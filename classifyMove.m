function label = classifyMove () %#codegen 
%CLASSIFYX Classify using SVM Model 
%  CLASSIFYX classifies the measurements in X 
%  using the SVM model in the file mySVM.mat, and then 
%  returns class labels in label.

CompactMdl = loadLearnerForCoder('mySVM'); 
label = predict(CompactMdl);
end