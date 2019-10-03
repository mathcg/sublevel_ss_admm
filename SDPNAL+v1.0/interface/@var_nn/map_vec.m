%%**********************************************************************
%% map_vec(X): vectorization of variable X
%% X is a declared variable. 
%% SDPNAL+: 
%% Copyright (c) 2017 by
%% Yancheng Yuan, Kim-Chuan Toh, Defeng Sun and Xinyuan Zhao
%%**********************************************************************

function exp_obj = map_vec(var_obj)
    if var_obj.block_no == -1
        error('Add the variable ''%s'' into the model first.', inputname(1));
    end
    info.exp_string = strcat('map_vec(', inputname(1),')');
    info.constr_dim.m = var_obj.blk{2};
    info.constr_dim.n = 1;
    info.constr_type = 'vector';
    info.Operator_Matrix = cell(var_obj.model.info.prob.block, 1);
    info.Operator_Matrix{var_obj.block_no} = speye(var_obj.blk{2});
    info.active_block = [var_obj.block_no];
    info.Constant = sparse(var_obj.blk{2},1);
    info.status = 2;
    info.model = var_obj.model;
    exp_obj = expression(info);
end
%%**********************************************************************