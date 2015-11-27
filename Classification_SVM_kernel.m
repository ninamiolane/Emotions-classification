% perform multi class SVM on data with a kernel

% clear all
% close all

addpath('../Matlab/libsvm-3.20/matlab');  % add LIBSVM to Mika path

%addpath('../../../Software/liblinear-2.1/matlab'); % add LIBSVM to Nina path

%% chose feature type
filename = 'data_features/BoW_step30_K500_data.txt';
str = sprintf('Loading images representations from file %s...', filename);
fprintf(str);
M = dlmread(filename,'');
sparseMatrix = sparse(M);
fprintf('done.\n');

label_vector = dlmread('data_features/labels.txt');

%% options

options = '-v 10 -q';

%% train model
SVM_model = svmtrain(label_vector,sparseMatrix,options);
