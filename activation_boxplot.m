%% activation_boxplot.m
clear; clc;

% This script generates: figures/plot_RMS_distribution.png
% It expects emg_analysis_results.csv to exist (created by run_trials_tables.m)

% -----------------------------
% 1) Load results CSV
% -----------------------------
csv1 = fullfile("results", "emg_analysis_results.csv");
csv2 = "emg_analysis_results.csv";

if isfile(csv1)
    resultsTable = readtable(csv1);
elseif isfile(csv2)
    resultsTable = readtable(csv2);
else
    error("Missing emg_analysis_results.csv. Run run_trials_tables.m first (to create the CSV).");
end

% -----------------------------
% 2) Ensure gestureName exists
% -----------------------------
if ~ismember("gestureName", resultsTable.Properties.VariableNames)
    % Try to construct gestureName from gestureNum if available
    if ismember("gestureNum", resultsTable.Properties.VariableNames)
        gestureMap = containers.Map( ...
            [11, 12, 15, 16], ...
            ["Wrist Extension", "Wrist Flexion", "Hand Open", "Hand Close"] ...
        );

        gName = strings(height(resultsTable), 1);
        for i = 1:height(resultsTable)
            gnum = resultsTable.gestureNum(i);
            if isKey(gestureMap, gnum)
                gName(i) = gestureMap(gnum);
            else
                gName(i) = "Other";
            end
        end
        resultsTable.gestureName = categorical(gName);
    else
        error("resultsTable is missing gestureName (and gestureNum). Cannot group by gesture.");
    end
end

% -----------------------------
% 3) Make sure figures folder exists
% -----------------------------
if ~exist("figures","dir")
    mkdir("figures");
end

% -----------------------------
% 4) Extract data and clean
% -----------------------------
if ~ismember("meanRMS_mV", resultsTable.Properties.VariableNames)
    error("resultsTable is missing meanRMS_mV. Check emg_analysis_results.csv columns.");
end

x = double(resultsTable.meanRMS_mV);
g = categorical(resultsTable.gestureName);

keep = ~isnan(x) & ~ismissing(g);
x = x(keep);
g = g(keep);

% -----------------------------
% 5) Plot + save
% -----------------------------
figure('Position',[100 100 800 500]);
boxchart(g, x);

ylabel("Mean RMS amplitude (mV)");
title("Distribution of EMG Activation Strength by Gesture (Median + IQR)");
grid on;

ax = gca;
ax.FontSize = 13;

exportgraphics(gcf, fullfile("figures","plot_RMS_distribution.png"), "Resolution", 300);
fprintf("Saved: figures/plot_RMS_distribution.png\n");
