%%**********************************************************************
%% class def for var_free
%% 
%% SDPNAL+: 
%% Copyright (c) 2017 by
%% Yancheng Yuan , Kim-Chuan Toh, Defeng Sun and Xinyuan Zhao
%%**********************************************************************

classdef var_free < matlab.mixin.Copyable
    %% Var -------- Class definition file
    % properties
    properties
        blk        % blk information
        blkorg  % blk organization
        L_Mat    % Lower Bound
        U_Mat   % Upper Bound
        block_no % index of the variable in model
        model
        
    end
    
    % Methods
    % Rewrite constructor 
    methods 
        function obj_var = var_free(m, n)
            obj_var.blkorg{1} = 'u';
            obj_var.blk{1} = 'u';
            if nargin == 0
                obj_var.blkorg{2} = 1;
                obj_var.blkorg{3} = 1;
                obj_var.blk{2} = 1;
            elseif nargin == 1
                if m >= 1
                    obj_var.blkorg{2} = floor(m);
                    obj_var.blkorg{3} = 1;
                    obj_var.blk{2} = floor(m);
                else
                    error('Invalid Input: Dimensions must be positive integer.\n');
                end
            else
                if m>=1 && n>=1
                    obj_var.blkorg{2} = floor(m);
                    obj_var.blkorg{3} = floor(n);
                    obj_var.blk{2} = obj_var.blkorg{2}*obj_var.blkorg{3};
                else
                    error('Invalid Input: Dimensions must be positive integer. \n');
                end
            end
            obj_var.L_Mat = -inf*ones(obj_var.blkorg{2}, obj_var.blkorg{3});
            obj_var.U_Mat = -obj_var.L_Mat;
            obj_var.block_no = -1;
        end
    end
end
        