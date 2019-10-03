%%**********************************************************************
%% Overload operator 'plus / + '
%% 
%% SDPNAL+: 
%% Copyright (c) 2017 by
%% Yancheng Yuan , Kim-Chuan Toh, Defeng Sun and Xinyuan Zhao
%%**********************************************************************
function exp_obj = plus(obj1, obj2)
    if isa(obj1, 'var_symm')
        if obj1.block_no == -1
            error('Add the variable ''%s'' into the model first.', inputname(1));
        end
        info.exp_string = inputname(1);
        info.constr_dim.m = obj1.blkorg{2};
        info.constr_dim.n = obj1.blkorg{3};
        if isa(obj2, 'var_symm')
            if obj2.block_no == -1
                error('Add the variable ''%s'' into the model first.', inputname(2));
            end
            if ~strcmp(obj1.model.info.prob.name, obj2.model.info.prob.name)
                error('variables are not in the same model.');
            end
            if obj2.blkorg{2} ~= info.constr_dim.m || obj2.blkorg{3} ~= info.constr_dim.n
                error('Dimensions must agree .');
            end
            info.exp_string = strcat(info.exp_string, '+', inputname(2));
            info.constr_type = 'symmetric';
            info.Operator_Matrix = cell(obj1.model.info.prob.block, 1);
            info.active_block = [obj1.block_no];
            [idx_i,idx_j]=find(triu(ones(obj1.blkorg{2},obj1.blkorg{3}))>0);
            idx_temp = idx_i+obj1.blkorg{2}*(idx_j-1);
            dim_temp = 0.5*obj1.blkorg{2}*(obj1.blkorg{2}+1);
            matrix_temp = sparse(idx_temp,[1:1:dim_temp],2,obj1.blk{2},dim_temp);
            for i = 1:1:obj1.blkorg{2}
                idx1 = i+(i-1)*obj1.blkorg{2};
                idx2 = 0.5*i*(i+1);
                matrix_temp(idx1, idx2) = 1;
            end
            info.Operator_Matrix{obj1.block_no} = matrix_temp;
            if ismember(obj2.block_no, info.active_block)
                info.Operator_Matrix{obj2.block_no} = info.Operator_Matrix{obj2.block_no} + matrix_temp;
            else
                info.Operator_Matrix{obj2.block_no} = matrix_temp;
                info.active_block = union(info.active_block, obj2.block_no);
            end
            info.Constant = sparse(obj1.blkorg{2},obj1.blkorg{3});
            info.status = 1;
            info.model = obj1.model;
            exp_obj = expression(info);
            return;
        elseif isa(obj2, 'var_sdp')
            if obj2.block_no == -1
                error('Add the variable ''%s'' into the model first.', inputname(2));
            end
            if ~strcmp(obj1.model.info.prob.name, obj2.model.info.prob.name)
                error('variables are not in the same model.');
            end
            if obj1.blkorg{2} ~= obj2.blkorg{2}
                error('Dimensions must agree.');
            end
            info.exp_string = strcat(inputname(1), '+', inputname(2));
            info.constr_dim.m = obj1.blkorg{2};
            info.constr_dim.n = obj1.blkorg{3};
            info.constr_type = 'symmetric';
            info.Operator_Matrix = cell(obj1.model.info.prob.block, 1);
            info.active_block = [obj1.block_no];
            [idx_i,idx_j]=find(triu(ones(obj1.blkorg{2},obj1.blkorg{3}))>0);
            idx_temp = idx_i+obj1.blkorg{2}*(idx_j-1);
            dim_temp = 0.5*obj1.blkorg{2}*(obj1.blkorg{2}+1);
            matrix_temp = sparse(idx_temp,[1:1:dim_temp],2,obj1.blk{2},dim_temp);
            for i = 1:1:obj1.blkorg{2}
                idx1 = i+(i-1)*obj1.blkorg{2};
                idx2 = 0.5*i*(i+1);
                matrix_temp(idx1, idx2) = 1;
            end
            info.Operator_Matrix{obj1.block_no} = matrix_temp;
            matrix_temp =sqrt(2)*speye(0.5*obj2.blkorg{2}*(obj2.blkorg{2}+1));
            for i = 1:1:obj2.blkorg{2}
                block_no = 0.5*i*(i+1);
                matrix_temp(block_no, block_no) = 1;
            end
            if ismember(obj2.block_no, info.active_block)
                info.Operator_Matrix{obj2.block_no} = info.Operator_Matrix{obj2.block_no} + matrix_temp;
            else
                info.Operator_Matrix{obj2.block_no} = matrix_temp;
                info.active_block = union(info.active_block, obj2.block_no);
            end
            info.Constant = sparse(obj1.blkorg{2},obj1.blkorg{3});
            info.status = 1;
            info.model = obj1.model;
            exp_obj = expression(info);
        elseif isa(obj2, 'expression')
            if ~strcmp(obj1.model.info.prob.name, obj2.model.info.prob.name)
                error('variables are not in the same model.');
            end
            if ~strcmp(obj2.constr_type, 'symmetric')
                error('Cannot use ''+'' between symmetric and asymmetric variables.');
            end
            if info.constr_dim.m ~= obj2.constr_dim.m || info.constr_dim.n ~= info.constr_dim.n
                error('Dimensions must agree .');
            end
            info.exp_string = strcat(info.exp_string, '+', obj2.exp_string);
            info.constr_type = 'symmetric';
            info.Operator_Matrix = obj2.Operator_Matrix;
            info.active_block = obj2.active_block;
            [idx_i,idx_j]=find(triu(ones(obj1.blkorg{2},obj1.blkorg{3}))>0);
            idx_temp = idx_i+obj1.blkorg{2}*(idx_j-1);
            dim_temp = 0.5*obj1.blkorg{2}*(obj1.blkorg{2}+1);
            matrix_temp = sparse(idx_temp,[1:1:dim_temp],2,obj1.blk{2},dim_temp);
            for i = 1:1:obj1.blkorg{2}
                idx1 = i+(i-1)*obj1.blkorg{2};
                idx2 = 0.5*i*(i+1);
                matrix_temp(idx1, idx2) = 1;
            end
            if ismember(obj1.block_no, info.active_block)
                info.Operator_Matrix{obj1.block_no} = info.Operator_Matrix{obj1.block_no} + matrix_temp;
            else
                info.Operator_Matrix{obj1.block_no} =  matrix_temp;
                info.active_block = union(info.active_block, obj1.block_no);
            end
            info.Constant = obj2.Constant;
            info.status = 1;
            info.model = obj1.model;
            exp_obj = expression(info);
            return;
        elseif isa(obj2, 'var_nn') || isa(obj2, 'var_free')
            error('Cannot use ''+'' between symmetric and asymmetric variables.');
        elseif isa(obj2, 'double')
            [dim_m, dim_n] = size(obj2);
            if dim_m ~= obj1.blkorg{2} || dim_n ~= obj1.blkorg{3}
                error('Dimensions must agree.');
            end
            if ~isempty(inputname(2))
                info.exp_string = strcat(inputname(1), '+', inputname(2));
            elseif isscalar(obj2)
                info.exp_string = strcat(inputname(2), '+', num2str(obj2));
            else
                info.exp_string = strcat(inputname(1), '+ const');
            end
            info.constr_type = 'symmetric';
            info.Operator_Matrix = cell(obj1.model.info.prob.block, 1);
            info.active_block = [obj1.block_no];
            [idx_i,idx_j]=find(triu(ones(obj1.blkorg{2},obj1.blkorg{3}))>0);
            idx_temp = idx_i+obj1.blkorg{2}*(idx_j-1);
            dim_temp = 0.5*obj1.blkorg{2}*(obj1.blkorg{2}+1);
            matrix_temp = sparse(idx_temp,[1:1:dim_temp],2,obj1.blk{2},dim_temp);
            for i = 1:1:obj1.blkorg{2}
                idx1 = i+(i-1)*obj1.blkorg{2};
                idx2 = 0.5*i*(i+1);
                matrix_temp(idx1, idx2) = 1;
            end
            info.Operator_Matrix{obj1.block_no} = matrix_temp;
            info.Constant = 0.5*(obj2 + obj2');
            info.status = 1;
            info.model = obj1.model;
            exp_obj = expression(info);
            return;
        end
    elseif isa(obj1, 'double')
        [dim_m, dim_n] = size(obj1);
        if isa(obj2, 'var_symm')
            if obj2.block_no == -1
                error('Add the variable ''%s'' into the model first.', inputname(2));
            end
            if dim_m ~= obj2.blkorg{2} || dim_n ~= obj2.blkorg{3}
                error('Dimensions must agree.');
            end
            if ~isempty(inputname(1))
                info.exp_string = strcat(inputname(1), '+', inputname(2));
            elseif isscalar(obj1)
                info.exp_string = strcat(num2str(obj1), '+', inputname(2));
            else
                info.exp_string = strcat('const + ', inputname(2));
            end
            info.constr_dim.m = dim_m;
            info.constr_dim.n = dim_n;
            info.constr_type = 'symmetric';
            info.Operator_Matrix = cell(obj2.model.info.prob.block, 1);
            info.active_block = [obj2.block_no];
            [idx_i,idx_j]=find(triu(ones(obj2.blkorg{2},obj2.blkorg{3}))>0);
            idx_temp = idx_i+obj2.blkorg{2}*(idx_j-1);
            dim_temp = 0.5*obj2.blkorg{2}*(obj2.blkorg{2}+1);
            matrix_temp = sparse(idx_temp,[1:1:dim_temp],2,obj2.blk{2},dim_temp);
            for i = 1:1:obj2.blkorg{2}
                idx1 = i+(i-1)*obj2.blkorg{2};
                idx2 = 0.5*i*(i+1);
                matrix_temp(idx1, idx2) = 1;
            end
            info.Operator_Matrix{obj2.block_no} = matrix_temp;
            info.Constant = 0.5*(obj1 + obj1');
            info.status = 1;
            info.model = obj2.model;
            exp_obj = expression(info);
            return;
        end
    end
end
            