% perform multi class SVM on data

% clear all
% close all

%addpath('../../Software/liblinear-2.1/matlab');  % add LIBLINEAR to Mika path

addpath('../../../Software/liblinear-2.1/matlab'); % add LIBLINEAR to Nina path

%% chose feature type
filename = 'BoWpca_data.txt';
str = sprintf('Loading images representations from file %s...', filename);
fprintf(str);
M = dlmread(filename,'\t');
sparseMatrix = sparse(M);
fprintf('done.\n');

label_vector = dlmread('labels.txt');

%% options

options = '-s 2 -C -v 10';

%% train model
SVM_model = train(label_vector,sparseMatrix,options);