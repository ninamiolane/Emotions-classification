% perform multi class SVM on data

clear all
close all

addpath('../../Software/liblinear-2.1/matlab');  % add LIBLINEAR to the path

%% chose feature type
M = dlmread('PCA_FV_data.txt');
sparseMatrix = sparse(M);

label_vector = dlmread('labels.txt');

%% options

options = '-s 1 -C -v 10';

%% train model
SVM_model = train(label_vector,sparseMatrix,options);