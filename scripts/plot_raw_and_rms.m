function plot_raw_and_rms(record)
% plot_raw_and_rms(record)
% Creates:
% 1) Main plot: Raw EMG (blue) + RMS envelope (orange, positive only)
%    with peak activity window marked (shaded + dashed boundary lines)
% 2) Zoom plot: Raw EMG only in the peak window, aligned with the same dashed lines
%
% Input:
%   record = "session1_participant1_gesture11_trial3" (no extensions)

close all;

%% 1) Get peak window + dominant channel from analysis
res = analyze_emg_record(record);
fs     = res.fs;
bestCh = res.bestCh;
tStart = res.windowStart_s;
tEnd   = res.windowEnd_s;

%% 2) Read header (.hea)
heaText = fileread(record + ".hea");
lines = splitlines(string(heaText));
lines(lines=="") = [];

first = strsplit(strtrim(lines(1)));
nCh   = str2double(first(2));
nSamp = str2double(first(4));

%% 3) Read raw binary (.dat)
fid = fopen(record + ".dat","r");
raw = fread(fid, [nCh, nSamp], "int16=>double"); % channels x samples
fclose(fid);

data_counts = raw.';                 % samples x channels
t = (0:nSamp-1).' / fs;              % time vector (seconds)

%% 4) Convert counts → mV
gain = zeros(1,nCh);
base = zeros(1,nCh);

for ch = 1:nCh
    chLine = lines(ch+1);
    tok = regexp(chLine, "(\d+\.?\d*)\((\-?\d+)\)\/mV", "tokens", "once");
    gain(ch) = str2double(tok{1});
    base(ch) = str2double(tok{2});
end

data_mV = (data_counts - base) ./ gain;

%% 5) Extract dominant channel
if bestCh > size(data_mV,2)
    warning("bestCh=%d but only %d channels exist. Using channel 1.", bestCh, size(data_mV,2));
    bestCh = 1;
end
raw_mV = data_mV(:, bestCh);

%% 6) RMS envelope (50 ms window — matches analyze_emg_record)
rmsWin_s  = 0.05;
rmsWin    = max(1, round(rmsWin_s * fs));
rmsEnv_mV = sqrt(movmean((abs(raw_mV)).^2, rmsWin));

%% 7) MAIN FIGURE: Raw + RMS + peak window
figure('Position',[100 100 1050 380]);

hRaw = plot(t, raw_mV, 'b', 'LineWidth', 0.2);     % raw EMG (blue)
hold on;

hRMS = plot(t, rmsEnv_mV, 'Color', [1 0.5 0], ...  % RMS envelope (orange)
    'LineWidth', 1);

% Shade peak activity window
yl = ylim;
patch([tStart tEnd tEnd tStart], ...
      [yl(1) yl(1) yl(2) yl(2)], ...
      [0.9 0.9 0.9], ...
      'FaceAlpha', 0.25, 'EdgeColor', 'none');

% Window boundaries (dashed)
xline(tStart, '--k', 'LineWidth', 1.2);
xline(tEnd,   '--k', 'LineWidth', 1.2);

% Ensure lines stay on top of shading
uistack([hRaw hRMS], 'top');

xlabel("Time (s)");
ylabel("EMG (mV)");
title("Raw EMG + RMS Envelope with Peak Window — " + record + ...
      " (bestCh=" + bestCh + ")", 'FontSize', 10);

% Legend: force it to include BOTH plotted lines (blue + orange)
legend([hRaw hRMS], {"Raw EMG", "RMS envelope"}, 'Location', 'northeast');

grid on;
hold off;

%% 8) ZOOM FIGURE: Raw EMG only in peak window (aligned with dashed lines)
idx = (t >= tStart) & (t <= tEnd);

figure('Position',[100 520 1050 330]);
plot(t(idx), raw_mV(idx), 'b', 'LineWidth', 1.2);

% Force exact alignment with the window boundaries
xlim([tStart tEnd]);

hold on;
xline(tStart, '--k', 'LineWidth', 1.2);
xline(tEnd,   '--k', 'LineWidth', 1.2);
hold off;

xlabel("Time (s)");
ylabel("EMG (mV)");
title("Raw EMG (Peak Window Only) — " + record + ...
      " [" + num2str(tStart,'%.3f') + "–" + num2str(tEnd,'%.3f') + " s]", ...
      'FontSize', 10);

grid on;

%% 9) Save figures for GitHub (raw_rms_peak_plots folder)
saveDir = fullfile("figures", "raw_rms_peak_plots");

if ~exist(saveDir, "dir")
    mkdir(saveDir);
end

exportgraphics(figure(1), ...
    fullfile(saveDir, record + "_raw_rms_full.png"), ...
    "Resolution", 300);

exportgraphics(figure(2), ...
    fullfile(saveDir, record + "_raw_peak_window.png"), ...
    "Resolution", 300);



end
