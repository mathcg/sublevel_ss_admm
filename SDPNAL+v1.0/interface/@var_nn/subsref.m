%%**********************************************************************
%% Overload the built-in function subsref
%%
%% SDPNAL+: 
%% Copyright (c) 2017 by
%% Yancheng Yuan, Kim-Chuan Toh, Defeng Sun and Xinyuan Zhao
%%**********************************************************************

function obj = subsref(var_obj, ind)
    k = length(ind);
    if k > 1
        obj = copy(var_obj);
        for i=1:1:k
            obj = subsref(obj, ind(i));
        end
        return
    end
        
    if ind.type == '.'
        switch ind.subs
            case 'blk'
                obj = var_obj.blk;
                return
            case 'blkorg'
                obj = var_obj.blkorg;
                return
            case 'L_Mat'
                obj = var_obj.L_Mat;
                return
            case 'U_Mat'
                obj = var_obj.U_Mat;
                return
            case 'block_no'
                obj = var_obj.block_no;
                return
            case 'model'
                obj = var_obj.model;
                return
            otherwise
                if var_obj.block_no == -1
                    error('Add the variable ''%s'' into the model first.', inputname(1));
                end
                var_name = var_obj.model.info.prob.varname{var_obj.block_no};
                try
                    obj = evalin('base',strcat(ind.subs, '(',var_name,')'));
                    return;
                catch
                    error('Reference to non-existent field or method ''%s''.', ind.subs);
                end
        end
    elseif strcmp(ind.type, '{}')
        error('Cell contents reference from a non-cell array object.');
    end
    % Handle the case X(i,j)     
    if var_obj.block_no == -1
        error('Add the variable ''%s'' into the model first.', inputname(1));
    end
    num_dim = length(ind.subs);
    info.exp_string = var_obj.model.info.prob.varname{var_obj.block_no};
    if num_dim == 0 
        error('No index specified for ''%s()''.', inputname(1));
    elseif num_dim == 1
        if min(ind.subs{1}) <= 0
            error('Index of matrix must be positive.');
        end
        [dim_m, dim_n] = size(ind.subs{1});
        if min(dim_m, dim_n) ~= 1
            error('Index must be a 1D array.');
        end
        num_constr = max(dim_m, dim_n);
        if max(ind.subs{1}) <= var_obj.blk{2} 
            if num_constr == 1
                info.exp_string = strcat(info.exp_string, '(' , num2str(ind.subs{1}), ')');
            else
                info.exp_string = strcat(info.exp_string, '(Idx)');
            end
            info.Operator_Matrix = cell(var_obj.model.info.prob.block, 1);
            info.Operator_Matrix{var_obj.block_no} = sparse(ind.subs{1},1:1:num_constr,1,var_obj.blk{2},num_constr);
            info.constr_dim.m = num_constr;
            info.constr_dim.n = 1;
            info.constr_type = 'vector';
            info.active_block = [var_obj.block_no];
            info.Constant = sparse(num_constr,1);
            info.status = 1;
            info.model = var_obj.model;
            obj = expression(info);
            return
        else
            error('Index exceeds matrix dimensions.');
        end
    elseif num_dim == 2
        if min(ind.subs{1})<=0 || min(ind.subs{2})<=0
            error('Index of matrix must be positive.');
        end
        [dim_m1,dim_n1] = size(ind.subs{1});
        [dim_m2,dim_n2] = size(ind.subs{2});
        if min(dim_m1,dim_n1)~=1 || min(dim_m2,dim_n2) ~=1
            error('Index must be a 1D array.');
        end
        if max(dim_m1,dim_n1) ~= max(dim_m2, dim_n2)
            error('Index are not balanced.');
        end
        num_constr = max(dim_m1, dim_n1);
        if max(ind.subs{1})<=var_obj.blkorg{2} && max(ind.subs{2})<=var_obj.blkorg{3}
            if num_constr == 1
                info.exp_string = strcat(info.exp_string, '(', num2str(ind.subs{1}), ',',  num2str(ind.subs{2}), ')');
            else
                info.exp_string = strcat(info.exp_string, '(Idx_m,Idx_n)');
            end
            info.Operator_Matrix = cell(var_obj.model.info.prob.block, 1);
            info.Operator_Matrix{var_obj.block_no} = sparse(ind.subs{1}+ (ind.subs{2}-1)*var_obj.blkorg{2},1:1:num_constr,1,var_obj.blk{2},num_constr);
            info.constr_dim.m = num_constr;
            info.constr_dim.n = 1;
            info.constr_type = 'vector';
            info.active_block = [var_obj.block_no];
            info.Constant = sparse(num_constr,1);
            info.status = 1;
            info.model = var_obj.model;
            obj = expression(info);
            return
        else
            error('Index exceeds matrix dimensions.');
        end
    else
        error('Index exceeds matrix dimensions.');
    end
end
%%**********************************************************************
    