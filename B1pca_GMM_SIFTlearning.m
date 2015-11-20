% Learn the Gaussian Mixture Model associated to the principal weights of
% the SIFTs


% clear all;
PCA_SIFT_mat = dlmread('PCA_SIFT_data.txt');
V = dlmread('eigenvectorsSIFT.mat');
%size(V)
data_folder='averaged_images/';


%% Learn GMM model of the keypoints generation
X=PCA_SIFT_mat';

numFeatures = size(X,2);
dimension = 64;
data = X ;

cv_numFolds = 10;
cv_numFeatures = floor(numFeatures/cv_numFolds);
cv_LogL = zeros(2,1);
i=0;
for numCl=[1200 1500 1700]
    i=i+1;
    LogL = zeros(cv_numFolds,1);
    for k=1:cv_numFolds
        data_test = data(:,((k-1)*cv_numFeatures+1):(k*cv_numFeatures));
        data_train = data(:,[1:((k-1)*cv_numFeatures+1) ((k*cv_numFeatures)+1):end]);
        
        numClusters = numCl ; %number of modes for the lay of the keypoints
        [means, covariances, priors] = vl_gmm(data_train, numCl);
        
        M = zeros(size(data_test,2),numClusters);
        
        for n=1:numCl
            M(:,n) = mvnpdf(data_test(:,:)',means(:,n)',diag(covariances(:,n)));
        end
        
        baby_LogL = log(M*priors);
        LogL(k) = sum(baby_LogL);
    end
    cv_LogL(i) = mean(LogL);
end

% y_numCl = cv_LogL;
% x_numCl = [10 30 60 100 200 500 1000];
plot(cv_LogL);


