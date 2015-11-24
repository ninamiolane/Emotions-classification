% Encode images w. Bag of Words representation

clear all
close all
clc

disp('## Script A04: Compute Bag of Words representation for each image:');

% Global Parameters
SIFT_type= 'dSIFT';
M=327;

%% Load K means

Kmeans_filename = strcat('Kmeans_',SIFT_type,'_centers.mat');
str = sprintf('Loading Kmeans from file %s...',Kmeans_filename);
fprintf(str);
centers = dlmread(Kmeans_filename);
K = size(centers,2);
fprintf('done.\n');

%% Bag of Words encoding
filename = strcat('PCAweights_',SIFT_type,'_perIMG_data.txt');
str = sprintf('Loading PCA weights per IMG from file %s...',filename);
X=dlmread(filename);
fprintf('done.\n');

% Open file in which we write
output_filename = 'BoWpca_data.txt';
fid = fopen(output_filename,'wt');
BoW_data = zeros(M,K);

fprintf('Computing the BoW representations...');
reverseStr = '';

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
    IDcenters = knnsearch(centers', d'); % to which center is assignated each PCA-descriptor
    
    
    for h=1:K
        BoW_data(i,h) = sum(IDcenters == h)/K; %histogram of centers' assignments
    end
    
    fprintf(fid,'%g\t',BoW_data(i,:));
    fprintf(fid,'\n');
    
end
fprintf(' .done.\n');

str= sprintf('DONE: BoW representations written to file %s',output_filename);
disp(str);
