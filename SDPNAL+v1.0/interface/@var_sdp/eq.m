%%**********************************************************************
%% Overload operator 'eq/=='
%%
%% SDPNAL+: 
%% Copyright (c) 2017 by
%% Yancheng Yuan , Kim-Chuan Toh, Defeng Sun and Xinyuan Zhao
%%**********************************************************************

function constr_obj = eq(obj1, obj2)
    if isa(obj1, 'var_sdp')
        if obj1.block_no == -1
             error('Add the variable ''%s'' into the model first.', inputname(1));
        end
        if isa(obj2, 'double')
            warning('Assign value to a variable.');
            if isscalar(obj2)
                info.constr_string = strcat(inputname(1), '==', num2str(obj2));
                info.symmetric_constr = 1;
                info.constr_type = 'affine_constr';
                info.operator_type = '==';
                info.Operator_Matrix = cell(obj1.model.info.prob.block , 1);
                matrix_temp = sqrt(2)*speye(0.5*obj1.blk{2}*(obj1.blk{2}+1));
                for i = 1:1:obj1.blk{2}
                    idx = 0.5*i*(i+1);
                    matrix_temp(idx, idx) = 1;
                end
                info.Operator_Matrix{obj1.block_no} = matrix_temp;
                info.active_block = [obj1.block_no];
                info.Constant = obj2*ones(obj1.blkorg{2}, obj1.blkorg{3});
                info.num_constr = 0.5*obj1.blk{2}*(obj1.blk{2}+1);
                constr_obj = constraint(info);
                return;
            else
                [dim_m, dim_n] = size(obj2);
                if dim_m ~= obj1.blkorg{2} || dim_n ~= obj1.blkorg{3}
                    error('Dimension must agree.');
                end
                info.constr_string = strcat(inputname(1), '==', inputname(2));
                info.symmetric_constr = 1;
                info.constr_type = 'affine_constr';
                info.operator_type = '==';
                info.Operator_Matrix = cell(obj1.model.info.prob.block , 1);
                matrix_temp = sqrt(2)*speye(0.5*obj1.blk{2}*(obj1.blk{2}+1));
                for i = 1:1:obj1.blk{2}
                    idx = 0.5*i*(i+1);
                    matrix_temp(idx, idx) = 1;
                end
                info.Operator_Matrix{obj1.block_no} = matrix_temp;
                info.active_block = [obj1.block_no];
                info.Constant = 0.5*(obj2 + obj2');
                info.num_constr = 0.5*obj1.blk{2}*(obj1.blk{2}+1);
                constr_obj = constraint(info);
                return;
            end
        elseif isa(obj2, 'expression')
            if ~strcmp(obj1.model.info.prob.name, obj2.model.info.prob.name)
                error('variables are not in the same model.');
            end
            if obj1.blkorg{2} ~= obj2.constr_dim.m || obj1.blkorg{3} ~= obj2.constr_dim.n
                error('Dimensions must agree.');
            end
            if strcmp(obj2.constr_type, 'vector')
                error('Cannot use ''=='' between symmetric and asymmetric variables.');
            end
            info.constr_string = strcat(inputname(1), '==', obj2.exp_string);
            info.symmetric_constr = 1;
            info.constr_type = 'affine_constr';
            info.operator_type = '==';
            info.Operator_Matrix = obj2.Operator_Matrix;
            info.active_block = obj2.active_block;
            matrix_temp = sqrt(2)*speye(0.5*obj1.blkorg{2}*(obj1.blkorg{2}+1));
            for i = 1:1:obj1.blkorg{2}
                idx = 0.5*i*(i+1);
                matrix_temp(idx, idx) = 1;
            end
            if ismember(obj1.block_no, info.active_block)
                info.Operator_Matrix{obj1.block_no} = info.Operator_Matrix{obj1.block_no} - matrix_temp;
            else
                info.Operator_Matrix{obj1.block_no} = -matrix_temp;
                info.active_block = union(info.active_block, obj1.block_no);
            end
            info.Constant = -obj2.Constant;
            info.num_constr = 0.5*obj1.blk{2}*(obj1.blk{2}+1);
            constr_obj = constraint(info);
            return;
        elseif isa(obj2, 'var_nn')
            error('Cannot use ''=='' between symmetric and asymmetric variables.');
        elseif isa(obj2, 'var_sdp')
            if obj2.block_no == -1
                error('Add the variable ''%s'' into the model first.', inputname(2));
            end
            if ~strcmp(obj1.model.info.prob.name, obj2.model.info.prob.name)
                error('variables are not in the same model.');
            end
            if obj1.blkorg{2} ~= obj2.blkorg{2} || obj1.blkorg{3} ~= obj2.blkorg{3}
                error('Dimensions must agree.');
            end
            info.constr_string = strcat(inputname(1), '==', inputname(2));
            info.symmetric_constr = 1;
            info.constr_type = 'affine_constr';
            info.operator_type = '==';
            info.Operator_Matrix = cell(obj1.model.info.prob.block, 1);
            matrix_temp = sqrt(2)*speye(0.5*obj1.blkorg{2}*(obj1.blkorg{2}+1));
            for i = 1:1:obj1.blkorg{2}
                idx = 0.5*i*(i+1);
                matrix_temp(idx, idx) = 1;
            end
            info.Operator_Matrix{obj1.block_no} = matrix_temp;
            info.active_block = [obj1.block_no];
            if ismember(obj2.block_no, info.active_block)
                warning(strcat('affine constraint: ', info.constr_string, ' is not necessary.'));
                dim = 0.5*obj1.blkorg{2}*(obj1.blkorg{2}+1);
                info.Operator_Matrix{obj1.block_no} = sparse(dim, dim);
            else
                info.Operator_Matrix{obj2.block_no} = -matrix_temp;
                info.active_block = union(info.active_block, obj2.block_no);
            end
            info.Constant = sparse(obj1.blkorg{2}, obj2.blkorg{3});
            info.num_constr = 0.5*obj1.blk{2}*(obj1.blk{2}+1);
            constr_obj = constraint(info);
            return;
        elseif isa(obj2, 'var_symm')
            if obj2.block_no == -1
                error('Add the variable ''%s'' into the model first.', inputname(2));
            end
            if ~strcmp(obj1.model.info.prob.name, obj2.model.info.prob.name)
                error('variables are not in the same model.');
            end
            if obj1.blkorg{2} ~= obj2.blkorg{2} || obj1.blkorg{3} ~= obj2.blkorg{3}
                error('Dimensions must agree.');
            end
            info.constr_string = strcat(inputname(1), '==', inputname(2));
            info.symmetric_constr = 1;
            info.constr_type = 'affine_constr';
            info.operator_type = '==';
            info.Operator_Matrix = cell(obj1.model.info.prob.block, 1);
            dim_temp = 0.5*obj1.blkorg{2}*(obj1.blkorg{2}+1);
            matrix_temp1 = sqrt(2)*speye(dim_temp);
            [idx_i,idx_j]=find(triu(ones(obj2.blkorg{2},obj2.blkorg{3}))>0);
            idx_temp = idx_i+obj2.blkorg{2}*(idx_j-1);
            matrix_temp2 = sparse(idx_temp,[1:1:dim_temp],2,obj2.blk{2},dim_temp);
            for i = 1:1:obj1.blkorg{2}
                idx1 = i+(i-1)*obj1.blkorg{2};
                idx2 = 0.5*i*(i+1);
                matrix_temp1(idx2, idx2) = 1;
                matrix_temp2(idx1, idx2) = 1;
            end
            info.Operator_Matrix{obj1.block_no} = matrix_temp1;
            info.active_block = [obj1.block_no];
            if ismember(obj2.block_no, info.active_block)
                info.Operator_Matrix{obj2.block_no} = info.Operator_Matrix{obj2.block_no} - matrix_temp2;
            else
                info.Operator_Matrix{obj2.block_no} = -matrix_temp2;
                info.active_block = union(info.active_block, obj2.block_no);
            end
            info.Constant = sparse(obj1.blkorg{2}, obj2.blkorg{3});
            info.num_constr = 0.5*obj1.blk{2}*(obj1.blk{2}+1);
            constr_obj = constraint(info);
            return;
        elseif isa(obj2, 'var_free')
            error('Cannot use ''=='' between symmetric and asymmetric variables.');
        end
    elseif isa(obj1, 'double')
        warning('Assign value to variable.');
        if isscalar(obj1)
            if isa(obj2, 'var_sdp')
                if obj2.block_no == -1
                    error('Add the variable ''%s'' into the model first.', inputname(2));
                end
                info.constr_string = strcat(num2str(obj1), '==', inputname(2));
                info.symmetric_constr = 1;
                info.constr_type = 'affine_constr';
                info.operator_type = '==';
                info.Operator_Matrix = cell(obj2.model.info.prob.block, 1);
                matrix_temp = sqrt(2)*speye(0.5*obj2.blk{2}*(obj2.blk{2}+1));
                for i = 1:1:obj2.blk{2}
                    idx = 0.5*i*(i+1);
                    matrix_temp(idx, idx) = 1;
                end
                info.Operator_Matrix{obj2.block_no} = matrix_temp;
                info.active_block = [obj2.block_no];
                info.Constant = obj1*ones(obj2.blkorg{2}, obj2.blkorg{3});
                info.num_constr = 0.5*obj2.blk{2}*(obj2.blk{2}+1);
                constr_obj = constraint(info);
                return;
            end
        else
            [dim_m, dim_n] = size(obj1);
            if isa(obj2, 'var_sdp')
                if obj2.block_no == -1
                    error('Add the variable ''%s'' into the model first.', inputname(2));
                end
                if dim_m ~= obj2.blkorg{2}|| dim_n ~= obj2.blkorg{3}
                    error('Dimension must agree.');
                end
                info.constr_string = strcat(inputname(1), '==', inputname(2));
                info.symmetric_constr = 1;
                info.constr_type = 'affine_constr';
                info.operator_type = '==';
                info.Operator_Matrix = cell(obj2.model.info.prob.block, 1);
                matrix_temp = sqrt(2)*speye(0.5*obj2.blk{2}*(obj2.blk{2}+1));
                for i = 1:1:obj2.blk{2}
                    idx = 0.5*i*(i+1);
                    matrix_temp(idx, idx) = 1;
                end
                info.Operator_Matrix{obj2.block_no} = matrix_temp;
                info.active_block = [obj2.block_no];
                info.Constant = 0.5*(obj1+obj1');
                info.num_constr = 0.5*obj2.blk{2}*(obj2.blk{2}+1);
                constr_obj = constraint(info);
                return;
            end
        end
    end
end
            