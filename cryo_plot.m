function cryo_plot(filename, unitSystem, smoothingWindow, spikeThresh, exportFlag)
% CRYO_PLOT processes and plots cryogenic sensor data of form

if nargin < 5, exportFlag = true; end
if nargin < 4, spikeThresh = 3; end
if nargin < 3, smoothingWindow = 5; end
if nargin < 2, unitSystem = 'C'; end

% Load data
data = readmatrix(filename);
time = data(:,5);
T1 = data(:,1);
T2 = data(:,2);
T3 = data(:,3);
T4 = data(:,4);

% Remove non-increasing and duplicate time values
valid = [true; diff(time) > 0];
time = time(valid);
T1 = T1(valid); T2 = T2(valid); T3 = T3(valid); T4 = T4(valid);
[T_unique, ~, ic] = unique(time);
time = T_unique;

T1_avg = accumarray(ic, T1, [], @mean);
T2_avg = accumarray(ic, T2, [], @mean);
T3_avg = accumarray(ic, T3, [], @mean);
T4_avg = accumarray(ic, T4, [], @mean);

% Smoothing
T1_s = movmean(T1_avg, smoothingWindow);
T2_s = movmean(T2_avg, smoothingWindow);
T3_s = movmean(T3_avg, smoothingWindow);
T4_s = movmean(T4_avg, smoothingWindow);

% Z-score spike detection
z1 = (T1_s - mean(T1_s, 'omitnan')) ./ std(T1_s, 'omitnan');
z2 = (T2_s - mean(T2_s, 'omitnan')) ./ std(T2_s, 'omitnan');
z3 = (T3_s - mean(T3_s, 'omitnan')) ./ std(T3_s, 'omitnan');
z4 = (T4_s - mean(T4_s, 'omitnan')) ./ std(T4_s, 'omitnan');

% Remove spikes
T1_c = T1_s; T1_c(abs(z1) > spikeThresh) = NaN;
T2_c = T2_s; T2_c(abs(z2) > spikeThresh) = NaN;
T3_c = T3_s; T3_c(abs(z3) > spikeThresh) = NaN;
T4_c = T4_s; T4_c(abs(z4) > spikeThresh) = NaN;

% Interpolate over NaNs
T1_f = fillmissing(T1_c, 'pchip');
T2_f = fillmissing(T2_c, 'pchip');
T3_f = fillmissing(T3_c, 'pchip');
T4_f = fillmissing(T4_c, 'pchip');

% Convert to Fahrenheit if needed
if strcmpi(unitSystem, 'F')
    T1_f = T1_f * 9/5 + 32;
    T2_f = T2_f * 9/5 + 32;
    T3_f = T3_f * 9/5 + 32;
    T4_f = T4_f * 9/5 + 32;
    ylabelText = 'Temperature [°F]';
else
    ylabelText = 'Temperature [°C]';
end

% Plotting
figure;
plot(time, T1_f, 'r', time, T2_f, 'g', time, T3_f, 'b', time, T4_f, 'k');
xlabel('Time [s]');
ylabel(ylabelText);
title('Cryogenic Sensor Readings');
legend('Sensor 1','Sensor 2','Sensor 3','Sensor 4','Location','northeast');
grid on;

% Export
if exportFlag
    set(gcf, 'PaperOrientation', 'landscape');
    set(gcf, 'PaperUnits', 'normalized');
    set(gcf, 'PaperPosition', [0 0 1 1]);
    [~, name, ~] = fileparts(filename);
    print(gcf, [name '_plot.png'], '-dpng', '-r600');
    print(gcf, [name '_plot.pdf'], '-dpdf', '-painters');
end

end  % END OF FUNCTION
