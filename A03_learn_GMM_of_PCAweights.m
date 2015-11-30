% Learn the Gaussian Mixture Model associated to the principal weights of
% the SIFTs

clear all
close all
clc

disp('## Script A03: Learn the generative GMM of the PCA weights of local descriptors:');

% Global Parameters
SIFT_type= 'dSIFT';
M=327;
K=30;

%Input file
filename = strcat('data_features/PCAweights_perSIFT_data.txt');

%% Get PCA weights of all SIFTs and PCA first 64 eigenvectors
str = sprintf('Loading matrix %s...', filename);
fprintf(str);
PCASIFT_mat = dlmread(filename); % one line = one projected SIFT
X=PCASIFT_mat'; % one column = one projected SIFT
numFeatures = size(X,2);
%disp(numFeatures);
fprintf('done.\n');

%% Learn GMM model of the keypoints generation
%% UNCOMMENT IF CROSS VALIDATION WANTED
% Set variables for the 10-folds cross-validation
% cv_numFolds = 10;
% cv_numFeatures = floor(numFeatures/cv_numFolds);
% cv_LogL = zeros(2,1);
% i=0;
% x_numCl = [10 30 60 100 500 1000 1200 1500 1800 2000];
% y_numCl = zeros(1, size(x_numCl,2));
% 
% disp('GMM selection: Start cross-validation for clusters number...'); 
% 
% for numCl= 500 %x_numCl
%     i=i+1;
%     str=sprintf('   CV for model with number of clusters= %d: ',numCl);
%     disp(str);
%     LogL = zeros(cv_numFolds,1);
%     for k=1:cv_numFolds
%         str= sprintf('     fold',k,'...');
%         fprintf(str);
%         data_test = X(:,((k-1)*cv_numFeatures+1):(k*cv_numFeatures));
%         data_train = X(:,[1:((k-1)*cv_numFeatures+1) ((k*cv_numFeatures)+1):end]);
%         
%         numClusters = numCl ; %number of modes for the lay of the keypoints
%         [means, covariances, priors] = vl_gmm(data_train, numCl);
%         
%         M = zeros(size(data_test,2),numClusters);
%         
%         for n=1:numCl
%             M(:,n) = mvnpdf(data_test(:,:)',means(:,n)',diag(covariances(:,n)));
%         end
%         
%         baby_LogL = log(M*priors);
%         LogL(k) = sum(baby_LogL);
%          fprintf('done.\n');
%     end
%     cv_LogL(i) = mean(LogL);
%    fprintf('done.\n');
% end
% y_numCl = cv_LogL;
% 
% % Write results of CV for all cluster number
% fprintf('Write vectors of CV: number of clusters in x_numCl.mat and Log-likelihoods in y_numCl.mat...');
% dlmwrite('x_numCl.mat',x_numCl);
% dlmwrite('y_numCl.mat',y_numCl);
% fprintf('done.\n');
% 
% %% Select model with highest CV-ed likelihood
% [~, I] = max(cv_LogL);
% numClusters = x_numCl(I);
% str = sprintf('Cross-validation selects model with %d clusters...',numClusters);
% disp(str);

%% Write GMM parameters
str=sprintf('Compute GMM with nbClusters = %d...',K);
fprintf(str);
[means, covariances, priors] = vl_gmm(X, K); %500 clusters here
fprintf('done.\n');
fprintf('Write GMM CV-ed parameters in files: GMM_means, GMM_covariances, GMM_priors...')
dlmwrite('data_features/GMM_means.mat',means);
dlmwrite('data_features/GMM_covariances.mat',covariances);
dlmwrite('data_features/GMM_priors.mat',priors);
fprintf('done.\n');
