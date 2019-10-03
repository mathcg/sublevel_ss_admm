%%**********************************************************************
%% inprod: compute inprod  <C, X>:
%% C is a constant; X is a declared free variable
%% SDPNAL: 
%% Copyright (c) 2017 by
%% Yancheng Yuan , Kim-Chuan Toh, Defeng Sun and Xinyuan Zhao
%%**********************************************************************
function exp_obj = inprod(obj1, obj2)
    if isa(obj1, 'var_free')
        if obj1.block_no == -1
            error('Add the variable ''%s'' into the model first.', inputname(1));
        end
        if isa(obj2, 'double')
            [dim_m, dim_n] = size(obj2);
            if dim_m ~= obj1.blkorg{2} || dim_n ~= obj1.blkorg{3}
                error('Dimension must agree.');
            end
            info.exp_string = strcat('<', inputname(1), ',', inputname(2), '>');
            info.constr_dim.m = 1;
            info.constr_dim.n = 1;
            info.constr_type = 'vector';
            info.Operator_Matrix = cell(obj1.model.info.prob.block,1);
            info.Operator_Matrix{obj1.block_no} = reshape(obj2, obj1.blk{2},1);
            info.active_block = [obj1.block_no];
            info.Constant = 0;
            info.status = 2;
            info.model = obj1.model;
            exp_obj = expression(info);
            return;
        else
            error('One of the input of ''inprod(C, X)'' must be constant matrix or vector.');
        end
    elseif isa(obj2, 'var_free')
        if obj2.block_no == -1
            error('Add the variable ''%s'' into the model first.', inputname(2));
        end
        if isa(obj1, 'double')
            [dim_m, dim_n] = size(obj1);
            if dim_m ~= obj2.blkorg{2} || dim_n ~= obj2.blkorg{3}
                error('Dimension must agree.');
            end
            info.exp_string = strcat('<', inputname(1), ',', inputname(2), '>');
            info.constr_dim.m = 1;
            info.constr_dim.n = 1;
            info.constr_type = 'vector';
            info.Operator_Matrix = cell(obj2.model.info.prob.block,1);
            info.Operator_Matrix{obj2.block_no} = reshape(obj1, obj2.blk{2},1);
            info.active_block = [obj2.block_no];
            info.Constant = 0;
            info.status = 2;
            info.model = obj2.model;
            exp_obj = expression(info);
            return;
        else
            error('One of the input of ''inprod(C, X)'' must be constant matrix or vector.');
        end
    else
        error('One of the input of ''inprod(C, X)'' must be variable.');
    end
end