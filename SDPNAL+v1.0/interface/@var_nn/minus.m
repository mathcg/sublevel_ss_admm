%%**********************************************************************
%% Overload operator 'minus/ - '
%%
%% SDPNAL+: 
%% Copyright (c) 2017 by
%% Yancheng Yuan , Kim-Chuan Toh, Defeng Sun and Xinyuan Zhao
%%**********************************************************************

function exp_obj = minus(obj1, obj2)
    if isa(obj1, 'var_nn')
        if obj1.block_no == -1
            error('Add the variable ''%s'' into the model first.', inputname(1));
        end
        info.exp_string = inputname(1);
        info.constr_dim.m = obj1.blkorg{2};
        info.constr_dim.n = obj1.blkorg{3};
        if isa(obj2, 'var_nn')
            if obj2.block_no == -1
                error('Add the variable ''%s'' into the model first.', inputname(2));
            end
            if obj2.blkorg{2} ~= info.constr_dim.m || obj2.blkorg{3} ~= info.constr_dim.n
                error('Dimensions must agree .');
            end
            if ~strcmp(obj1.model.info.prob.name, obj2.model.info.prob.name)
                error('variables are not in the same model.');
            end
            info.exp_string = strcat(info.exp_string, '-', inputname(2));
            info.constr_type = 'vector';
            info.Operator_Matrix = cell(obj1.model.info.prob.block, 1);
            info.Operator_Matrix{obj1.block_no} = speye(obj1.blk{2});
            info.active_block = [obj1.block_no];
            if ismember(obj2.block_no, info.active_block)
                info.Operator_Matrix{obj2.block_no} = info.Operator_Matrix{obj2.block_no} - speye(obj2.blk{2});
            else
                info.Operator_Matrix{obj2.block_no} = -speye(obj2.blk{2});
                info.active_block = union(info.active_block, obj2.block_no);
            end
            info.Constant = sparse(obj1.blk{2},1);
            info.status = 1;
            info.model = obj1.model;
            exp_obj = expression(info);
            return;
        elseif isa(obj2, 'var_sdp')
            error('Cannot use ''-'' between symmetric and asymmetric variables.');
        elseif isa(obj2, 'var_symm')
            error('Cannot use ''-'' between symmetric and asymmetric variables.');
        elseif isa(obj2, 'expression')
            if ~strcmp(obj2.constr_type, 'vector')
                error('Cannot use ''-'' between symmetric and asymmetric variables.');
            end
            if info.constr_dim.m ~= obj2.constr_dim.m || info.constr_dim.n ~= info.constr_dim.n
                error('Dimensions must agree .');
            end
            if ~strcmp(obj1.model.info.prob.name, obj2.model.info.prob.name)
                error('variables are not in the same model.');
            end
            info.exp_string = strcat(info.exp_string, '-', obj2.exp_string);
            info.constr_type = 'vector';
            info.Operator_Matrix = cell(obj1.model.info.prob.block, 1);
            info.Operator_Matrix{obj1.block_no} = speye(obj1.blk{2});
            info.active_block = [obj1.block_no];
            for i = 1:1:length(obj2.active_block)
                idx = obj2.active_block(i);
                if ismember(idx, info.active_block)
                    info.Operator_Matrix{idx} = info.Operator_Matrix{idx} - obj2.Operator_Matrix{idx};
                else
                    info.Operator_Matrix{idx} = - obj2.Operator_Matrix{idx};
                    info.active_block = union(info.active_block, idx);
                end
            end
            info.Constant = -obj2.Constant;
            info.status = 1;
            info.model = obj1.model;
            exp_obj = expression(info);
            return;
        elseif isa(obj2, 'var_free')
            if obj2.block_no == -1
                 error('Add the variable ''%s'' into the model first.', inputname(2));
            end
            if obj1.blkorg{2} ~= obj2.blkorg{2} || obj1.blkorg{3} ~= obj2.blkorg{3}
                error('Dimension must agree.');
            end
            if ~strcmp(obj1.model.info.prob.name, obj2.model.info.prob.name)
                error('variables are not in the same model.');
            end
            info.exp_string = strcat(inputname(1), '-', inputname(2));
            info.constr_dim.m = obj1.blkorg{2};
            info.constr_dim.n = obj1.blkorg{3};
            info.constr_type = 'vector';
            info.Operator_Matrix = cell(obj1.model.info.prob.block, 1);
            info.Operator_Matrix{obj1.block_no} = speye(obj1.blk{2});
            info.active_block = [obj1.block_no];
            if ismember(obj2.block_no, info.active_block)
                info.Operator_Matrix{obj2.block_no} = info.Operator_Matrix{obj2.block_no} - speye(obj2.blk{2});
            else
                info.Operator_Matrix{obj2.block_no} = -speye(obj2.blk{2});
                info.active_block = union(info.active_block, obj2.block_no);
            end
            info.Constant = sparse(info.constr_dim.m, info.constr_dim.n);
            info.status = 1;
            info.model = obj1.model;
            exp_obj = expression(info);
            return;
        elseif isa(obj2, 'double')
            [dim_m, dim_n] = size(obj2);
            if dim_m ~= obj1.blkorg{2} || dim_n ~= obj1.blkorg{3}
                error('Dimensions must agree.');
            end
            if ~isempty(inputname(2))
                info.exp_string = strcat(inputname(1), '-', inputname(2));
            elseif isscalar(obj2)
                info.exp_string = strcat(inputname(1),'-', num2str(obj2));
            else
                info.exp_string = strcat(inputname(1),'- const');
            end
            info.constr_type = 'vector';
            info.Operator_Matrix = cell(obj1.model.info.prob.block, 1);
            info.Operator_Matrix{obj1.block_no} = speye(obj1.blk{2});
            info.active_block = [obj1.block_no];
            info.Constant = -obj2;
            info.status = 1;
            info.model = obj1.model;
            exp_obj = expression(info);
            return;
        end
    elseif isa(obj1, 'double')
        [dim_m, dim_n] = size(obj1);
        if isa(obj2, 'var_nn')
            if obj2.block_no == -1
                error('Add the variable ''%s'' into the model first.', inputname(2));
            end
            if dim_m ~= obj2.blkorg{2} || dim_n ~= obj2.blkorg{3}
                error('Dimensions must agree.');
            end
            if ~isempty(inputname(1))
                info.exp_string = strcat(inputname(1), '-', inputname(2));
            elseif isscalar(obj1)
                info.exp_string = strcat(num2str(obj1), '-', inputname(2));
            else
                info.exp_string = strcat('const - ', inputname(2));
            end
            info.constr_dim.m = dim_m;
            info.constr_dim.n = dim_n;
            info.constr_type = 'vector';
            info.Operator_Matrix = cell(obj2.model.info.prob.block, 1);
            info.Operator_Matrix{obj2.block_no} = -speye(obj2.blk{2});
            info.active_block = [obj2.block_no];
            info.Constant = obj1;
            info.status = 1;
            info.model = obj2.model;
            exp_obj = expression(info);
            return;
        end
    end
end
            