function [X, err, out] = solve_sdp_err(X0, G, k, costmax, admm)
%
% Solves the SDP problem:
%       min <X0,X> s.t. <-G,X> <= costmax, trace(X) = K, X*1=1, X>=0,X semi-positive definite.
% X0(n,n) = reference clustering
% G(n,n) = centered Gram matrix
% k 	  = number of clusters
% costmax = a cap on the cost, typically >= cost( X0 );
% 	    for feasibility costmax >= coststar
% admm = whether to admmplus alone or not
% X	  = SDP solution (not necessarily integer)
% err	  = trace(X0*X);
% out	  = structure containing everything else, for debugging


tic;

n = size(G, 1);

% generate equality constraints

meq = n+1;   % number equality constraints
n22 = n*(n+1)/2;
At = sparse([],[],[],n22,meq);

blka{1,1} = 's';
blka{1,2} = n;
At(:,1) = svec(blka, speye(n));

for i = 1:n;    % constraints multiplied by k
    ssa = ones(2*n-1,1);
    iia( 1:n ) = i*ones(n,1);
    iia( n+(1:n-1)) =  [ (1:i-1)'; (i+1:n)'];
    jja( 1:n ) = (1:n)';
    jja( n+(1:n-1)) =  i;
    ssa( i ) = 2;
    At(:,i+1) = svec( blka, sparse( iia, jja, ssa, n, n ));
end;

beq = [k; 2*ones(n,1)];  % because the A^i matrices are doubled
L = 0;

% The extra inequality constraint
Bt = svec( blka, -G );
line = -inf;
uine = costmax;

% set up for sdpnal

blk{1,1} = 's';
blk{1,2} = n;
Ccel{1} = X0;
Atcel{1} = At;
Btcel{1} = Bt;

opts.printlevel = 1;
opts.tol = 1e-4;
opts.maxiter=100000;

if admm
    [err,X,s,y,S,Z,y2,v,info,runhist] = ...
        admmplus(blk,Atcel,Ccel,beq,L,[],Btcel,line,uine,opts);
else
    [err,X,s,y,S,Z,y2,v,info,runhist] = ...
        sdpnalplus(blk,Atcel,Ccel,beq,L,[],Btcel,line,uine,opts);
end

X = X{1};
err = err(1);
out.s = s;
out.y =y;
out.Z=Z;
out.S=S;
out.y2=y2;
out.At = At;
out.Bt = Bt;
out.beq = beq;
out.Ccel = Ccel;
out.L = L;
out.runhist = runhist;
out.info = info;



