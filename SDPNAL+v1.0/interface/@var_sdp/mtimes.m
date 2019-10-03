%%**********************************************************************
%% Overload operator 'mtimes/ *'
%%
%% SDPNAL+: 
%% Copyright (c) 2017 by
%% Yancheng Yuan , Kim-Chuan Toh, Defeng Sun and Xinyuan Zhao
%%**********************************************************************

function exp_obj = mtimes(A_mat, var_obj)
    if isa(A_mat, 'double') && isscalar(A_mat)
        if isa(var_obj, 'var_sdp')
            if var_obj.block_no == -1
                error('Add the variable ''%s'' into the model first.', inputname(2));
            end
            info.exp_string = strcat(num2str(A_mat), '*', inputname(2));
            info.constr_dim.m = var_obj.blkorg{2};
            info.constr_dim.n = var_obj.blkorg{3};
            info.constr_type = 'symmetric';
            info.Operator_Matrix = cell(var_obj.model.info.prob.block, 1);
            matrix_temp = (A_mat*sqrt(2))*speye(0.5*info.constr_dim.m*(info.constr_dim.m+1));
            for i = 1:1:info.constr_dim.m
                idx = 0.5*i*(i+1);
                matrix_temp(idx, idx) = A_mat;
            end
            info.Operator_Matrix{var_obj.block_no} = matrix_temp;
            info.active_block = [var_obj.block_no];
            info.Constant = sparse(var_obj.blkorg{2}, var_obj.blkorg{3});
            info.status = 1;
            info.model = var_obj.model;
            exp_obj = expression(info);
            return;
        end
    elseif iscell(A_mat)
        if isa(var_obj, 'var_sdp')
            if var_obj.block_no == -1
                error('Add the variable ''%s'' into the model first.', inputname(2));
            end
            num_constr = length(A_mat);
            info.exp_string = strcat(inputname(1), '*', inputname(2));
            info.constr_dim.m = num_constr;
            info.constr_dim.n = 1;
            info.constr_type = 'vector';
            info.Operator_Matrix = cell(var_obj.model.info.prob.block, 1);
            matrix_temp = [];
            for i = 1:1:num_constr
                matrix_temp = cat(2,matrix_temp,svec(var_obj.blk, 0.5*(A_mat{i}+A_mat{i}'), 1));
            end
            info.Operator_Matrix{var_obj.block_no} = matrix_temp;
            info.active_block = [var_obj.block_no];
            info.Constant = sparse(info.constr_dim.m, info.constr_dim.n);
            info.status = 1;
            info.model = var_obj.model;
            exp_obj = expression(info);
            return;
        end
    elseif isa(A_mat, 'double') % is a matrix
        error('Linear map for matrix variable must be a scalar or cell.');
    else
        error('Linear Operator A for sdpvar must be a scalar, matrix or cell.');
    end
end
        