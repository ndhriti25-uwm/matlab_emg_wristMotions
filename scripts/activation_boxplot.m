%% plot_rms_boxchart_only.m
clear; clc;

% Load outputs created by run_emg_analysis_tables.m
if ~isfile("emg_analysis_outputs.mat")
    error("Missing emg_analysis_outputs.mat. Run run_emg_analysis_tables.m first.");
end

load("emg_analysis_outputs.mat", "resultsTable");

% Make sure figures folder exists
if ~exist("figures","dir")
    mkdir("figures");
end

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

ax = gca;
ax.FontSize = 13;

% Save
exportgraphics(gcf, fullfile("figures","plot_RMS_distribution.png"), "Resolution", 300);

fprintf("Saved: figures/plot_RMS_distribution.png\n");
