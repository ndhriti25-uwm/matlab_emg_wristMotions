%% dom_electrode.m
% Dominant electrode counts by gesture
% Produces:
%   figures/plotA_dominantElectrode_counts.png
%   results/plotA_bestCh_counts.csv

clear; clc;

% ------------------------------------------------------------
% 1) Load resultsTable (prefer results/..., fallback to root)
% ------------------------------------------------------------
csv1 = fullfile("results", "emg_analysis_results.csv");
csv2 = "emg_analysis_results.csv";

if isfile(csv1)
    T = readtable(csv1);
elseif isfile(csv2)
    T = readtable(csv2);
else
    error("Missing emg_analysis_results.csv. Run run_trials_tables.m first.");
end

% ------------------------------------------------------------
% 2) Validate required columns
% ------------------------------------------------------------
req = ["bestCh"];
for k = 1:numel(req)
    if ~ismember(req(k), T.Properties.VariableNames)
        error("results table is missing required column: %s", req(k));
    end
end

% Need gestureName; if missing, build from gestureNum
if ~ismember("gestureName", T.Properties.VariableNames)
    if ismember("gestureNum", T.Properties.VariableNames)
        gestureMap = containers.Map( ...
            [11, 12, 15, 16], ...
            ["Wrist Extension", "Wrist Flexion", "Hand Open", "Hand Close"] ...
        );

        gName = strings(height(T), 1);
        for i = 1:height(T)
            gnum = T.gestureNum(i);
            if isKey(gestureMap, gnum)
                gName(i) = gestureMap(gnum);
            else
                gName(i) = "Other";
            end
        end
        T.gestureName = categorical(gName);
    else
        error("Missing gestureName (and gestureNum). Cannot group by gesture.");
    end
end

% Force consistent types (prevents == / xticklabels issues)
T.gestureName = categorical(string(T.gestureName));  % works even if already categorical
T.bestCh = double(T.bestCh);

% Optional: drop "Other" if it exists
T = T(~ismissing(T.gestureName) & T.gestureName ~= "Other", :);

% ------------------------------------------------------------
% 3) Count (gestureName, bestCh) pairs
% ------------------------------------------------------------
[Gid, gestureGroup, chGroup] = findgroups(T.gestureName, T.bestCh);
counts = splitapply(@numel, T.bestCh, Gid);

countTable = table(gestureGroup, chGroup, counts, ...
    'VariableNames', {'gestureName','bestCh','count'});

% ------------------------------------------------------------
% 4) Convert to matrix for stacked bar plot
% ------------------------------------------------------------
gestures   = categories(categorical(countTable.gestureName));
electrodes = sort(unique(countTable.bestCh));

M = zeros(numel(gestures), numel(electrodes));

for i = 1:height(countTable)
    r = find(strcmp(gestures, char(countTable.gestureName(i))));
    c = find(electrodes == countTable.bestCh(i));
    if ~isempty(r) && ~isempty(c)
        M(r, c) = countTable.count(i);
    end
end

% ------------------------------------------------------------
% 5) Plot
% ------------------------------------------------------------
figure('Position',[100 100 950 500]);
bar(M, 'stacked');

xticks(1:numel(gestures));
xticklabels(gestures);
ax = gca;
ax.XAxis.FontSize = 10;

xlabel("Gesture");
ylabel("Number of trials where channel was best");
title("Dominant (Best) Electrode by Gesture Across Trials");
legend("Ch " + string(electrodes), 'Location', 'eastoutside');
grid on;

% ------------------------------------------------------------
% 6) Save outputs
% ------------------------------------------------------------
if ~exist("figures","dir"); mkdir("figures"); end
if ~exist("results","dir"); mkdir("results"); end

exportgraphics(gcf, fullfile("figures","plotA_dominantElectrode_counts.png"), "Resolution", 300);
writetable(countTable, fullfile("results","plotA_bestCh_counts.csv"));

fprintf("Saved: figures/plotA_dominantElectrode_counts.png\n");
fprintf("Saved: results/plotA_bestCh_counts.csv\n");
