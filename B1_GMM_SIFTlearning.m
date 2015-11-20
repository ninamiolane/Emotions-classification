% clear all;
SIFT_mat = dlmread('SIFT_data.txt');
M=8;
data_folder='averaged_images/';


%% Learn GMM model of the keypoints generation
X=[];
for i=1:M
     line = squeeze(SIFT_mat(i,:));
    nbfeatures = line(1);
    d=zeros(128,nbfeatures);
    for k=1:nbfeatures
        aux = line((6+(k-1)*132):(6+(k-1)*132)+127);
        d(:,k)=aux(:)';
    end 
    X = [X d];
end

numFeatures = size(X,2) ;
dimension = 128 ;
data = X;

numClusters = 30 ; %number of modes for the lay of the keypoints
[means, covariances, priors] = vl_gmm(data, numClusters);