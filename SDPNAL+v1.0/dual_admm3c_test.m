function [S, X, epsilon, time, num_pos] = dual_admm3c_test(X0, G, k, eps, p_iter)
% Wrapper to use dual admm convergent algorithm.
n = size(X0, 1);
% G = (G + G')/2; % make sure it is symmetric
costmax = trace(G * X0);
max_iter = 5000;

eta = zeros(n); % need to nonnegative
v = 0.01; % need to be nonnegative
S = zeros(n); % need to be psd
X1 = X0; 
X2 = X0;
sigma = 0.05;
tau = 1.618;
tic;

[S, X, epsilon, num_pos] = dual_admm3c(X0, G, k, costmax, eta, v, S, X1, X2, sigma, tau, max_iter, eps, p_iter);
time=toc;
end