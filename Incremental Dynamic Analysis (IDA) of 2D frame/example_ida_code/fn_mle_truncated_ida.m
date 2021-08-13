function [theta, beta] = fn_mle_truncated_ida(IM_i, IM_max, num_exceed)
% by Jack Baker
% 10/9/2012
% Modified by Jack Baker, 1/25/2017, to update citation information
%
% This function fits a lognormal CDF to observed probability of collapse 
% data by minimizing the sum of squared errors between the observed and
% predicted fractions of collapse. This approach is investigated in
% equation 12 of the following paper.
%
% Baker, J. W. (2015). “Efficient analytical fragility function fitting 
% using dynamic structural analysis.” Earthquake Spectra, 31(1), 579-599.
%
%
% INPUTS:
% IM_i          1xn             IM levels at which a ground motion was
%                               observed to cause collapse
% IM_max        1x1             Maximum IM level for which analysis was performed
% num_exceed 	1x1             Number of analyses for which the IM_i
%                               exceeds IM_max (i.e., no collapse was
%                               observed)
% 
% OUTPUTS:
% theta         1x1             median of fragility function
% beta          1x1             lognormal standard deviation of fragility function


% Initial guess for the fragility function parameters theta and beta. 
% These initial choices should not need revision in most cases, but they 
% could be altered if needed.
x0 = [0.8 0.4]; 

% Run optimization
options = optimset('MaxFunEvals',1000, 'GradObj', 'off'); %maximum 1000 iterations, gradient of the function not provided
x = fminsearch(@mle_censored, x0, options, IM_i, IM_max, num_exceed) ;
theta = x(1);
beta = x(2);


% objective function to be optimized
function [ neg_loglik ] = mle_censored( x0, IM_i, IM_max, num_exceed )

if (x0(1)<=0) | (x0(2)<=0)
    neg_loglik = 10000; % penalize negative parameters so they aren't identified as optimal
else
    non_trunc_loglik = sum(log(lognpdf(IM_i, log(x0(1)), x0(2))));
    trunc_loglik = num_exceed * (log(1-logncdf(IM_max, log(x0(1)), x0(2))));
    neg_loglik = -(non_trunc_loglik + trunc_loglik); % negative sign because the function is being minimized (so we minimize the negative loglikelihood)
end


