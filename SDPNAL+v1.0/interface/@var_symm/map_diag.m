%%**********************************************************************
%% map_diag(X): Extract the main diagonals of X.
%% X is a declared variable. 
%% SDPNAL+: 
%% Copyright (c) 2017 by
%% Yancheng Yuan , Kim-Chuan Toh, Defeng Sun and Xinyuan Zhao
%%**********************************************************************

function exp_obj = map_diag(var_obj)
    if var_obj.block_no == -1
        error('Add the variable ''%s'' into the model first.', inputname(1));
    end
    info.exp_string = strcat('map_diag(', inputname(1),')');
    info.Operator_Matrix = cell(var_obj.model.info.prob.block, 1);
    idx_j_temp = 1:1:var_obj.blkorg{2};
    idx_i_temp = idx_j_temp + var_obj.blkorg{2}*(idx_j_temp - 1);
    info.Operator_Matrix{var_obj.block_no} = sparse(idx_i_temp, idx_j_temp, 1, var_obj.blk{2},var_obj.blkorg{2});
    info.constr_dim.m = var_obj.blkorg{2};
    info.constr_dim.n = 1;
    info.constr_type = 'vector';
    info.active_block = [var_obj.block_no];
    info.Constant = sparse(var_obj.blkorg{2}, 1);
    info.status = 2;
    info.model = var_obj.model;
    exp_obj = expression(info);
end