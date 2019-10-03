%%**********************************************************************
%% map_svec(X): Symmetric vectorization of symmetric variable X
%% X should be a declared symmetric variable. 
%% SDPNAL+: 
%% Copyright (c) 2017 by
%% Yancheng Yuan, Kim-Chuan Toh, Defeng Sun and Xinyuan Zhao
%%**********************************************************************

function exp_obj = map_svec(var_obj)
    if var_obj.block_no == -1
        error('Add the variable ''%s'' into the model first.', inputname(1));
    end
    info.exp_string = strcat('map_svec(', inputname(1),')');
    info.constr_dim.m = 0.5*var_obj.blkorg{2}*(var_obj.blkorg{2}+1);
    info.constr_dim.n = 1;
    info.constr_type = 'vector';
    info.Operator_Matrix = cell(var_obj.model.info.prob.block, 1);
    const = 1; %%do not use sqrt(2); 
    info.Operator_Matrix{var_obj.block_no} = const*speye(0.5*var_obj.blkorg{2}*(var_obj.blkorg{2}+1));
    for i = 1:1:var_obj.blkorg{2}
        idx = 0.5*i*(i+1);
        info.Operator_Matrix{var_obj.block_no}(idx, idx)=1;
    end
    info.active_block = [var_obj.block_no];
    info.Constant = sparse(info.constr_dim.m,1);
    info.status = 2;
    info.model = var_obj.model;
    exp_obj = expression(info);
end
%%**********************************************************************