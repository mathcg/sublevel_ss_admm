%%**********************************************************************
%% Overload operator 'times / .*'
%%
%% SDPNAL+: 
%% Copyright (c) 2017 by
%% Yancheng Yuan , Kim-Chuan Toh, Defeng Sun and Xinyuan Zhao
%%**********************************************************************

function exp_obj = times(A_mat, var_obj)
    if isa(A_mat, 'double')
        if isa(var_obj, 'var_sdp')
            [dim_m, dim_n] = size(A_mat);
            if dim_m ~= var_obj.blkorg{2}||dim_n ~= var_obj.blkorg{3}
                error('Error using ''.*'':Matrix dimensions must agree.');
            end
            info.exp_string = strcat(inputname(1), '.*', inputname(2));
            info.constr_dim.m = var_obj.blkorg{2};
            info.constr_dim.n = var_obj.blkorg{3};
            info.constr_type = 'vector';
            info.Operator_Matrix = cell(var_obj.model.info.prob.block, 1);
            dim_temp = 0.5*var_obj.blkorg{2}*(var_obj.blkorg{2}+1);
            idx_temp = 1:1:dim_temp;
            value_temp = svec(var_obj.blk, 0.5*(A_mat+A_mat'),1);
            info.Operator_Matrix{var_obj.block_no} = sparse(idx_temp,idx_temp, value_temp,dim_temp,dim_temp);
            info.active_block = [var_obj.block_no];
            info.Constant = sparse(var_obj.blkorg{2}, var_obj.blkorg{3});
            info.status = 1;
            info.model = var_obj.model;
            exp_obj = expression(info);
            return;
        else
            error('Error using ''.*'':The right-hand side must be a declared variable.');
        end
    else
        error('Error using ''.*'':The left-hand side must be a constant matrix.');
    end
end