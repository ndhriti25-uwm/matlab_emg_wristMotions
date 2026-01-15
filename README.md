# EMG Wrist & Hand Gesture Analysis (GRABMyo Dataset)

## Overview
This project analyzes multi-channel surface electromyography (EMG) data to characterize hand and wrist gestures using signal processing and statistical analysis. Raw EMG recordings from the GRABMyo dataset are processed to identify dominant electrodes, quantify muscle activation strength, and analyze the timing of peak muscle activation across repeated trials and gestures. All analysis is implemented in MATLAB using custom scripts, with no reliance on external toolboxes.

---

## Dataset
- Dataset: Gesture Recognition and Biometrics ElectroMyogram (GRABMyo), version 1.1.0  
- Source: PhysioNet  
- Signal type: Multi-channel forearm and wrist EMG  
- Gestures analyzed:
  - Hand Close
  - Hand Open
  - Wrist Extension
  - Wrist Flexion  

Raw data files (.hea and .dat) are parsed directly by the analysis scripts.

---

## Analysis Workflow

### Raw EMG Processing
For each trial, EMG counts are converted to millivolts using per-channel gain and baseline values from the header file. A 50 ms RMS envelope is computed for each channel to represent muscle activation intensity.

### Dominant Electrode Identification
A sliding 1-second window is applied to the RMS envelope of each channel. The channel with the highest sustained mean RMS value is selected as the dominant (best) electrode for that trial.

### Peak Activation Window
The center, start, and end of the peak activation window are identified for the dominant electrode. The following metrics are extracted for each trial:
- Mean RMS amplitude (mV)
- Maximum RMS amplitude (mV)
- Peak window duration (s)
- Peak activation center time (s)

### Cross-Trial and Cross-Gesture Analysis
Results are aggregated across trials to compare dominant electrode consistency, EMG activation strength, and the timing of peak activation across gestures.

---

## Scripts

analyze_emg_record.m  
Core analysis function that reads raw EMG data, computes RMS envelopes, identifies the dominant electrode, determines the peak activation window, and returns quantitative metrics for a single trial.

plot_raw_and_rms.m  
Visualization function that generates raw EMG signals with RMS envelopes over the full trial and raw EMG signals restricted to the peak activation window. Peak window boundaries are marked, and figures are saved to figures/raw_rms_peak_plots/. Raw and peak plots were generated for every trial, which are all included in the repository.

run_trials_tables.m  
Batch-processing script that runs the analysis across all gestures and trials, compiles results into tables, and saves summary CSV files.

dom_electrode.m  
Aggregates dominant electrode selections across trials and generates stacked bar charts showing electrode consistency by gesture. Resulting visual is included in repository.

activation_boxplot.m  
Creates boxplots (median and interquartile range) of mean RMS activation amplitude to compare muscle activation strength across gestures.

---

## Results

### Figures
The repository includes:
- Raw EMG with RMS envelope and highlighted peak activation windows
- Peak activation timing by gesture (mean ± standard deviation)
- Dominant electrode distribution across trials for each gesture
- Distribution of EMG activation strength by gesture (median + IQR)

In addition to the example figures shown in the repository, raw and peak activity plots were generated for every individual trial.

### Tables
CSV files summarizing the analysis include:
- emg_analysis_results.csv: per-trial metrics including dominant channel and RMS features
- timing_summary.csv: gesture-level peak timing statistics
- Dominant electrode count tables by gesture

All tables are viewable directly on GitHub and fully reproducible from the scripts.

---

## How to Run
1. Set MATLAB’s current folder to the repository root.
2. Add the scripts folder to the MATLAB path:
```matlab
addpath("scripts")

