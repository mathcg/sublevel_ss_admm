%%**********************************************************************
%% Overload operator 'mtimes/ *'
%%
%% SDPNAL+: 
%% Copyright (c) 2017 by
%% Yancheng Yuan , Kim-Chuan Toh, Defeng Sun and Xinyuan Zhao
%%**********************************************************************

function exp_obj = mtimes(A_mat, var_obj)
    if isa(A_mat, 'double')
        if isscalar(A_mat)
            if isa(var_obj, 'var_nn')
                if var_obj.block_no == -1
                    error('Add the variable ''%s'' into the model first.', inputname(2));
                end
                info.exp_string = strcat(num2str(A_mat), '*', inputname(2));
                info.constr_dim.m = var_obj.blkorg{2};
                info.constr_dim.n = var_obj.blkorg{3};
                info.constr_type = 'vector';
                info.Operator_Matrix = cell(var_obj.model.info.prob.block, 1);
                info.Operator_Matrix{var_obj.block_no} = A_mat*speye(var_obj.blk{2});
                info.active_block = [var_obj.block_no];
                info.Constant = sparse(var_obj.blkorg{2}, var_obj.blkorg{3});
                info.status = 1;
                info.model = var_obj.model;
                exp_obj = expression(info);
                return;
            else
                error('Error using ''*'': variable must be on the right.');
            end
        else
            if isa(var_obj, 'var_nn')
                if var_obj.block_no == -1
                    error('Add the variable ''%s'' into the model first.', inputname(2));
                end
                if var_obj.blkorg{3} > 1
                    error('Linear Map should be a cell for matrix variable.');
                end
                [dim_m, dim_n] = size(A_mat);
                if dim_n ~= var_obj.blkorg{2}
                    error('Dimension must agree.');
                end
                info.exp_string = strcat(inputname(1), '*', inputname(2));
                info.constr_dim.m = dim_m;
                info.constr_dim.n = 1;
                info.constr_type = 'vector';
                info.Operator_Matrix = cell(var_obj.model.info.prob.block, 1);
                info.Operator_Matrix{var_obj.block_no} = A_mat';
                info.active_block = [var_obj.block_no];
                %%info.Constant = sparse(var_obj.blkorg{2},var_obj.blkorg{3});%% error      
                info.Constant = sparse(info.constr_dim.m,info.constr_dim.n); %%TKC
                info.status = 1;
                info.model = var_obj.model;
                exp_obj = expression(info);
                return;
            end
        end
    elseif iscell(A_mat)
        if isa(var_obj, 'var_nn')
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
                [dim_m, dim_n] = size(A_mat{i});
                if dim_m ~= var_obj.blkorg{2} || dim_n ~= var_obj.blkorg{3}
                    error('Dimensions of ''%s {%s}'' and ''%s'' disagree.', inputname(1), num2str(i), inputname(2));
                end
                %%matrix_temp = cat(2, matrix_temp, vec(A_mat{i})); %%old
                matrix_temp = cat(2, matrix_temp, reshape(A_mat{i}, var_obj.blk{2},1));  
            end
            info.Operator_Matrix{var_obj.block_no} = matrix_temp;
            info.active_block = [var_obj.block_no];
            info.Constant = sparse(info.constr_dim.m, info.constr_dim.n);
            info.status = 1;
            info.model = var_obj.model;
            exp_obj = expression(info);
            return;
        end
    else
        error('Linear Operator must be a scalar, matrix or cell.');
    end
end
        