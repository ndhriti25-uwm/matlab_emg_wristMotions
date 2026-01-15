% List of gestures and trials to analyze
gestures = [11, 12, 15, 16];
trials = 1:7;
validCount = 0;

for g = 1:length(gestures)
    gestureNum = gestures(g);
    
    for t = 1:length(trials)
        trialNum = trials(t);
        
        % Build record name with gesture number
        record = "session1_participant1_gesture" + gestureNum + "_trial" + trialNum;
        
        % Check if files exist before trying to read them
        if isfile(record + ".hea") && isfile(record + ".dat")
            try
                r = analyze_emg_record(record);
                validCount = validCount + 1;
                
                if validCount == 1
                    % First valid trial - initialize results structure
                    results = r;
                else
                    % Append to results
                    results(validCount) = r;
                end
                
                fprintf('✓ Gesture %d, Trial %d analyzed successfully\n', gestureNum, trialNum);
            catch ME
                warning('Error analyzing Gesture %d, Trial %d: %s', gestureNum, trialNum, ME.message);
            end
        else
            warning('Gesture %d, Trial %d files not found (skipping)', gestureNum, trialNum);
        end
    end
end

% Check if we got any results
if validCount == 0
    error('No valid trials found!');
end

% ===============================
% PART A: Create results table with gesture labels
% ===============================
resultsTable = struct2table(results);

% Parse gesture and trial numbers from record names
rec = string(resultsTable.record);
tok = regexp(rec, "gesture(\d+)_trial(\d+)", "tokens", "once");
resultsTable.gestureNum = cellfun(@(c) str2double(c{1}), tok);
resultsTable.trialNum = cellfun(@(c) str2double(c{2}), tok);

% Map gesture numbers to names
gestureMap = containers.Map( ...
    [11, 12, 15, 16], ...
    ["Wrist Extension", "Wrist Flexion", "Hand Open", "Hand Close"] ...
);

% Add gesture names
gName = strings(height(resultsTable), 1);
for i = 1:height(resultsTable)
    if isKey(gestureMap, resultsTable.gestureNum(i))
        gName(i) = gestureMap(resultsTable.gestureNum(i));
    else
        gName(i) = "Other";
    end
end
resultsTable.gestureName = categorical(gName);

% Filter to only keep valid gestures
resultsTable = resultsTable(resultsTable.gestureName ~= "Other", :);

% Display key columns
fprintf('\n=== Analysis Results ===\n');
disp(resultsTable(:, ["record", "gestureNum", "trialNum", "gestureName", "bestCh", "meanRMS_mV", "maxRMS_mV"]));

% ===============================
% PART B: Peak Activation Timing Analysis
% ===============================

% Create peak center time from window boundaries
resultsTable.peakCenter_s = (resultsTable.windowStart_s + resultsTable.windowEnd_s) / 2;

% Group by gesture name and calculate statistics
[G, gestureNames] = findgroups(resultsTable.gestureName);

meanStart = splitapply(@mean, resultsTable.windowStart_s, G);
meanEnd   = splitapply(@mean, resultsTable.windowEnd_s, G);
meanDur   = splitapply(@mean, resultsTable.duration_s, G);
meanCtr   = splitapply(@mean, resultsTable.peakCenter_s, G);
stdCtr    = splitapply(@std,  resultsTable.peakCenter_s, G);

timingSummary = table(gestureNames, meanStart, meanEnd, meanDur, meanCtr, stdCtr, ...
    'VariableNames', {'gestureName', 'meanPeakStart_s', 'meanPeakEnd_s', ...
                      'meanPeakDuration_s', 'meanPeakCenter_s', 'stdPeakCenter_s'});

fprintf('\n=== Timing Summary by Gesture ===\n');
disp(timingSummary);

% ===============================
% PART C: Visualization
% ===============================

%% ===== RMS DISTRIBUTION (boxchart – no toolbox required) =====

% Extract data
x = double(resultsTable.meanRMS_mV);
g = categorical(resultsTable.gestureName);

% Remove missing values
keep = ~isnan(x) & ~ismissing(g);
x = x(keep);
g = g(keep);

% Plot
figure('Position',[100 100 800 500])
boxchart(g, x)

ylabel("Mean RMS amplitude (mV)")
title("Distribution of EMG Activation Strength by Gesture (Median + IQR)")
grid on

% Improve readability
ax = gca;
ax.FontSize = 13;

% Save
if ~exist("figures","dir"); mkdir("figures"); end
exportgraphics(gcf, "figures/plot_RMS_distribution.png", "Resolution", 300);


% ===============================
% PART D: Save results to file
% ===============================
writetable(resultsTable, 'emg_analysis_results.csv');
writetable(timingSummary, 'timing_summary.csv');
fprintf('\nSaved: emg_analysis_results.csv\n');
fprintf('Saved: timing_summary.csv\n');

fprintf('\n=== Analysis Complete! ===\n');
fprintf('Analyzed %d trials across %d gestures\n', height(resultsTable), length(gestureNames));