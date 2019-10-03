%%**********************************************************************
%% maximize(model, obj_exp): add objective function obj_exp for model
%%
%% SDPNAL+: 
%% Copyright (c) 2017 by
%% Yancheng Yuan, Kim-Chuan Toh, Defeng Sun and Xinyuan Zhao
%%**********************************************************************

function maximize(model_obj, exp_obj)
    if model_obj.info.prob.block == 0
        error('No variables in the sdp model.');
    end
    if model_obj.info.prob.min ~= 0
        error('Objective function is already defined.');
    end
    if isa(exp_obj, 'expression')
        if exp_obj.constr_dim.m ~=1 || exp_obj.constr_dim.n ~= 1
            error('The objective function must be a scalar.');
        end
        model_obj.info.prob.min = -1;
        len_temp = length(exp_obj.active_block);
        for i = 1:1:len_temp
            idx = exp_obj.active_block(i);
            if strcmp(model_obj.info.prob.blk{i,1}, 's')
                blk_temp{1,1} = model_obj.info.prob.blk{idx,1};
                blk_temp{1,2} = model_obj.info.prob.blk{idx,2};
                model_obj.info.prob.C{idx} = model_obj.info.prob.C{idx} - smat(blk_temp, exp_obj.Operator_Matrix{idx},1);
            else
                model_obj.info.prob.C{idx} = model_obj.info.prob.C{idx} - exp_obj.Operator_Matrix{i};
            end
        end
    else
        error('Invalid input.');
    end
end
%%**********************************************************************
