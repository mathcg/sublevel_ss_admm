%%**********************************************************************
%% Overload operator 'ge / >='
%% X is a declared free variable
%% SDPNAL+: 
%% Copyright (c) 2017 by
%% Yancheng Yuan , Kim-Chuan Toh, Defeng Sun and Xinyuan Zhao
%%**********************************************************************

function constr_obj = ge(obj1, obj2)
    if isa(obj1, 'var_free')
        if obj1.block_no == -1
             error('Add the variable ''%s'' into the model first.', inputname(1));
        end
        if isa(obj2, 'double')
            if isscalar(obj2) % X >= a
                info.constr_string = strcat(inputname(1), '>=', num2str(obj2));
                info.symmetric_constr = 0;
                info.constr_type = 'lower_bound';
                info.operator_type = '>=';
                info.Operator_Matrix = cell(obj1.model.info.prob.block , 1);
                % bound constraint no need initialize At/Bt
                info.active_block = [obj1.block_no];
                info.Constant = obj2*ones(obj1.blkorg{2}, obj1.blkorg{3});
                info.num_constr = obj1.blk{2};
                constr_obj = constraint(info);
                return;
            else
                [dim_m, dim_n] = size(obj2);
                if dim_m ~= obj1.blkorg{2} || dim_n ~= obj1.blkorg{3}
                    error('Dimension must agree.');
                end
                info.constr_string = strcat(inputname(1), '>=', inputname(2));
                info.symmetric_constr = 0;
                info.constr_type = 'lower_bound';
                info.operator_type = '>=';
                info.Operator_Matrix = cell(obj1.model.info.prob.block , 1);
                info.active_block = [obj1.block_no];
                info.Constant = obj2;
                info.num_constr = obj1.blk{2};
                constr_obj = constraint(info);
                return;
            end
        elseif isa(obj2, 'expression')
            if ~strcmp(obj1.model.info.prob.name, obj2.model.info.prob.name)
                error('variables are not in the same model.');
            end
            if obj1.blkorg{2} ~= obj2.constr_dim.m || obj1.blkorg{3} ~= obj2.constr_dim.n
                error('Dimension must agree.');
            end
            if ~strcmp(obj2.constr_type, 'vector')
                error('Cannot use ''>='' between symmetric and asymmetric variables.');
            end
            info.constr_string = strcat(inputname(1), '>=', obj2.exp_string);
            info.symmetric_constr = 0;
            info.constr_type = 'affine_constr';
            info.operator_type = '>=';
            info.Operator_Matrix = cell(obj1.model.info.prob.block, 1);
            info.Operator_Matrix{obj1.block_no} = speye(obj1.blk{2});
            info.active_block = [obj1.block_no];
            len_temp = length(obj2.active_block);
            for i = 1:1:len_temp
                if ismember(obj2.active_block(i), info.active_block)
                    info.Operator_Matrix{obj2.active_block(i)} = info.Operator_Matrix{obj2.active_block(i)} - obj2.Operator_Matrix{obj2.active_block(i)};
                else
                    info.Operator_Matrix{obj2.active_block(i)} = -obj2.Operator_Matrix{obj2.active_block(i)};
                    info.active_block = union(info.active_block, obj2.active_block(i));
                end
            end
            info.Constant = obj2.Constant;
            info.num_constr = obj1.blk{2};
            constr_obj = constraint(info);
            return;
        elseif isa(obj2, 'var_sdp')|| isa(obj2, 'var_symm')
            error('Cannot use ''>='' between symmetric and asymmetric variables.');
        elseif isa(obj2, 'var_nn')
            if obj2.block_no == -1
                error('Add the variable ''%s'' into the model first.', inputname(2));
            end
            if ~strcmp(obj1.model.info.prob.name, obj2.model.info.prob.name)
                error('variables are not in the same model.');
            end
            if obj1.blkorg{2} ~= obj2.blkorg{2} || obj1.blkorg{3} ~= obj2.blkorg{3}
                error('Dimensions must agree.');
            end
            info.constr_string = strcat(inputname(1), '>=', inputname(2));
            info.symmetric_constr = 0;
            info.constr_type = 'affine_constr';
            info.operator_type = '>=';
            info.Operator_Matrix = cell(obj1.model.info.prob.block, 1);
            info.Operator_Matrix{obj1.block_no} = speye(obj1.blk{2});
            info.Operator_Matrix{obj2.block_no} = -speye(obj2.blk{2});
            info.active_block = [obj1.block_no, obj2.block_no];
            info.Constant = sparse(obj1.blkorg{2}, obj2.blkorg{3});
            info.num_constr = obj1.blk{2};
            constr_obj = constraint(info);
            return;
        elseif isa(obj2, 'var_free')
            if obj2.block_no == -1
                error('Add the variable ''%s'' into the model first.', inputname(2));
            end
            if ~strcmp(obj1.model.info.prob.name, obj2.model.info.prob.name)
                error('variables are not in the same model.');
            end
            if obj1.blkorg{2} ~= obj2.blkorg{2} || obj1.blkorg{3} ~= obj2.blkorg{3}
                error('Dimensions must agree.');
            end
            info.constr_string = strcat(inputname(1), '>=', inputname(2));
            info.symmetric_constr = 0;
            info.constr_type = 'affine_constr';
            info.operator_type = '>=';
            info.Operator_Matrix = cell(obj1.model.info.prob.block, 1);
            info.Operator_Matrix{obj1.block_no} = speye(obj1.blk{2});
            info.active_block = [obj1.block_no];
            if obj1.block_no == obj2.block_no
                warning(strcat('affine constraint: ', info.constr_string, ' is not necessary'));
                info.Operator_Matrix{obj1.block_no} = sparse(obj1.blk{2}, obj1.blk{2});
            else
                info.Operator_Matrix{obj2.block_no} = -speye(obj2.blk{2});
                info.active_block = [obj1.block_no, obj2.block_no];
            end
            info.Constant = sparse(obj1.blkorg{2}, obj2.blkorg{3});
            info.num_constr = obj1.blk{2};
            constr_obj = constraint(info);
            return;
        end
    elseif isa(obj1, 'double')
        if isscalar(obj1)
            if isa(obj2, 'var_free')
                if obj2.block_no == -1
                    error('Add the variable ''%s'' into the model first.', inputname(2));
                end
                info.constr_string = strcat(num2str(obj1), '>=', inputname(2));
                info.symmetric_constr = 0;
                info.constr_type = 'upper_bound';
                info.operator_type = '>=';
                info.Operator_Matrix = cell(obj2.model.info.prob.block, 1);
                info.active_block = [obj2.block_no];
                info.Constant = obj1*ones(obj2.blkorg{2}, obj2.blkorg{3});
                info.num_constr = obj2.blk{2};
                info.status = -2; % prepare for the chain constrraint. 
                constr_obj = constraint(info);
                return;
            end
        else
            [dim_m, dim_n] = size(obj1);
            if isa(obj2, 'var_free')
                if obj2.block_no == -1
                    error('Add the variable ''%s'' into the model first.', inputname(2));
                end
                if dim_m ~= obj2.blkorg{2}|| dim_n ~= obj2.blkorg{3}
                    error('Dimension must agree.');
                end
                info.constr_string = strcat(inputname(1), '>=', inputname(2));
                info.symmetric_constr = 0;
                info.constr_type = 'upper_bound';
                info.operator_type = '>=';
                info.Operator_Matrix = cell(obj2.model.info.prob.block, 1);
                info.active_block = [obj2.block_no];
                info.Constant = obj1;
                info.num_constr = obj2.blk{2};
                info.status = -2;
                constr_obj = constraint(info);
                return;
            end
        end
    end
end
            