%%**********************************************************************
%% map_vec(X): Vectorization of symmetric variable X
%% X should be a declared symmetric variable. 
%% SDPNAL+: 
%% Copyright (c) 2017 by
%% Yancheng Yuan, Kim-Chuan Toh, Defeng Sun and Xinyuan Zhao
%%**********************************************************************

function exp_obj = map_vec(var_obj)
    if var_obj.block_no == -1
        error('Add the variable ''%s'' into the model first.', inputname(1));
    end
    info.exp_string = strcat('map_vec(', inputname(1),')');
    info.constr_dim.m = var_obj.blkorg{2}*var_obj.blkorg{3};
    info.constr_dim.n = 1;
    info.constr_type = 'vector';
    info.Operator_Matrix = cell(var_obj.model.info.prob.block, 1);
    %const = 1; %%do not use sqrt(2);
    [idx_i, idx_j] = find(ones(var_obj.blkorg{2}, var_obj.blkorg{3}));
    v_temp = (sqrt(2)/2)*ones(info.constr_dim.m, 1);
    v_temp(idx_i == idx_j) =1;
    idx_temp = 0.5*(max(idx_i, idx_j).*(max(idx_i, idx_j)-1)) + min(idx_i, idx_j);
    info.Operator_Matrix{var_obj.block_no} = sparse(idx_temp, 1:info.constr_dim.m, v_temp, 0.5*var_obj.blkorg{2}*(var_obj.blkorg{2}+1), info.constr_dim.m);
    info.active_block = [var_obj.block_no];
    info.Constant = sparse(info.constr_dim.m,1);
    info.status = 2;
    info.model = var_obj.model;
    exp_obj = expression(info);
end
%%**********************************************************************