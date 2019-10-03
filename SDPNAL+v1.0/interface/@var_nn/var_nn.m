%%**********************************************************************
%% class def of var_nn
%%
%% SDPNAL+: 
%% Copyright (c) 2017 by
%% Yancheng Yuan , Kim-Chuan Toh, Defeng Sun and Xinyuan Zhao
%%**********************************************************************

classdef var_nn < matlab.mixin.Copyable
    
    properties
        blk
        blkorg
        L_Mat
        U_Mat
        block_no
        model
    end
    
    methods
        function var_obj = var_nn(m, n)
            if nargin == 0
                var_obj = nnvar(1,1);
            elseif nargin == 1
                var_obj.blk{1} = 'l';
                var_obj.blk{2} = m;
                var_obj.blkorg{1} = 'l';
                var_obj.blkorg{2} = m;
                var_obj.blkorg{3} = 1;
                var_obj.L_Mat = sparse(m, 1);
                var_obj.U_Mat = inf*ones(m, 1);
                var_obj.block_no = -1;
                var_obj.model = [];
            elseif nargin == 2
                var_obj.blk{1} = 'l';
                var_obj.blk{2} = m*n;
                var_obj.blkorg{1} = 'l';
                var_obj.blkorg{2} = m;
                var_obj.blkorg{3} = n;
                var_obj.L_Mat = sparse(m, n);
                var_obj.U_Mat = inf*ones(m, n);
                var_obj.block_no = -1;
                var_obj.model = [];
            end
        end
    end
end
                