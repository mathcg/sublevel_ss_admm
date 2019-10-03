%%**********************************************************************
%% add_variable(model, variables): add variables into model
%%
%% SDPNAL+: 
%% Copyright (c) 2017 by
%% Yancheng Yuan, Kim-Chuan Toh, Defeng Sun and Xinyuan Zhao
%%**********************************************************************

function add_variable(model_obj, varargin)

    if nargin < 2
        error('Not enough arguments for ''add_variable(model, variable)''.\n');
    end
    if ~isa(model_obj, 'ccp_model')
        error('The first arugment must be a ''ccp_model''.');
    end
    for i = 1:1:nargin-1
        var_name = inputname(i+1);
        add_variable_subroutine(model_obj, varargin{i}, var_name);
    end
end
%%********************************************************************
%%********************************************************************
function add_variable_subroutine(model_obj, variable, var_name)
    if ~(isa(variable, 'var_free')||isa(variable,'var_sdp')||isa(variable, 'var_nn')||isa(variable, 'var_symm'))
        error('The second argument must be a variable.');
    end
    if variable.block_no ~= -1
        error('variable ''%s'' already exists.', var_name);
    end
    % Update model
    model_obj.info.prob.block = model_obj.info.prob.block + 1;
    variable.block_no = model_obj.info.prob.block;
    model_obj.info.prob.blk{variable.block_no,1} = variable.blk{1};
    model_obj.info.prob.blk{variable.block_no,2} = variable.blk{2};
    num_eq = model_obj.info.num_eqconstr;
    if num_eq == 0
        model_obj.info.prob.At{variable.block_no,1} = [];
    else
        if isa(variable, 'var_free')||isa(variable, 'var_nn')||isa(variable, 'var_symm')
            model_obj.info.prob.At{variable.block_no,1} = sparse(variable.blk{2},num_eq);
        elseif isa(variable, 'var_sdp')
            model_obj.info.prob.At{variable.block_no,1} = sparse(0.5*variable.blkorg{2}*(variable.blkorg{2}+1),num_eq);
        end
    end
    
    num_ineq = model_obj.info.num_ineqconstr;
    if num_ineq == 0
        model_obj.info.prob.Bt{variable.block_no} = [];
    else
        if isa(variable, 'var_free')||isa(variable, 'var_nn')||isa(variable,'var_symm')
            model_obj.info.prob.Bt{variable.block_no,1} = sparse(variable.blk{2},num_ineq);
        elseif isa(variable, 'var_sdp')
            model_obj.info.prob.Bt{variable.block_no,1} = sparse(0.5*variable.blkorg{2}*(variable.blkorg{2}+1),num_ineq);
        end
    end
    
    model_obj.info.prob.L{variable.block_no,1}= variable.L_Mat;
    model_obj.info.prob.U{variable.block_no,1}= variable.U_Mat;
    
    model_obj.info.prob.blkorg{variable.block_no,1}=variable.blkorg{1};
    model_obj.info.prob.blkorg{variable.block_no,2}=variable.blkorg{2};
    model_obj.info.prob.blkorg{variable.block_no,3}=variable.blkorg{3};    
    
    model_obj.info.prob.varname{variable.block_no}=var_name;
    
    if isa(variable, 'var_sdp')
       model_obj.info.prob.C{variable.block_no,1}= sparse(variable.blkorg{2},variable.blkorg{3});
    else
       model_obj.info.prob.C{variable.block_no,1}= sparse(variable.blk{2},1);
    end
    variable.model = model_obj;
end
%%********************************************************************

            
    