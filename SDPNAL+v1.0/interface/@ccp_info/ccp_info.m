%%**********************************************************************
%% class def : ccp_info
%% for inner purpose, store ccp model info for the solver.
%% SDPNAL+: 
%% Copyright (c) 2017 by
%% Yancheng Yuan, Kim-Chuan Toh, Defeng Sun and Xinyuan Zhao
%%**********************************************************************
classdef ccp_info < matlab.mixin.Copyable
    
    properties
        prob
        num_eqconstr
        num_ineqconstr
        issolved
        opt_solution
        dual_opt % new property to store dual opt
    end
    
    methods
        function ccp_obj = ccp_info(input_info)
            
            if isa(input_info, 'ccp_info')
                ccp_obj = input_info; %% redundant
            elseif ischar(input_info)
                prob_struct.name = input_info;
                prob_struct.block = 0;
                prob_struct.blk = {};
                prob_struct.At = {};
                prob_struct.b = [];
                prob_struct.L = {};
                prob_struct.U = {};
                prob_struct.Bt = {};
                prob_struct.l = [];
                prob_struct.u = [];
                prob_struct.varname = {};
                prob_struct.blkorg = {};
                prob_struct.C = {};
                prob_struct.min = 0;
                prob_struct.OPTIONS.tol = 1e-6;
                prob_struct.OPTIONS.maxiter = 1200;
                ccp_obj.prob = prob_struct;
                ccp_obj.num_eqconstr = 0;
                ccp_obj.num_ineqconstr = 0;
                ccp_obj.issolved = 0;
                ccp_obj.opt_solution = {};
                ccp_obj.dual_opt = [];
            else
                error('Invalid input.');
            end
        end
    end
end
                