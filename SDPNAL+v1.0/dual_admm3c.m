function [S, X1, epsilon, num_pos] = dual_admm3c(X0, G, k, costmax, eta, v, S, X1, X2, sigma, tau, max_iter, eps, p_iter)
% Solve following SDP problem 
% min kz + alpha^T 1 - v costmax
% subject to; S = C + z I_n + (1 *alpha^T + alpha * 1^T)/2 - beta - v G;
%             S is psd
%             beta >= 0 beta is a n x n matrix
%             v >= 0
% by the algorithm in paper:
%     A Convergent 3-Block Semi-Proximal Alternating Direction Method of 
%     Multipliers for Conic Programming with 4-Type of Constraints.
% 
n = size(X0, 1);

epsilon = 0;

% Initialization

% s_1 = X0 - S - v * G + eta;
% a_1 = -trace(X0 - S - v * G);
% b_1 = -(X0 - S - v * G) * ones(n, 1);
% 
% sum_alpha = (sum(sum(s_1)) + 2 * sum(b_1) - trace(s_1) - 2 * a_1)/(n-1);
% z = (trace(s_1) + 2 * a_1 - sum_alpha)/n;
% alpha = (2 * s_1 * ones(n, 1) + 4 * b_1 - sum_alpha * ones(n, 1) - 2 * z * ones(n, 1))/n;
% A_alpha = (ones(n, 1) * alpha' + alpha * ones(1, n))/2;
% 
% beta = 0.5 * (s_1 + z * eye(n) + A_alpha);

sum_alpha = (sum(sum(eta + S)) - trace(eta + S + v * G) + k - n)/(n-1);
z = (trace(S + v * G + eta) - k - sum_alpha)/n;
alpha = (2 * (S + eta) * ones(n, 1) - 2 - sum_alpha - 2 * z)/n;
A_alpha = (ones(n, 1) * alpha' + alpha * ones(1, n))/2;
beta = 0.5 * (X0 - S - v * G + eta + A_alpha + z * eye(n));

num_pos = zeros(1, max_iter);
norm_G = norm(G, 'fro')^2;

for i = 1:max_iter
    
% Update S and eta variable
T_1 = v * G - z*eye(n) - A_alpha + beta - X0;
M = -T_1 - X1/sigma;
% [eig_vec, eig_val] = eig(-T_1 - X1/sigma);
% [eig_vec, eig_val] = eig(S);
% pos_loc = find(diag(eig_val) <= 0);
% num_pos(i) = n - length(pos_loc);
% fprintf('number of positive eigenvalues is %d\n', num_pos(i));
% eig_vec_pos = eig_vec(:, pos_loc);
% eig_val_pos = eig_val(pos_loc, pos_loc);
% S = eig_vec_pos * eig_val_pos * eig_vec_pos';
% S = S - eig_vec_pos * eig_val_pos * eig_vec_pos';
[v_ignore, S] = proj_psd_largescale(1, -M, 1);
% [v_ignore, S] = proj_psd_ls(1, -M, 1);
S = S + M;
S = (S + S')/2;


eta = max(beta - X2/sigma, 0);

% Update beta, z and alpha variable
sum_alpha = (sum(sum(eta + S)) - trace(eta + S + v * G) + k - n)/(n-1);
z = (trace(S + v * G + eta) - k - sum_alpha)/n;
alpha = (2 * (S + eta) * ones(n, 1) - 2 - sum_alpha - 2 * z)/n;
A_alpha = (ones(n, 1) * alpha' + alpha * ones(1, n))/2;
beta = 0.5 * (X0 - S - v * G + eta + A_alpha + z * eye(n));

% Update v variable
T_2 = S - z * eye(n) - A_alpha + beta - X0;
v = (costmax - trace(G * X1) - sigma * trace(G * T_2)) / (sigma * norm_G);
v = max(v, 0);

% Update beta, z and alpha variable again
sum_alpha = (sum(sum(eta + S)) - trace(eta + S + v * G) + k - n)/(n-1);
z = (trace(S + v * G + eta) - k - sum_alpha)/n;
alpha = (2 * (S + eta) * ones(n, 1) - 2 - sum_alpha - 2 * z)/n;
A_alpha = (ones(n, 1) * alpha' + alpha * ones(1, n))/2;
beta = 0.5 * (X0 - S - v * G + eta + A_alpha + z * eye(n));

% Update X1 and X2 variable
X1 = X1 + tau * sigma * (S + v * G + beta - A_alpha - z * eye(n) - X0);
X2 = X2 + tau * sigma * (eta - beta);

epsilon = trace(X0 * X1);
dual_value = k * z + sum(alpha) - v * costmax;

relative_gap = abs(epsilon - dual_value) / (1 + abs(epsilon) + abs(dual_value));

% compute constraint violation
% compute primal infeasibility
% eta_e1 = trace(X1) - k;
% eta_e2 = sum(X1) - ones(1, n);
% eta_e = sqrt(eta_e1^2 + norm(eta_e2)^2) / (1 + sqrt(k^2 + n));
eta_e = 0; % by our algorithm, the equality constraint always satisfy.
eta_i = abs(min(real(trace(G * X1) - costmax), 0)) / (1 + abs(costmax));

eta_P = max(eta_e, eta_i);

% compute dual infeasibility
eta_D = norm(S + v * G + beta - A_alpha - z * eye(n) - X0, 'fro') / (1 + sqrt(k));

% eta_C1 = abs(trace(X1 * S)) / (1 + norm(X1, 'fro') + norm(S, 'fro'));
% eta_C2 = abs(trace(X1 * beta)) / (1 + norm(X1, 'fro') + norm(beta, 'fro'));

eta = max(eta_D, eta_P);
if mod(i, p_iter) == 0 || eta <= eps
    fprintf('after %d iteration, epsilon is %f\n', i, epsilon)
    fprintf('after %d iteration, dual value is %f\n', i, -dual_value)
%     fprintf('primal equality violation is %f, inequality violation is %f\n', eta_e, eta_i);
    fprintf('the dual violation is %f; the primal violation is %f\n', eta_D, eta_P);
    fprintf('\n');
end


if eta <= eps
    fprintf('the multiplier value sigma is %f\n', sigma);
    break
end

end
