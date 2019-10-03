%%**********************************************************************
%% map_svec(X): Symmetric vectorization of X
%% X is a declared symmetric variable. 
%% SDPNAL+: 
%% Copyright (c) 2017 by
%% Yancheng Yuan, Kim-Chuan Toh, Defeng Sun and Xinyuan Zhao
%%**********************************************************************

function exp_obj = map_svec(var_obj)
    if var_obj.block_no == -1
        error('Add the variable ''%s'' into the model first.', inputname(1));
    end
    info.exp_string = strcat('map_svec(', inputname(1),')');
    dim_temp = 0.5*var_obj.blkorg{2}*(var_obj.blkorg{2}+1);
    info.constr_dim.m = dim_temp;
    info.constr_dim.n = 1;
    info.constr_type = 'vector';
    info.Operator_Matrix = cell(var_obj.model.info.prob.block, 1);
    [idx_i, idx_j] = find(triu(ones(var_obj.blkorg{2}, var_obj.blkorg{3}))>0);
    value_temp = sqrt(2)*ones(dim_temp,1); %%important to use sqrt(2)
    value_temp(idx_i == idx_j) = 1;
    idx_temp = idx_i + var_obj.blkorg{2}*(idx_j - 1);
    info.Operator_Matrix{var_obj.block_no} = sparse(idx_temp,1:1:dim_temp,value_temp,var_obj.blk{2},dim_temp);
    info.active_block = [var_obj.block_no];
    info.Constant = sparse(info.constr_dim.m,1);
    info.status = 2;
    info.model = var_obj.model;
    exp_obj = expression(info);
end
%%**********************************************************************
