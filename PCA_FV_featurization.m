% clear all;
PCA_SIFT_mat = dlmread('PCA_SIFT_data.txt');
V = dlmread('eigenvectorsSIFT.mat');
%size(V)
data_folder='averaged_images/';


%% Learn GMM model of the keypoints generation
X=PCA_SIFT_mat';

numFeatures = size(X,2) ;
dimension = 64;
data = X ;

numClusters = 60 ; %number of modes for the lay of the keypoints
[means, covariances, priors] = vl_gmm(data, numClusters);


%% Fisher Encoding
M=327;
FV_data = zeros(327,7680);
for i=1:M
data_folder='averaged_images/';
str = strcat(data_folder,int2str(i),'.png');    % concatenates two strings that form the name of the image
eval('img=imread(str);');
%subplot(ceil(sqrt(M)),ceil(sqrt(M)),i)
%imshow(img)
%The vl_sift command requires a single precision gray scale image. 
I = single(img);

%We compute the SIFT frames (keypoints) and descriptors by
[f,d] = vl_sift(I, 'PeakThresh', 5,'edgethresh', 6) ;
%size(d)
w = V'*double(d);
nbfeatures = size(w,2);
numDataToBeEncoded = nbfeatures;
dataToBeEncoded = double(w);
%The Fisher vector encoding enc of these vectors is obtained by calling the vl_fisher function 
%(using the output of the vl_gmm function)
encoding = vl_fisher(dataToBeEncoded, means, covariances, priors);
%size(encoding)
FV_data(i,:)=encoding';
end

% Write this to file.
fid = fopen('PCA_FV60_data.txt','wt');

for ii = 1:size(FV_data,1)
    fprintf(fid,'%g\t',FV_data(ii,:));
    fprintf(fid,'\n');
end
%fclose(fid)

