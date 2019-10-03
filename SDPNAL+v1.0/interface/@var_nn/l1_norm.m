%%**********************************************************************
%% l1_norm(X): the l1 norm of X
%% X is a declared variable. 
%% SDPNAL+: 
%% Copyright (c) 2017 by
%% Yancheng Yuan , Kim-Chuan Toh, Defeng Sun and Xinyuan Zhao
%%**********************************************************************

function exp_obj = l1_norm(var_obj)
    if var_obj.block_no == -1
        error('Add the variable ''%s'' into the model first.', inputname(1));
    end
    % Since X is nonnegative
    exp_obj = sum(var_obj);
    exp_obj.exp_string = strcat('l1_norm(', inputname(1), ')');
end