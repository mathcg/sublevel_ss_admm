%%**********************************************************************
%% Overload operator 'uminus / - '
%% 
%% SDPNAL+: 
%% Copyright (c) 2017 by
%% Yancheng Yuan , Kim-Chuan Toh, Defeng Sun and Xinyuan Zhao
%%**********************************************************************
function exp_obj = uminus(var_obj)
    if var_obj.block_no == -1
        error('Add the variable ''%s'' into the model first.', inputname(1));
    end
    info.exp_string = strcat('-', inputname(1));
    info.Operator_Matrix = cell(var_obj.model.info.prob.block, 1);
    [idx_i,idx_j]=find(triu(ones(var_obj.blkorg{2},var_obj.blkorg{3}))>0);
    idx_temp = idx_i+var_obj.blkorg{2}*(idx_j-1);
    dim_temp = 0.5*var_obj.blkorg{2}*(var_obj.blkorg{2}+1);
    matrix_temp = sparse(idx_temp,[1:1:dim_temp],-2,var_obj.blk{2},dim_temp);
    for i = 1:1:var_obj.blkorg{2}
        idx1 = i+(i-1)*var_obj.blkorg{2};
        idx2 = 0.5*i*(i+1);
        matrix_temp(idx1, idx2) = -1;
    end
    info.Operator_Matrix{var_obj.block_no} = matrix_temp;
    info.constr_dim.m = var_obj.blkorg{2};
    info.constr_dim.n = var_obj.blkorg{3};
    info.constr_type = 'symmetric';
    info.active_block = [var_obj.block_no];
    info.Constant = sparse(var_obj.blkorg{2}, var_obj.blkorg{3});
    info.status = 1;
    info.model = var_obj.model;
    exp_obj = expression(info);
end