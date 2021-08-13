% Example calculations to demonstrate the use of fragility fitting
% functions for use with Incremental Dynamic Analysis Data. These 
% calculations are based on the following paper:
%
% Baker, J. W. (2015). “Efficient analytical fragility function fitting 
% using dynamic structural analysis.” Earthquake Spectra, 31(1), 579-599.
%
% Created by Jack Baker
% 2/4/2013
% Modified by Jack Baker, 1/25/2017, to update citation information

% example data: IM values at which a ground motion caused collapse
clear
clc

IM_cap10 = xlsread('C:\Users\KNUST\Desktop\bundle_postIDA\bundle_postIDA\postIDA\data_10_1_RDR_.xlsx');

IM_cap = [0.49	0.62	0.63	0.63	0.65	0.70	0.71	0.72	0.77	0.79	0.80	0.84	0.91	0.92	0.93	0.97	1.04	1.04	1.05	1.08	1.08	1.09	1.12	1.13	1.22	1.32	1.33	1.34	1.40	1.40	1.47	1.72	1.76	2.15	2.31	2.42	2.50];


% Method of moments fit, using equations 2 and 3
theta_hat_mom = exp(mean(log(IM_cap)));
beta_hat_mom = std(log(IM_cap));

% Maximum likelihood fit, using equation 11. This isn't theoretically
% correct, as the observations of collapse at each IM level are not
% independent, but in practice is appears to often produce numerical 
% results similar to the method of moments above. This approach is not
% recommended, but is provided for comparison purposes.
num_gms = length(IM_cap)*ones(size(IM_cap));
num_collapse = 1:length(IM_cap);
[theta_hat_mle, beta_hat_mle] = fn_mle_pc(IM_cap, num_gms, num_collapse);

% Maximum likelihood fit, using equation 7. This is the formulation for
% truncated IDA analysis, but works for untruncated data as long as the
% truncation value is larger than the largest observed IM_cap value.
IM_max = 4; % any value larger than max(IM_cap) will produce the same result
num_exceed = 0; % no analyses were truncated
[theta_hat_trunc_alt, beta_hat_trunc_alt] = fn_mle_truncated_ida(IM_cap, IM_max, num_exceed);


% compute fragility function using estimated parameters
x_vals = 0.01:0.01:3; % IM levels to plot fragility function at
p_collapse = normcdf((log(x_vals/theta_hat_mom))/beta_hat_mom); % compute fragility function using equation 1 and estimated parameters

% plot fragility curve
figure
plot(IM_cap,(1:length(IM_cap))/length(IM_cap), 'ob', 'linewidth', 2)
hold on
plot(x_vals, p_collapse, '-b', 'linewidth', 1)
legh = legend('Empirical cumulative distribution', 'Fitted fragility function', 4);
set(legh, 'fontsize', 12)
hx = xlabel('IM', 'Fontsize', 14);
hy = ylabel('Probability of collapse', 'Fontsize', 14);
axis([0 3 0 1])


%% example truncated data
% make example truncated data from the IM_cap data above
IM_max = 1.3;
IM_cap_trunc = IM_cap(IM_cap <= IM_max); % take only the results with IM <= IM_max
num_exceed = sum(IM_cap > IM_max); % how many analyses reached IM_max without collapsing

% Maximum likelihood fit, using equation 7.
[theta_hat_trunc, beta_hat_trunc] = fn_mle_truncated_ida(IM_cap_trunc, IM_max, num_exceed);

% compute fragility function using estimated parameters
p_collapse_trunc = normcdf((log(x_vals/theta_hat_trunc))/beta_hat_trunc); % compute fragility function using equation 1 and estimated parameters


% plot fragility curve
figure
plot(IM_cap_trunc,(1:length(IM_cap_trunc))/length(IM_cap), 'ob', 'linewidth', 2)
hold on
plot(IM_max*[1 1], [0 1], '--k')
plot(x_vals,p_collapse_trunc, '-b', 'linewidth', 1)
legh = legend('Empirical cumulative distribution', 'IM_{max}', 'Fitted fragility function', 4);
set(legh, 'fontsize', 12)
hx = xlabel('IM', 'Fontsize', 14);
hy = ylabel('Probability of collapse', 'Fontsize', 14);
axis([0 3 0 1])



