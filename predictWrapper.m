function label = predictWrapper(inputStruct)

%#codegen
% Create a codegen directive to tell MATLAB Coder to generate C++ code for this function

% Extract input data from struct
inputData = inputStruct.data;

trainedModel = loadLearnerForCoder('ensembleTree');
% Make prediction using model
label = predict(trainedModel, inputData);

end