%%**********************************************************************
%% add_psd_constraint(model, constr): add psd constr into model
%% 
%% SDPNAL+: 
%% Copyright (c) 2017 by
%% Yancheng Yuan , Kim-Chuan Toh, Defeng Sun and Xinyuan Zhao
%%**********************************************************************

function add_psd_constraint(model_obj, constr_obj)
    if nargin < 2
        error('Not enough arguments for ''add_affine_constraint(model, constraint)''.');
    end
    if ~isa(model_obj, 'ccp_model')
        error('The first arugment must be a ''ccp_model''.');
    end
    if ~isa(constr_obj, 'constraint')
        error('The second argument must be a ''constraint''.');
    end
    if constr_obj.symmetric_constr == 0
        error('PSD constraints only for symmetric variables.');
    end
    switch constr_obj.constr_type
        case 'upper_bound'
            % plus sdpvar
            [dim_m, dim_n] = size(constr_obj.Constant);
            slack_var_psd = var_sdp(dim_m, dim_n);
            model_obj.add_variable(slack_var_psd);
            constr_obj.constr_type = 'affine_constr';
            constr_obj.operator_type = '==';
            matrix_temp = sqrt(2)*speye(0.5*dim_m*(dim_m+1));
            for i = 1:1:dim_m
                idx = 0.5*i*(i+1);
                matrix_temp(idx, idx)=1;
            end
            constr_obj.Operator_Matrix{slack_var_psd.block_no} = matrix_temp;
            % Initialize Operator_Matrix for the origin variable, since we set as empty for
            % bound constraint
            block_no = constr_obj.active_block(1); % Only one block for bound constraint.
            if strcmp(model_obj.info.prob.blk{block_no, 1}, 's')
                constr_obj.Operator_Matrix{block_no} = matrix_temp;
            elseif strcmp(model_obj.info.prob.blk{block_no, 1}, 'symm')
                [idx_i,idx_j]=find(triu(ones(dim_m, dim_n))>0);
                idx_temp = idx_i+dim_m*(idx_j-1);
                dim_temp = 0.5*dim_m*(dim_m+1);
                matrix_temp = sparse(idx_temp,[1:1:dim_temp],2,dim_m*dim_n,dim_temp);
                for i = 1:1:dim_m
                    idx1 = i+(i-1)*dim_m;
                    idx2 = 0.5*i*(i+1);
                    matrix_temp(idx1, idx2) = 1;
                end
                constr_obj.Operator_Matrix{block_no} = matrix_temp;
            else
                error('Wrong variable type.');
            end
            constr_obj.active_block = union(constr_obj.active_block, slack_var_psd.block_no);
            model_obj.add_affine_constraint(constr_obj);
        case 'lower_bound'
            % minus sdpvar
            [dim_m, dim_n] = size(constr_obj.Constant);
            slack_var_psd = var_sdp(dim_m, dim_n);
            model_obj.add_variable(slack_var_psd);
            constr_obj.constr_type = 'affine_constr';
            constr_obj.operator_type = '==';
            matrix_temp = -sqrt(2)*speye(0.5*dim_m*(dim_m+1));
            for i = 1:1:dim_m
                idx = 0.5*i*(i+1);
                matrix_temp(idx, idx)=-1;
            end
            constr_obj.Operator_Matrix{slack_var_psd.block_no} = matrix_temp;
            % Initialize Operator_Matrix for the origin variable, since we set as empty for
            % bound constraint
            block_no = constr_obj.active_block(1); % Only one block for bound constraint.
            if strcmp(model_obj.info.prob.blk{block_no, 1}, 's')
                constr_obj.Operator_Matrix{block_no} = -matrix_temp;
            elseif strcmp(model_obj.info.prob.blk{block_no, 1}, 'symm')
                [idx_i,idx_j]=find(triu(ones(dim_m, dim_n))>0);
                idx_temp = idx_i+dim_m*(idx_j-1);
                dim_temp = 0.5*dim_m*(dim_m+1);
                matrix_temp = sparse(idx_temp,[1:1:dim_temp],2,dim_m*dim_n,dim_temp);
                for i = 1:1:dim_m
                    idx1 = i+(i-1)*dim_m;
                    idx2 = 0.5*i*(i+1);
                    matrix_temp(idx1, idx2) = 1;
                end
                constr_obj.Operator_Matrix{block_no} = matrix_temp;
            else
                error('Wrong variable type.');
            end
            constr_obj.active_block = union(constr_obj.active_block, slack_var_psd.block_no);
            model_obj.add_affine_constraint(constr_obj);
        case 'twodirect_bound'
            if ~isempty(constr_obj.Constant.L)
                [dim_m, dim_n] = size(constr_obj.Constant.L);
                constr_obj_L = constr_obj;
                slack_var_L = var_sdp(dim_m, dim_n);
                model_obj.add_variable(slack_var_L);
                constr_obj_L.operator_type = '==';
                constr_obj_L.constr_type = 'affine_constr';
                matrix_temp = -sqrt(2)*speye(0.5*dim_m*(dim_m+1));
                for i = 1:1:dim_m
                    idx = 0.5*i*(i+1);
                    matrix_temp(idx,idx) = -1;
                end
                constr_obj_L.Operator_Matrix{slack_var_L.block_no} = matrix_temp;
                block_no = constr_obj_L.active_block(1); % Only one block for bound constraint.
                if strcmp(model_obj.info.prob.blk{block_no, 1}, 's')
                    constr_obj_L.Operator_Matrix{block_no} = -matrix_temp;
                elseif strcmp(model_obj.info.prob.blk{block_no, 1}, 'symm')
                    [idx_i,idx_j]=find(triu(ones(dim_m, dim_n))>0);
                    idx_temp = idx_i+dim_m*(idx_j-1);
                    dim_temp = 0.5*dim_m*(dim_m+1);
                        matrix_temp = sparse(idx_temp,[1:1:dim_temp],2,dim_m*dim_n,dim_temp);
                    for i = 1:1:dim_m
                        idx1 = i+(i-1)*dim_m;
                        idx2 = 0.5*i*(i+1);
                        matrix_temp(idx1, idx2) = 1;
                    end
                    constr_obj_L.Operator_Matrix{block_no} = matrix_temp;
                else
                    error('Wrong variable type.');
                end
                constr_obj_L.Constant = constr_obj.Constant.L;
                constr_obj_L.active_block = union(constr_obj_L.active_block,slack_var_L.block_no);
                model_obj.add_affine_constraint(constr_obj_L);
            end
            if ~isempty(constr_obj.Constant.U)
                [dim_m, dim_n] = size(constr_obj.Constant.U);
                constr_obj_U = constr_obj;
                slack_var_U = var_sdp(dim_m, dim_n);
                model_obj.add_variable(slack_var_U);
                constr_obj_U.operator_type = '==';
                constr_obj_U.constr_type = 'affine_constr';
                matrix_temp = sqrt(2)*speye(0.5*dim_m*(dim_m+1));
                for i = 1:1:dim_m
                    idx = 0.5*i*(i+1);
                    matrix_temp(idx,idx) = 1;
                end
                constr_obj_U.Operator_Matrix{slack_var_U.block_no} = matrix_temp;
                block_no = constr_obj.active_block(1); % Only one block for bound constraint.
                if strcmp(model_obj.info.prob.blk{block_no, 1}, 's')
                    constr_obj_U.Operator_Matrix{block_no} = matrix_temp;
                elseif strcmp(model_obj.info.prob.blk{block_no, 1}, 'symm')
                    [idx_i,idx_j]=find(triu(ones(dim_m, dim_n))>0);
                    idx_temp = idx_i+dim_m*(idx_j-1);
                    dim_temp = 0.5*dim_m*(dim_m+1);
                    matrix_temp = sparse(idx_temp,[1:1:dim_temp],2,dim_m*dim_n,dim_temp);
                    for i = 1:1:dim_m
                        idx1 = i+(i-1)*dim_m;
                        idx2 = 0.5*i*(i+1);
                        matrix_temp(idx1, idx2) = 1;
                    end
                    constr_obj_U.Operator_Matrix{block_no} = matrix_temp;
                else
                    error('Wrong variable type.');
                end
                constr_obj_U.active_block = union(constr_obj_U.active_block,slack_var_U.block_no);
                constr_obj_U.Constant = constr_obj.Constant.U;
                model_obj.add_affine_constraint(constr_obj_U);
            end
        case 'affine_constr'
            switch constr_obj.operator_type
                case '<='
                    if constr_obj.status == 1 % X + Y <= C
                        [dim_m, dim_n] = size(constr_obj.Constant);
                        slack_var = var_sdp(dim_m, dim_n);
                        model_obj.add_variable(slack_var);
                        constr_obj.operator_type = '==';
                        matrix_temp = sqrt(2)*speye(0.5*dim_m*(dim_m+1));
                        for i = 1:1:dim_m
                            idx = 0.5*i*(i+1);
                            matrix_temp(idx, idx)=1;
                        end
                        constr_obj.Operator_Matrix{slack_var.block_no} = matrix_temp;
                        constr_obj.active_block = union(constr_obj.active_block,slack_var.block_no);
                        model_obj.add_affine_constraint(constr_obj);
                    else   % C <= X + Y
                        [dim_m, dim_n] = size(constr_obj.Constant);
                        slack_var = var_sdp(dim_m, dim_n);
                        model_obj.add_variable(slack_var);
                        constr_obj.operator_type = '==';
                        matrix_temp = -sqrt(2)*speye(0.5*dim_m*(dim_m+1));
                        for i = 1:1:dim_m
                            idx = 0.5*i*(i+1);
                            matrix_temp(idx, idx)=-1;
                        end
                        constr_obj.Operator_Matrix{slack_var.block_no} = matrix_temp;
                        constr_obj.active_block = union(constr_obj.active_block,slack_var.block_no);
                        model_obj.add_affine_constraint(constr_obj);
                    end
                case '>='
                    if constr_obj.status == 1 % X + Y >= C
                        [dim_m, dim_n] = size(constr_obj.Constant);
                        slack_var = var_sdp(dim_m, dim_n);
                        model_obj.add_variable(slack_var);
                        constr_obj.operator_type = '==';
                        matrix_temp = -sqrt(2)*speye(0.5*dim_m*(dim_m+1));
                        for i = 1:1:dim_m
                            idx = 0.5*i*(i+1);
                            matrix_temp(idx, idx)=-1;
                        end
                        constr_obj.Operator_Matrix{slack_var.block_no} = matrix_temp;
                        constr_obj.active_block = union(constr_obj.active_block,slack_var.block_no);
                        model_obj.add_affine_constraint(constr_obj);
                    else   % C >= X + Y
                        [dim_m, dim_n] = size(constr_obj.Constant);
                        slack_var = var_sdp(dim_m, dim_n);
                        model_obj.add_variable(slack_var);
                        constr_obj.operator_type = '==';
                        matrix_temp = sqrt(2)*speye(0.5*dim_m*(dim_m+1));
                        for i = 1:1:dim_m
                            idx = 0.5*i*(i+1);
                            matrix_temp(idx, idx)=1;
                        end
                        constr_obj.Operator_Matrix{slack_var.block_no} = matrix_temp;
                        constr_obj.active_block = union(constr_obj.active_block,slack_var.block_no);
                        model_obj.add_affine_constraint(constr_obj);
                    end
                case '=='
                    error('Only support ''>='' or ''<='' for psd constraint.');
                    
                otherwise
                    error('''%s'' is not supported for psd constranit.', constr_obj.operator_type);
            end
        case 'chain_constr'
            if ~isempty(constr_obj.Constant.L)
                [dim_m, dim_n] = size(constr_obj.Constant.L);
                constr_obj_L = constr_obj;
                slack_var_L = var_sdp(dim_m, dim_n);
                model_obj.add_variable(slack_var_L);
                constr_obj_L.operator_type = '==';
                constr_obj_L.constr_type = 'affine_constr';
                matrix_temp = -sqrt(2)*speye(0.5*dim_m*(dim_m+1));
                for i = 1:1:dim_m
                    idx = 0.5*i*(i+1);
                    matrix_temp(idx, idx)=-1;
                end
                constr_obj_L.Operator_Matrix{slack_var_L.block_no} = matrix_temp;
                constr_obj_L.active_block = union(constr_obj_L.active_block,slack_var_L.block_no);
                constr_obj_L.Constant = constr_obj_L.Constant.L;
                model_obj.add_affine_constraint(constr_obj_L);
            end
            if ~isempty(constr_obj.Constant.U)
                [dim_m, dim_n] = size(constr_obj.Constant.U);
                constr_obj_U = constr_obj;
                slack_var_U = var_sdp(dim_m, dim_n);
                model_obj.add_variable(slack_var_U);
                constr_obj_U.operator_type = '==';
                constr_obj_U.constr_type = 'affine_constr';
                matrix_temp = sqrt(2)*speye(0.5*dim_m*(dim_m+1));
                for i = 1:1:dim_m
                    idx = 0.5*i*(i+1);
                    matrix_temp(idx, idx)=1;
                end
                constr_obj_U.Operator_Matrix{slack_var_U.block_no} = matrix_temp;
                constr_obj_U.active_block = union(constr_obj_U.active_block,slack_var_U.block_no);
                constr_obj_U.Constant = constr_obj_U.Constant.U;
                model_obj.add_affine_constraint(constr_obj_U);
            end
        otherwise
            error('Invalid Input Type.');
    end
end
            
            
            