%%**********************************************************************
%% add_affine_constraint(model, constr): add affine constraint constr into model.
%% model: declared ccp_model, constr: affine constraint
%% SDPNAL+: 
%% Copyright (c) 2017 by
%% Yancheng Yuan, Kim-Chuan Toh, Defeng Sun and Xinyuan Zhao
%%**********************************************************************
function add_affine_constraint(model_obj, constr_obj)
    if nargin < 2
        error('Not enough arguments for ''add_affine_constraint(model, constraint)''.');
    end
    if ~isa(model_obj, 'ccp_model')
        error('''%s'' is not a ''ccp_model''.', inputname(1));
    end
    if ~isa(constr_obj, 'constraint')
        error('The second argument must be a ''constraint''.');
    end
    if strcmp(constr_obj.constr_type, 'upper_bound')
        num_block = length(constr_obj.active_block);
        for i = 1:1:num_block
            idx = constr_obj.active_block(i);
            model_obj.info.prob.U{idx} = min(model_obj.info.prob.U{idx}, constr_obj.Constant);
        end
    elseif strcmp(constr_obj.constr_type, 'lower_bound')
        num_block = length(constr_obj.active_block);
        for i = 1:num_block
            idx = constr_obj.active_block(i);
            model_obj.info.prob.L{idx} = max(model_obj.info.prob.L{idx}, constr_obj.Constant);
        end
    elseif strcmp(constr_obj.constr_type, 'twodirect_bound')
        num_block = length(constr_obj.active_block);
        for i = 1:num_block
            idx = constr_obj.active_block(i);
            if ~isempty(constr_obj.Constant.L)
                model_obj.info.prob.L{idx} = max(constr_obj.Constant.L, model_obj.info.prob.L{idx});
            end
            if ~isempty(constr_obj.Constant.U)
                model_obj.info.prob.U{idx} = min(constr_obj.Constant.U, model_obj.info.prob.U{idx});
            end
        end
    elseif strcmp(constr_obj.constr_type, 'affine_constr')
        if strcmp(constr_obj.operator_type, '<=')
            if constr_obj.symmetric_constr == 1
                for i = 1:1:model_obj.info.prob.block
                    if ismember(i, constr_obj.active_block)
                        model_obj.info.prob.Bt{i} = cat(2, model_obj.info.prob.Bt{i}, constr_obj.Operator_Matrix{i});
                    else
                        if strcmp(model_obj.info.prob.blk{i,1}, 's')
                            dim_temp = 0.5*model_obj.info.prob.blkorg{i,2}*(model_obj.info.prob.blkorg{i,3}+1);
                            model_obj.info.prob.Bt{i} = cat(2, model_obj.info.prob.Bt{i}, sparse(dim_temp, constr_obj.num_constr));
                        else
                            dim_temp = model_obj.info.prob.blk{i,2};
                            model_obj.info.prob.Bt{i} = cat(2, model_obj.info.prob.Bt{i}, sparse(dim_temp, constr_obj.num_constr));
                        end
                    end
                end
                constr_obj.Constant = 0.5*(constr_obj.Constant + (constr_obj.Constant)');
                bound_temp = constr_obj.Constant - diag(diag(constr_obj.Constant));
                bound_temp = sqrt(2)*bound_temp + diag(diag(constr_obj.Constant));
                [dim_m, ~] = size(constr_obj.Constant);
                blk_temp{1} = 's';                
                blk_temp{2} = dim_m;
                if constr_obj.status == 1
                    u_temp = svec(blk_temp, bound_temp, 1);
                    l_temp = -Inf*ones(constr_obj.num_constr, 1);
                else
                    l_temp = svec(blk_temp, bound_temp, 1);
                    u_temp = Inf*ones(constr_obj.num_constr, 1);
                end
                model_obj.info.prob.l = cat(1, model_obj.info.prob.l, l_temp);
                model_obj.info.prob.u = cat(1, model_obj.info.prob.u, u_temp);
                model_obj.info.num_ineqconstr = model_obj.info.num_ineqconstr + constr_obj.num_constr;
            else
                for i = 1:model_obj.info.prob.block
                    if ismember(i, constr_obj.active_block)
                        model_obj.info.prob.Bt{i} = cat(2, model_obj.info.prob.Bt{i}, constr_obj.Operator_Matrix{i});
                    else
                        if strcmp(model_obj.info.prob.blk{i,1}, 's')
                            dim_temp = 0.5*model_obj.info.prob.blkorg{i,2}*(model_obj.info.prob.blkorg{i,3}+1);
                            model_obj.info.prob.Bt{i} = cat(2, model_obj.info.prob.Bt{i}, sparse(dim_temp, constr_obj.num_constr));
                        else
                            dim_temp = model_obj.info.prob.blk{i,2};
                            model_obj.info.prob.Bt{i} = cat(2, model_obj.info.prob.Bt{i}, sparse(dim_temp, constr_obj.num_constr));
                        end
                    end
                end
                if constr_obj.status == 1
                    u_temp = reshape(constr_obj.Constant, constr_obj.num_constr, 1);
                    l_temp = -Inf*ones(constr_obj.num_constr, 1);
                else
                    u_temp = Inf*ones(constr_obj.num_constr, 1);
                    l_temp = reshape(constr_obj.Constant, constr_obj.num_constr, 1);
                end
                model_obj.info.prob.l = cat(1, model_obj.info.prob.l, l_temp);
                model_obj.info.prob.u = cat(1, model_obj.info.prob.u, u_temp);
                model_obj.info.num_ineqconstr = model_obj.info.num_ineqconstr + constr_obj.num_constr;
            end
        elseif strcmp(constr_obj.operator_type, '>=')
             if constr_obj.symmetric_constr == 1
                for i = 1:model_obj.info.prob.block
                    if ismember(i, constr_obj.active_block)
                        model_obj.info.prob.Bt{i} = cat(2, model_obj.info.prob.Bt{i}, constr_obj.Operator_Matrix{i});
                    else
                        if strcmp(model_obj.info.prob.blk{i,1}, 's')
                            dim_temp = 0.5*model_obj.info.prob.blkorg{i,2}*(model_obj.info.prob.blkorg{i,3}+1);
                            model_obj.info.prob.Bt{i} = cat(2, model_obj.info.prob.Bt{i}, sparse(dim_temp, constr_obj.num_constr));
                        else
                            dim_temp = model_obj.info.prob.blk{i,2};
                            model_obj.info.prob.Bt{i} = cat(2, model_obj.info.prob.Bt{i}, sparse(dim_temp, constr_obj.num_constr));
                        end
                    end
                end
                constr_obj.Constant = 0.5*(constr_obj.Constant + (constr_obj.Constant)');
                bound_temp = constr_obj.Constant - diag(diag(constr_obj.Constant));
                bound_temp = sqrt(2)*bound_temp + diag(diag(constr_obj.Constant));
                [dim_m, ~] = size(constr_obj.Constant);
                blk_temp{1} = 's';                
                blk_temp{2} = dim_m;
                if constr_obj.status == 1
                    l_temp = svec(blk_temp, bound_temp, 1);
                    u_temp = Inf*ones(constr_obj.num_constr, 1);
                else
                    l_temp = -inf*ones(constr_obj.num_constr, 1);
                    u_temp = svec(blk_temp, bound_temp,1);
                end
                model_obj.info.prob.l = cat(1, model_obj.info.prob.l, l_temp);
                model_obj.info.prob.u = cat(1, model_obj.info.prob.u, u_temp);
                model_obj.info.num_ineqconstr = model_obj.info.num_ineqconstr + constr_obj.num_constr;
            else
                for i = 1:model_obj.info.prob.block
                    if ismember(i, constr_obj.active_block)
                        model_obj.info.prob.Bt{i} = cat(2, model_obj.info.prob.Bt{i}, constr_obj.Operator_Matrix{i});
                    else
                        if strcmp(model_obj.info.prob.blk{i,1}, 's')
                            dim_temp = 0.5*model_obj.info.prob.blkorg{i,2}*(model_obj.info.prob.blkorg{i,3}+1);
                            model_obj.info.prob.Bt{i} = cat(2, model_obj.info.prob.Bt{i}, sparse(dim_temp, constr_obj.num_constr));
                        else
                            dim_temp = model_obj.info.prob.blk{i,2};
                            model_obj.info.prob.Bt{i} = cat(2, model_obj.info.prob.Bt{i}, sparse(dim_temp, constr_obj.num_constr));
                        end
                    end
                end
                if constr_obj.status == 1
                    l_temp = reshape(constr_obj.Constant, constr_obj.num_constr, 1);
                    u_temp = Inf*ones(constr_obj.num_constr, 1);
                else
                    l_temp = -inf*ones(constr_obj.num_constr, 1);
                    u_temp = reshape(constr_obj.Constant, constr_obj.num_constr,1);
                end
                model_obj.info.prob.l = cat(1, model_obj.info.prob.l, l_temp);
                model_obj.info.prob.u = cat(1, model_obj.info.prob.u, u_temp);
                model_obj.info.num_ineqconstr = model_obj.info.num_ineqconstr + constr_obj.num_constr;
             end
        elseif strcmp(constr_obj.operator_type, '==')
            if (constr_obj.symmetric_constr == 1)
                for i = 1:model_obj.info.prob.block
                    if ismember(i, constr_obj.active_block)
                        model_obj.info.prob.At{i} = cat(2, model_obj.info.prob.At{i}, constr_obj.Operator_Matrix{i});
                    else
                        if strcmp(model_obj.info.prob.blk{i,1}, 's')
                            dim_temp = 0.5*model_obj.info.prob.blkorg{i,2}*(model_obj.info.prob.blkorg{i,3}+1);
                            model_obj.info.prob.At{i} = cat(2, model_obj.info.prob.At{i}, sparse(dim_temp, constr_obj.num_constr));
                        else
                            dim_temp = model_obj.info.prob.blk{i,2};
                            model_obj.info.prob.At{i} = cat(2, model_obj.info.prob.At{i}, sparse(dim_temp, constr_obj.num_constr));
                        end
                    end
                end
                constr_obj.Constant = 0.5*(constr_obj.Constant + constr_obj.Constant');
                b_temp = constr_obj.Constant - diag(diag(constr_obj.Constant));
                b_temp = sqrt(2)*b_temp + diag(diag(constr_obj.Constant));
                [dim_m, ~] = size(constr_obj.Constant);
                blk_temp{1} = 's';                
                blk_temp{2} = dim_m;
                b_temp = svec(blk_temp, b_temp, 1);
                model_obj.info.prob.b = cat(1, model_obj.info.prob.b, b_temp);
                model_obj.info.num_eqconstr = model_obj.info.num_eqconstr + constr_obj.num_constr;
            else
                for i = 1:model_obj.info.prob.block
                    if ismember(i, constr_obj.active_block)
                        model_obj.info.prob.At{i} = cat(2, model_obj.info.prob.At{i}, constr_obj.Operator_Matrix{i});
                    else
                        if strcmp(model_obj.info.prob.blk{i,1}, 's')
                            dim_temp = 0.5*model_obj.info.prob.blkorg{i,2}*(model_obj.info.prob.blkorg{i,3}+1);
                            model_obj.info.prob.At{i} = cat(2, model_obj.info.prob.At{i}, sparse(dim_temp, constr_obj.num_constr));
                        else
                            dim_temp = model_obj.info.prob.blk{i,2};
                            model_obj.info.prob.At{i} = cat(2, model_obj.info.prob.At{i}, sparse(dim_temp, constr_obj.num_constr));
                        end
                    end
                end
                b_temp = reshape(constr_obj.Constant, constr_obj.num_constr,1);
                model_obj.info.prob.b = cat(1, model_obj.info.prob.b, b_temp);
                model_obj.info.num_eqconstr = model_obj.info.num_eqconstr + constr_obj.num_constr;
            end
        end
    elseif strcmp(constr_obj.constr_type, 'chain_constr')
        if constr_obj.symmetric_constr == 1
            for i = 1:model_obj.info.prob.block
                if ismember(i, constr_obj.active_block)
                    model_obj.info.prob.Bt{i} = cat(2, model_obj.info.prob.Bt{i}, constr_obj.Operator_Matrix{i});
                else
                    if strcmp(model_obj.info.prob.blk{i,1}, 's')
                        dim_temp = 0.5*model_obj.info.prob.blkorg{i,2}*(model_obj.info.prob.blkorg{i,3}+1);
                        model_obj.info.prob.Bt{i} = cat(2, model_obj.info.prob.Bt{i}, sparse(dim_temp, constr_obj.num_constr));
                    else
                        dim_temp = model_obj.info.prob.blk{i,2};
                        model_obj.info.prob.Bt{i} = cat(2, model_obj.info.prob.Bt{i}, sparse(dim_temp, constr_obj.num_constr));
                    end
                end
            end
            if isempty(constr_obj.Constant.L)
                l_temp = -inf*ones(constr_obj.num_constr,1);
            else
                [dim_m, ~] = size(constr_obj.Constant.L);
                constr_obj.Constant.L = 0.5*(constr_obj.Constant.L + constr_obj.Constant.L');
                l_temp = constr_obj.Constant.L - diag(diag(constr_obj.Constant.L));
                l_temp = sqrt(2)*l_temp + diag(diag(constr_obj.Constant.L));
                l_temp = svec({'s',dim_m}, l_temp, 1);
            end
            if isempty(constr_obj.Constant.U)
                u_temp = inf*ones(constr_obj.num_constr,1);
            else
                [dim_m, ~] = size(constr_obj.Constant.U);
                constr_obj.Constant.U = 0.5*(constr_obj.Constant.U + constr_obj.Constant.U');
                u_temp = constr_obj.Constant.U - diag(diag(constr_obj.Constant.U));
                u_temp = sqrt(2)*u_temp + diag(diag(constr_obj.Constant.U));
                u_temp = svec({'s',dim_m}, u_temp, 1);
            end
            model_obj.info.prob.u = cat(1, model_obj.info.prob.u, u_temp);
            model_obj.info.prob.l = cat(1, model_obj.info.prob.l, l_temp);
            model_obj.info.num_ineqconstr = model_obj.info.num_ineqconstr + constr_obj.num_constr;
        else
            for i = 1:model_obj.info.prob.block
                if ismember(i, constr_obj.active_block)
                    model_obj.info.prob.Bt{i} = cat(2, model_obj.info.prob.Bt{i}, constr_obj.Operator_Matrix{i});
                else
                    if strcmp(model_obj.info.prob.blk{i,1}, 's')
                        dim_temp = 0.5*model_obj.info.prob.blkorg{i,2}*(model_obj.info.prob.blkorg{i,3}+1);
                        model_obj.info.prob.Bt{i} = cat(2, model_obj.info.prob.Bt{i}, sparse(dim_temp, constr_obj.num_constr));
                    else
                        dim_temp = model_obj.info.prob.blk{i,2};
                        model_obj.info.prob.Bt{i} = cat(2, model_obj.info.prob.Bt{i}, sparse(dim_temp, constr_obj.num_constr));
                    end
                end
            end
            if isempty(constr_obj.Constant.U)
                u_temp = Inf*ones(constr_obj.num_constr, 1);
            else
                u_temp = reshape(constr_obj.Constant.U, constr_obj.num_constr, 1);
            end
            if isempty(constr_obj.Constant.L)
                l_temp = -Inf*ones(constr_obj.num_constr, 1);
            else
                l_temp = reshape(constr_obj.Constant.L, constr_obj.num_constr, 1);
            end
            model_obj.info.prob.l = cat(1, model_obj.info.prob.l, l_temp);
            model_obj.info.prob.u = cat(1, model_obj.info.prob.u, u_temp);
            model_obj.info.num_ineqconstr = model_obj.info.num_ineqconstr + constr_obj.num_constr;
        end
    end
end