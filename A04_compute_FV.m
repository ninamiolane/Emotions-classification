% Encode images w. Fisher vector representation
% and write in file PCA_FV60_data.txt

clear all
close all
clc

disp('## Script C1pca: Compute Fisher vector representation of each image');

% Global Parameters
SIFT_type= 'dSIFT';
M=327;
filename = strcat('PCAweights_',SIFT_type,'_perIMG_data.txt');

%% Load matrix of PCA weights per image:
str = sprintf('Loading projected SIFTs per image from file %s...',filename);
fprintf(str);
X=dlmread(filename);
fprintf('done.\n');

%% Load learned parameters of the GMM
fprintf('Loading means, covariances and priors of the GMM model ');
means=dlmread('GMM_means.mat');
K = size(means,2);
str= sprintf('(number of Gaussians = %d)...',K);
fprintf(str);
covariances = dlmread('GMM_covariances.mat');
priors = dlmread('GMM_priors.mat');
fprintf('done.\n');

%% Compute the FV representation for each image i
fprintf('Computing the FV representations...');
reverseStr = '';

FV_data = zeros(M,[]);
for i=1:M
    percentDone = 100 * i / M;
    msg = sprintf(' : %3.0f%%%%', percentDone);
    fprintf([reverseStr, msg]);
    reverseStr = repmat(sprintf('\b'), 1, length(msg)-1);
    
    % Get PCA weights of the SIFTs for image i 
    line = X(i,:);
    nbfeatures = line(1);
    d=zeros(64,nbfeatures);
    for k=1:nbfeatures
        aux = line((2+(k-1)*64):(1+k*64));
        d(:,k)=aux(:)';
    end
    
    % Encode the image from its PCA weights, using the FV representation
    dataToBeEncoded = double(d);
    encoding = vl_fisher(dataToBeEncoded, means, covariances, priors);
    % Fill the matrix of images representation
    FV_data(i,1:numel(encoding))=encoding(:)';
end
fprintf('. done.\n');

%% Write FV representations to file
output_filename = strcat('FV_dSIFT_data.mat');
str=strcat('Writing Fisher Vector representation in file: %s', output_filename);
fprintf(str);
% fid = fopen('FV_GMM1000_data.mat','wt');
save(output_filename,'FV_data','-v7.3');

% for i = 1:size(FV_data,1)
%     fprintf(fid,'%g\t',FV_data(i,1:128000));
%     fprintf(fid,'\n');
% end
% %fclose(fid)
fprintf('done.\n');
