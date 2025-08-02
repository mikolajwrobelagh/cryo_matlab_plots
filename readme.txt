# cryo_plot.m - MATLAB Cryogenic Data Visualizer 🧊📊

This MATLAB function processes and plots raw cryogenic lab sensor data.
data has to in a matrix format w the first 4 columns containing the temperatures and the fifth column time in seconds
## Features
- Removes non-increasing timestamps and duplicates
- Applies moving average smoothing
- Detects and removes spikes via Z-score filtering
- Interpolates missing data with `pchip`
- Converts units to °C or °F
- Exports high-resolution PNG and vector PDF plots

## Example Usage

```matlab
cryo_plot('Zeszyt2CCCSV.csv') 
% Default: °C, smoothing=5, threshold=3, export=on

% Or fully customized:
cryo_plot('Zeszyt2CCCSV.csv', 'F', 7, 2.5, true)
