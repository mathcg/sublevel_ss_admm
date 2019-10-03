%%**********************************************************************
%% class def: ccp_model
%% 
%% Note: lump everything in info so that it is easy to pass the 
%%       content around. 
%% SDPNAL+: 
%% Copyright (c) 2017 by
%% Yancheng Yuan, Kim-Chuan Toh, Defeng Sun and Xinyuan Zhao
%%**********************************************************************
classdef ccp_model < matlab.mixin.Copyable
    
    properties 
        info 
    end
    
    methods 
        function model_obj = ccp_model(name)
            if nargin == 0
                model_obj.info = ccp_info('Default');
                fprintf('===== Model building start.\n');
            elseif nargin == 1
                if ischar(name)
                    model_obj.info = ccp_info(name);
                    fprintf('===== Model building start.\n');
                else
                    error('Model name must be strings.');
                end
            end
        end
    end
end
%%**********************************************************************