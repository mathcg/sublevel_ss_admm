%%**********************************************************************
%% solve(model): solve model
%%
%% SDPNAL+: 
%% Copyright (c) 2017 by
%% Yancheng Yuan , Kim-Chuan Toh, Defeng Sun and Xinyuan Zhao
%%**********************************************************************

function solve(model_obj)

    if ~isa(model_obj, 'ccp_model')
        error('''%s'' model is not defined.', inputname(1));
    end
    if model_obj.info.prob.block == 0
        error('sdp model ''%s'' has no variables.', inputname(1));
    end
    if model_obj.info.prob.min == 0
        error('sdp model ''%s'' has no objective function.', inputname(1));
    end
    para = model_obj.info.prob;
    % Reshape L, U
    for i = 1:1:para.block
        if strcmp(para.blk{i,1}, 'symm')
            para.blk{i,1} = 'u';
        end
        if para.L{i} == -inf
            para.L{i} = [];
        elseif ~strcmp(para.blk{i,1}, 's')
            para.L{i} = vec(para.L{i});
        end
        if para.U{i} == inf
            para.U{i} = [];
        elseif ~strcmp(para.blk{i,1}, 's')
            para.U{i} = vec(para.U{i});
        end
    end
    fprintf('===== Model building completed.\n');
    fprintf('===== SDPNAL+ solver start.\n');
    [obj,XX,ss,yy,Z1,Z2,ybar,v,info_sol,runhist] = ...    
         sdpnalplus(para.blk,para.At,para.C,para.b,para.L,para.U,para.Bt,para.l,para.u,para.OPTIONS);
    model_obj.info.issolved = 1;
    for i = 1:1:model_obj.info.prob.block
        if strcmp(model_obj.info.prob.blk{i,1}, 'u') || strcmp(model_obj.info.prob.blk{i,1},'l')
           XX{i} = reshape(XX{i}, model_obj.info.prob.blkorg{i,2},...
                model_obj.info.prob.blkorg{i,3});
        elseif strcmp(model_obj.info.prob.blk{i,1}, 'symm')
           XX{i} = reshape(XX{i}, model_obj.info.prob.blkorg{i,2},...
                model_obj.info.prob.blkorg{i,3});
           XX{i} = triu(XX{i}) + triu(XX{i},1)';
        end
    end
    model_obj.info.opt_solution = XX;        
    input_data = model_obj.info.prob;
    solution.primal_optimal = XX;
    solution.dual_optimal.y = yy; 
    solution.dual_optimal.Z1 = Z1;
    solution.dual_optimal.Z2 = Z2; 
    model_obj.info.dual_opt = solution.dual_optimal; % new for dual optimal
    solution.info = info_sol;
    save(model_obj.info.prob.name, 'input_data', 'solution');
end
 