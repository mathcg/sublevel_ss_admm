%%**********************************************************************
%% l1_norm(X): l1 norm of X
%% X is a declared variable. 
%% SDPNAL+: 
%% Copyright (c) 2017 by
%% Yancheng Yuan , Kim-Chuan Toh, Defeng Sun and Xinyuan Zhao
%%**********************************************************************

function exp_obj = l1_norm(var_obj)
    if var_obj.block_no == -1
       error('Add the variable ''%s'' into the model first.', inputname(1));
    end
    slack_var1 = var_nn(var_obj.blkorg{2},var_obj.blkorg{3});
    slack_var2 = var_nn(var_obj.blkorg{2},var_obj.blkorg{3});
    var_obj.model.add_variable(slack_var1);
    var_obj.model.add_variable(slack_var2);
    exp_obj = sum(slack_var1) + sum(slack_var2);
    exp_obj.exp_string = strcat('l1_norm(', inputname(1), ')');
    var_obj.model.add_affine_constraint(var_obj == slack_var1 - slack_var2);
    var_obj.model.add_affine_constraint(slack_var1 >= 0);
    var_obj.model.add_affine_constraint(slack_var2 >= 0);
end


