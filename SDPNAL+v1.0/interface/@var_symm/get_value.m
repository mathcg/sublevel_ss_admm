%%**********************************************************************
%% get_value(X): get the solution of X
%% X is a declared variable. 
%% SDPNAL+: 
%% Copyright (c) 2017 by
%% Yancheng Yuan , Kim-Chuan Toh, Defeng Sun and Xinyuan Zhao
%%**********************************************************************

function sol = get_value(var_obj)
    if var_obj.block_no == -1
        error('Add the variable ''%s'' into the model first.', inputname(1));
    end
    if var_obj.model.info.issolved == 0
        error('Solve the model first.');
    end
    sol = var_obj.model.info.opt_solution{var_obj.block_no};
end