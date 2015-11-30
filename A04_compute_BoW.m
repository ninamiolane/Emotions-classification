% Encode images w. Bag of Words representation

clear all
close all
clc

disp('## Script A04: Compute Bag of Words representation for each image:');

% Global Parameters
SIFT_type= 'dSIFT';
M=327;
withPCA=0;

%% Input and output files
Kmeans_filename = strcat('Kmeans_centers.mat');
filename = strcat('data_features/SIFT_perIMG_data.txt');
output_filename = 'data_features/BoW_1.txt';

%% Load K means
str = sprintf('Loading Kmeans from file %s...',Kmeans_filename);
fprintf(str);
centers = dlmread(Kmeans_filename);
K = size(centers,2);
fprintf('done.\n');

%% Bag of Words encoding

str = sprintf('Loading PCA weights per IMG from file %s...',filename);
fprintf(str);
X=dlmread(filename);
fprintf('done.\n');

% Open file in which we write
fid = fopen(output_filename,'wt');
BoW_data = zeros(M,K);

fprintf('Computing the BoW representations...');
reverseStr = '';

for i=1:M
    percentDone = 100 * i / M;
    msg = sprintf(' : %3.0f%%%%', percentDone);
    fprintf([reverseStr, msg]);
    reverseStr = repmat(sprintf('\b'), 1, length(msg)-1);
    
    if withPCA
        % Get PCA weights of the SIFTs for image i
        line = X(i,:);
        nbfeatures = line(1);
        d=zeros(64,nbfeatures);
        for k=1:nbfeatures
            aux = line((2+(k-1)*64):(1+k*64));
            d(:,k)=aux(:)';
        end
    else
        line = X(i,:);
        nbfeatures = line(1);
        d=zeros(128,nbfeatures);
        for k=1:nbfeatures
            if strcmp(SIFT_type,'SIFT')
                aux = line((6+(k-1)*132):(6+(k-1)*132)+127); % extract SIFT
            else
                aux = line((4+(k-1)*130):(4+(k-1)*130)+127); % extract SIFT
                
            end
            d(:,k)=aux(:)';
        end
    end
    IDcenters = knnsearch(centers', d'); % to which center is assignated each PCA-descriptor
    
    
    for h=1:K
        BoW_data(i,h) = sum(IDcenters == h)/nbfeatures; %histogram of centers' assignments
    end
    
    fprintf(fid,'%g\t',BoW_data(i,:));
    fprintf(fid,'\n');
    
end
fprintf(' .done.\n');

str= sprintf('DONE: BoW representations written to file %s',output_filename);
disp(str);
