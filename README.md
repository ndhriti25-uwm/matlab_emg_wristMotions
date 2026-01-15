# EMG Wrist & Hand Gesture Analysis (GRABMyo Dataset)
## Overview
This project analyzes multi-channel surface electromyography (sEMG) data from the GRABMyo dataset to characterize hand and wrist gestures. Raw EMG recordings are processed in MATLAB to compute RMS envelopes, identify dominant electrodes, detect peak activation windows, and summarize activation strength and timing across repeated trials and gestures. All analysis is implemented using custom MATLAB scripts without reliance on external toolboxes.
## Dataset
- **Dataset:** Gesture Recognition and Biometrics ElectroMyogram (GRABMyo), version 1.1.0
- **Source:** PhysioNet
- **Signal type:** Multi-channel forearm and wrist EMG
- **File formats:** `.hea` (header) and `.dat` (binary signal)
- **Gestures analyzed:**
  - Wrist Extension (gesture 11)
  - Wrist Flexion (gesture 12)
  - Hand Open (gesture 15)
  - Hand Close (gesture 16)
The scripts directly parse the `.hea` files to extract channel gains and baselines and read the `.dat` files to obtain raw EMG signals.
## Analysis Workflow
### RMS Envelope and Dominant Electrode Detection
For each trial, raw EMG counts are converted to millivolts using per-channel gain and baseline values from the header file. A 50 ms RMS envelope is computed for each channel. A sliding 1-second window is applied to each RMS envelope, and the channel with the highest sustained mean RMS value is selected as the dominant (best) electrode for that trial.
### Peak Activation Window
For the dominant electrode, the peak activation window is defined as the 1-second window centered at the time of maximum sustained RMS activation. The following metrics are extracted for each trial:
- Dominant electrode index `bestCh`
- Peak window start time `windowStart_s`
- Peak window end time `windowEnd_s`
- Peak window duration `duration_s`
- Mean RMS amplitude within the peak window `meanRMS_mV`
- Maximum RMS amplitude within the peak window `maxRMS_mV`
### Cross-Trial and Cross-Gesture Analysis
Results are aggregated across trials to compare dominant electrode consistency, activation strength distributions, and peak activation timing across gestures.
## Scripts (What Each One Does)
### `analyze_emg_record.m`
Core analysis function that processes a single EMG trial.
**Input:** a record name string (no file extensions), for example:
```matlab
result = analyze_emg_record("session1_participant1_gesture11_trial3");
```
**Output:** a structure containing:
- `record`
- `fs`
- `bestCh`
- `windowStart_s`
- `windowEnd_s`
- `duration_s`
- `meanRMS_mV`
- `maxRMS_mV`

This function is used by both the batch analysis script and the plotting function.

### `run_trials_tables.m`
Batch analysis script that loops over all gestures and trials:
```matlab
gestures = [11, 12, 15, 16];
trials   = 1:7;
```

**Outputs generated:**
- `emg_analysis_results.csv` — per-trial metrics for all recordings
- `timing_summary.csv` — gesture-level peak timing statistics

The script prints progress messages and displays summary tables in the MATLAB command window.

### `plot_raw_and_rms.m`
Visualization function that generates detailed plots for any single trial.

**Produces two plots per trial:**
1. Full-trial plot showing raw EMG (blue) with RMS envelope (orange, positive only), with the peak activation window highlighted using shading and dashed boundary lines
2. Zoomed plot showing raw EMG only within the peak activation window, aligned to the same start and end boundaries

**Usage:**
```matlab
plot_raw_and_rms("session1_participant1_gesture11_trial3");
```

**Outputs saved to:**
- `figures/raw_rms_peak_plots/`
  - `<record>_raw_rms_full.png`
  - `<record>_raw_peak_window.png`

In this repository, these plots were generated for all gesture–trial combinations.

### `dom_electrode.m`
Reads `emg_analysis_results.csv` and computes dominant electrode counts grouped by gesture.

**Outputs generated:**
- `figures/plotA_dominantElectrode_counts.png`
- `results/plotA_bestCh_counts.csv`

### `activation_boxplot.m`
Reads `emg_analysis_results.csv` and generates a boxchart comparing mean RMS activation strength across gestures.

**Output generated:**
- `figures/plot_RMS_distribution.png`

## Figures Included in This Repository
This repository includes five summary figures stored in the `figures/` directory:
- Distribution of EMG Activation Strength by Gesture (Median + IQR)
- Dominant (Best) Electrode by Gesture Across Trials
- When Peak Activation Occurs (Center of Peak Window)
- Peak Activation Timing by Gesture (Mean ± SD)

In addition, the `figures/raw_rms_peak_plots/` folder contains raw EMG and RMS envelope plots for every individual trial.

## Tables Included in This Repository
- `emg_analysis_results.csv` — per-trial dominant electrode and peak window metrics (produced by `run_trials_tables.m`)
- `timing_summary.csv` — gesture-level peak timing statistics (produced by `run_trials_tables.m`)
- `results/plotA_bestCh_counts.csv` — dominant electrode counts by gesture (produced by `dom_electrode.m`)

## How To Run
### Prerequisites
- MATLAB (no additional toolboxes required)
- GRABMyo `.hea` and `.dat` files for the desired gesture and trial recordings

### Setup
Place the GRABMyo data files (`.hea` and `.dat`) in the same working directory as the scripts, or ensure MATLAB's current folder is set to the directory containing the data files.

Ensure a `figures/` directory exists (scripts will create it if needed).

### Run the Full Analysis
```matlab
run_trials_tables
```

### Generate Summary Figures
```matlab
dom_electrode
activation_boxplot
```

### Generate Raw + RMS Plots for a Single Trial
```matlab
plot_raw_and_rms("session1_participant1_gesture11_trial3");
```

## Customization
To analyze different gestures or trial ranges, edit the arrays in `run_trials_tables.m`:
```matlab
gestures = [11, 12, 15, 16];
trials   = 1:7;
```

To adjust analysis parameters, modify values in `analyze_emg_record.m`:
- RMS smoothing window: `rmsWin_s`
- Peak activation window length: `winActive_s`

## Citation
If you use this dataset or analysis pipeline, please cite the following sources.

### GRABMyo Dataset (PhysioNet)
Jiang, N., Pradhan, A., & He, J. (2024). Gesture Recognition and Biometrics ElectroMyogram (GRABMyo) (version 1.1.0). PhysioNet. RRID:SCR_007345. https://doi.org/10.13026/89dm-f662

### Original Publication
Pradhan, A., He, J., & Jiang, N. (2022). Multi-day dataset of forearm and wrist electromyogram for hand gesture recognition and biometrics. Scientific Data, 9, 733. https://doi.org/10.1038/s41597-022-01836-y

### PhysioNet
Goldberger, A. L., Amaral, L. A. N., Glass, L., Hausdorff, J. M., Ivanov, P. C., Mark, R. G., et al. (2000). PhysioBank, PhysioToolkit, and PhysioNet: Components of a new research resource for complex physiologic signals. Circulation, 101(23), e215–e220. RRID:SCR_007345.
