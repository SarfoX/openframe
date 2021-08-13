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

IM_cap10 = xlsread('C:\Users\KNUST\Desktop\bundle_postIDA\bundle_postIDA\postIDA\data_10_4_MIDR_.xlsx');
IM_cap20 = xlsread('C:\Users\KNUST\Desktop\bundle_postIDA\bundle_postIDA\postIDA\data_20_4_MIDR_.xlsx');
IM_cap30 = xlsread('C:\Users\KNUST\Desktop\bundle_postIDA\bundle_postIDA\postIDA\data_30_4_MIDR_.xlsx');

x_vals10 = 0.01:0.01:ceil(max(IM_cap10)*1.2); 
x_vals20 = 0.01:0.01:ceil(max(IM_cap20)*1.2); 
x_vals30 = 0.01:0.01:ceil(max(IM_cap30)*1.2); 

% IM_cap = [0.49	0.62	0.63	0.63	0.65	0.70	0.71	0.72	0.77	0.79	0.80	0.84	0.91	0.92	0.93	0.97	1.04	1.04	1.05	1.08	1.08	1.09	1.12	1.13	1.22	1.32	1.33	1.34	1.40	1.40	1.47	1.72	1.76	2.15	2.31	2.42	2.50];


% Method of moments fit, using equations 2 and 3
theta_hat_mom10 = exp(mean(log(IM_cap10)));
beta_hat_mom10 = std(log(IM_cap10));
theta_hat_mom20 = exp(mean(log(IM_cap20)));
beta_hat_mom20 = std(log(IM_cap20));
theta_hat_mom30 = exp(mean(log(IM_cap30)));
beta_hat_mom30 = std(log(IM_cap30));

% Maximum likelihood fit, using equation 11. This isn't theoretically
% correct, as the observations of collapse at each IM level are not
% independent, but in practice is appears to often produce numerical 
% results similar to the method of moments above. This approach is not
% recommended, but is provided for comparison purposes.
num_gms10 = length(IM_cap10)*ones(size(IM_cap10));
num_collapse10 = 1:length(IM_cap10);
[theta_hat_mle10, beta_hat_mle10] = fn_mle_pc(IM_cap10, num_gms10, num_collapse10);

num_gms20 = length(IM_cap20)*ones(size(IM_cap20));
num_collapse20 = 1:length(IM_cap20);
[theta_hat_mle20, beta_hat_mle20] = fn_mle_pc(IM_cap20, num_gms20, num_collapse20);

num_gms30 = length(IM_cap30)*ones(size(IM_cap30));
num_collapse30 = 1:length(IM_cap30);
[theta_hat_mle30, beta_hat_mle30] = fn_mle_pc(IM_cap30, num_gms30, num_collapse30);

% Maximum likelihood fit, using equation 7. This is the formulation for
% truncated IDA analysis, but works for untruncated data as long as the
% truncation value is larger than the largest observed IM_cap value.
IM_max10 = 4.0;
IM_cap_trunc10 = IM_cap10(IM_cap10 <= IM_max10); % take only the results with IM <= IM_max
num_exceed10 = sum(IM_cap10 > IM_max10); % how many analyses reached IM_max without collapsing

% Maximum likelihood fit, using equation 7.
[theta_hat_trunc10, beta_hat_trunc10] = fn_mle_truncated_ida(IM_cap_trunc10, IM_max10, num_exceed10);

% compute fragility function using estimated parameters
p_collapse_trunc10 = normcdf((log(x_vals10/theta_hat_trunc10))/beta_hat_trunc10); % compute fragility function using equation 1 and estimated parameters




IM_max20 = 4.0;
IM_cap_trunc20 = IM_cap20(IM_cap20 <= IM_max20); % take only the results with IM <= IM_max
num_exceed20 = sum(IM_cap20 > IM_max20); % how many analyses reached IM_max without collapsing

% Maximum likelihood fit, using equation 7.
[theta_hat_trunc20, beta_hat_trunc20] = fn_mle_truncated_ida(IM_cap_trunc20, IM_max20, num_exceed20);

% compute fragility function using estimated parameters
p_collapse_trunc20 = normcdf((log(x_vals20/theta_hat_trunc20))/beta_hat_trunc20); % compute fragility function using equation 1 and estimated parameters




IM_max30 = 4.0;
IM_cap_trunc30 = IM_cap30(IM_cap30 <= IM_max30); % take only the results with IM <= IM_max
num_exceed30 = sum(IM_cap30 > IM_max30); % how many analyses reached IM_max without collapsing

% Maximum likelihood fit, using equation 7.
[theta_hat_trunc30, beta_hat_trunc30] = fn_mle_truncated_ida(IM_cap_trunc30, IM_max30, num_exceed30);

% compute fragility function using estimated parameters
p_collapse_trunc30 = normcdf((log(x_vals30/theta_hat_trunc30))/beta_hat_trunc30); % compute fragility function using equation 1 and estimated parameters



% compute fragility function using estimated parameters
% x_vals = 0.01:0.01:3; % IM levels to plot fragility function at
% p_collapse = normcdf((log(x_vals/theta_hat_mom))/beta_hat_mom); % compute fragility function using equation 1 and estimated parameters

% plot fragility curve
figure
% plot(IM_cap_trunc,(1:length(IM_cap_trunc))/length(IM_cap), 'ob', 'linewidth', 2)
% hold on
% plot(IM_max*[1 1], [0 1], '--k')
plot(x_vals10,p_collapse_trunc10, '-b', 'linewidth', 1)
hold on
plot(x_vals20,p_collapse_trunc20, '--r', 'linewidth', 1)
plot(x_vals30,p_collapse_trunc30, '-.k', 'linewidth', 1)
legh = legend('C10', 'C20', 'C30', 4);
set(legh, 'fontsize', 12)
hx = xlabel('IM (g)', 'Fontsize', 14);
hy = ylabel('Probability of collapse', 'Fontsize', 14);

caps = zeros(3,3);

xvals = vertcat(x_vals10,x_vals20,x_vals30);
pcollapse = vertcat(p_collapse_trunc10,p_collapse_trunc20,p_collapse_trunc30);
cutVals = zeros(3);
for j = 1:3
    xv = xvals(j,:);
    ps = pcollapse(j,:);
    for k = 1:3
        if k == 1
            cutVals(j,k) = interp1(ps,xv,0.14);
        elseif k == 2
            cutVals(j,k) = interp1(ps,xv,0.50);
        else
            cutVals(j,k) = interp1(ps,xv,0.86);
        end
    end
end

xlswrite('C:\Users\KNUST\Desktop\Results_IDA\CP_fractal_matrix_MIDR.xlsx',cutVals);
% axis([0 3 0 1])





