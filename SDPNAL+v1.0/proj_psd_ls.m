function [ v, X_psd ] = proj_psd_ls(isReal, X, t )
% Updated Sept 2012. The restriction to rank K "Kignore" has not been done yet
% (that is nonconvex)
persistent oldRank
persistent nCalls
persistent V
if nargin == 0, oldRank = []; v = nCalls; nCalls = []; V=[]; return; end
if isempty(nCalls), nCalls = 0; end
SP  = issparse(X);

n = size(X, 1);
X_psd = zeros(n);

if nargin > 2 && t > 0,
	v = 0;
    if isempty(oldRank), K = 10;
    else, K = oldRank + 2;
    end

    [M,N]   = size(X);
    EIG_TOL         = 1e-10;
    ok = false;
    opts = [];
    opts.tol = 1e-10;
    if isreal(X)
        opts.issym = true;
        SIGMA       = 'LA';
    else
        SIGMA       = 'LR'; % largest real part
    end
    X = (X+X')/2;
    if isReal, X = real(X); end
    
    oldRank = 0; % reset value of oldRank to successivly perform eigen-decomposition
    
    while ~ok
        K = min( [K,N] );
        if K > N/2 || K > N-2 || N < 20
            [V,D] = eig(full((X+X')/2));
            ok = true;
        else
            if ~issymmetric(X)
                fprintf('X not symmetric')
            end
            [V,D] = eigs( X, K, SIGMA, opts );
            ok = (min(real(diag(D))) < EIG_TOL) || ( K == N );
        end
        if ok, break; end
%         opts.v0     = V(:,1); % starting vector

        % if not yet finished, update K and minus the large eigenvalues
        % obtained so far
        K = 2*K;
        D   = real(diag(D));
        oldRank = oldRank + length(find( D > EIG_TOL ));
        
        tt = D > EIG_TOL;
        V  = bsxfun(@times,V(:,tt),sqrt(D(tt,:))');
        temp_V = V * V';
        X = X - temp_V;
        X_psd = X_psd + temp_V;
        
%         fprintf('Increasing K from %d to %d\n', K/2,K );
        if K > 10
            opts.tol = 1e-6;
        end
        if K > 40
            opts.tol = 1e-4;
        end
        if K > 100
            opts.tol = 1e-3;
        end
    end
    D   = real( diag(D) );
    oldRank = oldRank + length(find( D > EIG_TOL ));

    tt = D > EIG_TOL;
    V  = bsxfun(@times,V(:,tt),sqrt(D(tt,:))');
    X_psd = X_psd + V * V';
    if SP, X = sparse(X); end
else
    opts.tol = 1e-10;
    if isreal(X)
        opts.issym = true;
        SIGMA       = 'SA';
    else
        SIGMA       = 'SR'; % smallest real part
    end
    K = 1; % we only want the smallest
    X = full(X+X'); % divide by 2 later
    if isReal, X = real(X); end
    d = eigs(X, K, SIGMA, opts );
    d = real(d)/2;
    
    if d < -10*eps
        v = Inf;
    else
    	v = 0;
    end
end