%%**********************************************************************
%% class def of var_symm. 
%% 
%% SDPNAL+: 
%% Copyright (c) 2017 by
%% Yancheng Yuan , Kim-Chuan Toh, Defeng Sun and Xinyuan Zhao
%%**********************************************************************
classdef var_symm < matlab.mixin.Copyable
    
    properties
        blk
        blkorg
        L_Mat
        U_Mat
        block_no
        model
    end
    
    methods
        function var_obj = var_symm(m, n)
            if nargin < 2
               error('Not enough arguments for ''symmvar(n, n)''.');
            elseif nargin == 2
                if m == n
                    var_obj.blk{1} = 'symm';
                    var_obj.blk{2} = m*n;
                    var_obj.blkorg{1} = 'symm';
                    var_obj.blkorg{2} = m;
                    var_obj.blkorg{3} = n;
                    var_obj.L_Mat = -inf*ones(m, n);
                    var_obj.U_Mat = inf*ones(m, n);
                    var_obj.block_no = -1;
                    var_obj.model = [];
                else
                    error('Symmetric variable must be square matrix.');
                end
            end
        end
    end
end
       