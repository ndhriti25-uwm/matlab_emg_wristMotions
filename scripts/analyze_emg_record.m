function result = analyze_emg_record(record)
% analyze_emg_record(record)
% INPUT:
%   record = string like "session1_participant1_gesture1_trial1" (no .hea/.dat)
% OUTPUT:
%   result = struct with fields like bestCh, meanRMS, maxRMS, windowStart, windowEnd

%% 1) Read header (.hea) to get sampling + per-channel scaling
heaText = fileread(record + ".hea");          % Loads the header text into MATLAB
lines = splitlines(string(heaText));          % Splits header into separate lines
lines(lines=="") = [];                        % Removes empty lines

first = strsplit(strtrim(lines(1)));          % Splits first header line into parts
nCh   = str2double(first(2));                 % Number of channels
fs    = str2double(first(3));                 % Sampling frequency (Hz)
nSamp = str2double(first(4));                 % Number of samples

%% 2) Read raw binary (.dat) into a matrix (time x channels)
fid = fopen(record + ".dat","r");             % Opens the .dat file
raw = fread(fid, [nCh, nSamp], "int16=>double"); % Reads int16 counts into a matrix
fclose(fid);                                  % Closes the file
data_counts = raw.';                          % Transpose to nSamp x nCh (time x channel)
t = (0:nSamp-1).'/fs;                         % Time vector in seconds

%% 3) Parse gain + baseline for each channel from header
gain = zeros(1,nCh);                          % Preallocate gain array
base = zeros(1,nCh);                          % Preallocate baseline array

for ch = 1:nCh
    chLine = lines(ch+1);                     % Channel info is lines 2..(nCh+1)
    tok = regexp(chLine, "(\d+\.?\d*)\((\-?\d+)\)\/mV", "tokens", "once");
    gain(ch) = str2double(tok{1});            % Counts per mV
    base(ch) = str2double(tok{2});            % Baseline offset in counts
end

%% 4) Convert counts -> mV for all channels
data_mV = (data_counts - base) ./ gain;       % Converts each channel into millivolts

%% 5) RMS envelope for all channels
rmsWin_s = 0.05;                              % 50 ms RMS smoothing window
rmsWin   = max(1, round(rmsWin_s * fs));      % Window length in samples

data_rms = zeros(nSamp, nCh);                 % Preallocate RMS envelope matrix
for ch = 1:nCh
    x = data_mV(:,ch);                        % Raw EMG in mV (one channel)
    data_rms(:,ch) = sqrt(movmean((abs(x)).^2, rmsWin)); % RMS envelope in mV
end

%% 6) Find "best channel" = highest sustained mean RMS in a 1-second window
winActive_s = 1.0;                            % Window length = 1 second
winActive   = max(1, round(winActive_s * fs));% Samples in that window

bestScore = -inf;
bestCh = 1;
bestCenterIdx = 1;

for ch = 1:nCh
    env = data_rms(:,ch);                     % RMS envelope for this channel
    avg1s = movmean(env, winActive);          % Sliding 1-second mean RMS
    [score, centerIdx] = max(avg1s);          % Best sustained activation score + location
    if score > bestScore
        bestScore = score;
        bestCh = ch;
        bestCenterIdx = centerIdx;
    end
end

%% 7) Best window boundaries + features
s = max(1, bestCenterIdx - floor(winActive/2)); % Start index of best window
e = min(nSamp, s + winActive - 1);              % End index of best window

rmsEnv_mV = data_rms(:, bestCh);                % RMS envelope of best channel

meanRMS = mean(rmsEnv_mV(s:e));                 % Mean RMS in best window
maxRMS  = max(rmsEnv_mV(s:e));                  % Max RMS in best window
dur_s   = (e - s + 1)/fs;                       % Window duration in seconds

%% 8) Return results (no plotting inside function for scaling)
result.record = record;
result.fs = fs;
result.bestCh = bestCh;
result.windowStart_s = t(s);
result.windowEnd_s   = t(e);
result.meanRMS_mV = meanRMS;
result.maxRMS_mV  = maxRMS;
result.duration_s = dur_s;
end
