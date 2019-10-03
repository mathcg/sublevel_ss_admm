%%**********************************************************************
%% setparameter(model, para_name, para_value): set parameter for model
%%
%% SDPNAL+: 
%% Copyright (c) 2017 by
%% Yancheng Yuan, Kim-Chuan Toh, Defeng Sun and Xinyuan Zhao
%%**********************************************************************
function setparameter(model_obj,varargin)

    if ~isa(model_obj, 'ccp_model')
        error('The first argument must be a ''ccp_model'' object.');
    end
    if nargin == 1 || mod(nargin-1,2)
        error('Inputs are not balanced.');
    end
    len_temp = nargin - 1;
    for i = 1:2:len_temp
        switch varargin{i}
            case 'tol'
                if varargin{i+1} > 0
                    model_obj.info.prob.OPTIONS.tol = varargin{i+1};
                else
                    error('The value of parameter ''tol'' should be a positive scalar.');
                end
            case 'tolADM'
                if varargin{i+1} > 0
                    model_obj.info.prob.OPTIONS.ADMtol = varargin{i+1};
                else
                    error('The value of parameter ''tolADM'' should be a positive scalar.');
                end
            case 'maxiter'
                if varargin{i+1} > 0 && fix(varargin{i+1})==varargin{i+1}
                    model_obj.info.prob.OPTIONS.maxiter = varargin{i+1};
                else
                    error('The value of parameter ''maxiter'' should be a positive integer.');
                end
            case 'maxiterADM'
                if varargin{i+1}>0 && fix(varargin{i+1}) == varargin{i+1}
                    model_obj.info.prob.OPTIONS.maxiterADM = varargin{i+1};
                else
                    error('The value of parameter ''maxiterADM'' should be a positive integer.');
                end
            case 'printlevel'
                if varargin{i+1} == 0 || varargin{i+1} == 1 || varargin{i+1} == 2
                    model_obj.info.prob.OPTIONS.printlevel = varargin{i+1};
                else
                    error('The value of parameter ''printlevel'' should be 0, 1, or 2.');
                end
            case 'stopoption'
                if varargin{i+1} == 0 || varargin{i+1} == 1
                    model_obj.info.prob.OPTIONS.stopoption = varargin{i+1};
                else
                    error('The value of parameter ''stopoption'' should be 0 or 1.');
                end
            case 'AATsolve.method'
                if strcmp(varargin{i+1}, 'direct') || strcmp(varargin{i+1}, 'iterative')
                    model_obj.info.prob.OPTIONS.AATsolve.method = varargin{i+1};
                else
                    error('The value of parameter ''AATsolve.method'' should be ''direct'' or ''iterative''.');
                end
            case 'BBTsolve.method'
                if strcmp(varargin{i+1}, 'direct') || strcmp(varargin{i+1}, 'iterative')
                    model_obj.info.prob.OPTIONS.BBTsolve.method = varargin{i+1};
                else
                    error('The value of parameter ''BBTsolve.method'' should be ''direct'' or ''iterative''.');
                end               
            otherwise
                error('There is no parameter called ''%s''.', varargin{i});
        end
    end
end
%%**********************************************************************