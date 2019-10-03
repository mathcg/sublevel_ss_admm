%%**********************************************************************
%% get_dualinfo(model_obj): Get the dual solution of model
%% model_obj is a solved ccp_model
%% SDPNAL+: 
%% Copyright (c) 2017 by
%% Yancheng Yuan , Kim-Chuan Toh, Defeng Sun and Xinyuan Zhao
%%**********************************************************************
function dual_info = get_dualinfo(model_obj)
    if model_obj.info.issolved ~= 1
        error('Solve the model first.');
    end
    dual_info = model_obj.info.dual_opt;
end