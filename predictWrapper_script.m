% PREDICTWRAPPER_SCRIPT   Generate MEX-function predictWrapper_mex from
%  predictWrapper.
% 
% Script generated from project 'predictWrapper.prj' on 05-Apr-2023.
% 
% See also CODER, CODER.CONFIG, CODER.TYPEOF, CODEGEN.

%% Create configuration object of class 'coder.MexCodeConfig'.
cfg = coder.config('mex');
cfg.TargetLang = 'C++';
cfg.GenerateReport = true;
cfg.EnableJIT = true;

%% Define argument types for entry-point 'predictWrapper'.
ARGS = cell(1,1);
ARGS{1} = cell(1,1);
ARGS_1_1 = struct;
ARGS_1_1.data = coder.typeof(0,[1 14]);
ARGS{1}{1} = coder.typeof(ARGS_1_1);

%% Invoke MATLAB Coder.
codegen -config cfg predictWrapper -args ARGS{1}

