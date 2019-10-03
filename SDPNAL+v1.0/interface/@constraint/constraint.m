%%**********************************************************************
%% class def: constraint
%%
%% SDPNAL+: 
%% Copyright (c) 2017 by
%% Yancheng Yuan , Kim-Chuan Toh, Defeng Sun and Xinyuan Zhao
%%**********************************************************************
classdef constraint
    properties
        constr_string
        symmetric_constr
        constr_type
        operator_type
        Operator_Matrix
        active_block
        Constant
        num_constr
        status
    end
    
    methods
        function constr_obj = constraint(info)
            if isfield(info, 'constr_string')
                constr_obj.constr_string = info.constr_string;
            else
                error('''constr_string'' is missing.');
            end
            if isfield(info, 'symmetric_constr')
                constr_obj.symmetric_constr = info.symmetric_constr;
            else
                error('''symmetric_constr'' is missing.');
            end
            if isfield(info, 'constr_type')
                constr_obj.constr_type = info.constr_type;
            else
                error('''constr_type'' is missing.');
            end
            if isfield(info, 'operator_type')
                constr_obj.operator_type = info.operator_type;
            else
                error('''operator_type'' is missing.');
            end
            if isfield(info, 'Operator_Matrix')
                constr_obj.Operator_Matrix = info.Operator_Matrix;
            else
                error('''Operator_Matrix'' is missing.');
            end
            if isfield(info, 'active_block')
                constr_obj.active_block = info.active_block;
            else
                error('''active_block'' is missing.');
            end
            if isfield(info, 'Constant')
                constr_obj.Constant = info.Constant;
            else
                error('''Constant'' is missing.');
            end
            if isfield(info, 'num_constr')
                constr_obj.num_constr = info.num_constr;
            else
                error('''num_constr'' is missing.');
            end
            if isfield(info, 'status')
                constr_obj.status = info.status;
            else
                constr_obj.status = 1;
            end
        end
    end
end