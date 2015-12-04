% Encode images w. Fisher vector representation
% and write in file PCA_FV60_data.txt

clear all
close all
clc

disp('## Script A04: Compute Fisher vector representation of each image');

% Global Parameters
SIFT_type= 'dSIFT';
M=327;
SPM = 1; %Spatial Pyramid Matching
norma = 1;

% Input and output files
filename = strcat('data_features/PCAweights_perIMG_data.txt');
filename_SIFTs = strcat('data_features/SIFT_perIMG_data.txt');
output_filename = strcat('data_features/FV.mat');

%% Load matrix of PCA weights per image:
str = sprintf('Loading projected SIFTs per image from file %s...',filename);
fprintf(str);
X=dlmread(filename);
fprintf('done.\n');

%% Load matrix of SIFTs per image:
str = sprintf('Loading SIFTs per image from file %s...',filename_SIFTs);
fprintf(str);
SIFT_mat=load(filename_SIFTs);
fprintf('done.\n');

%% Load learned parameters of the GMM
fprintf('Loading means, covariances and priors of the GMM model ');
means=dlmread('data_features/GMM_means.mat');
K = size(means,2);
str= sprintf('(number of Gaussians = %d)...',K);
fprintf(str);
covariances = dlmread('data_features/GMM_covariances.mat');
priors = dlmread('data_features/GMM_priors.mat');
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
    SIFTs = SIFT_mat(i,:);
    nbfeatures = line(1);
    d=zeros(64,nbfeatures);
    pos = zeros(2,nbfeatures);
    for k=1:nbfeatures
        
        aux = line((2+(k-1)*64):(1+k*64));
        d(:,k)=aux(:)';
        if strcmp(SIFT_type,'SIFT')
            aux = SIFTs((2+(k-1)*132):(2+(k-1)*132)+1);
        else
            aux= SIFTs((2+(k-1)*130):(2+(k-1)*130)+1);
        end
        pos(:,k)= aux(:)';
    end
    
    
    if SPM
        zone1 = intersect(find(pos(1,:)<=38.4),find(pos(2,:)<=32));
        zone2 = intersect(intersect(find(pos(1,:)<=38.4),find(pos(2,:)<=72)),find(pos(2,:)>=32));
        zone3 = intersect(find(pos(1,:)<=38.4),find(pos(2,:)>=72));
        zone4 = intersect(intersect(find(pos(1,:)>=38.4),find(pos(1,:)<=57.6)),find(pos(2,:)<=32));
        zone5 = intersect(intersect(intersect(find(pos(1,:)>=38.4),find(pos(1,:)<=57.6)),find(pos(2,:)<=72)),find(pos(2,:)>=32));
        zone6 = intersect(intersect(find(pos(1,:)>=38.4),find(pos(1,:)<=57.6)),find(pos(2,:)>=72));
        zone7 = intersect(find(pos(1,:)>=57.6),find(pos(2,:)<=32));
        zone8 = intersect(intersect(find(pos(1,:)>=57.6),find(pos(2,:)<=72)),find(pos(2,:)>=32));
        zone9 = intersect(find(pos(1,:)>=57.6),find(pos(2,:)>=72));
        FV = [];
        for j=1:9
            str = strcat('zone=zone',int2str(j),';');    % concatenates two strings that form the name of the image
            eval(str);
            d_cell = d(:,zone);
            encoding = vl_fisher(double(d_cell), means, covariances, priors);
            FVaux = encoding(:)';
            %Renormalization of Fisher vector
            if norma
            FVaux = (abs(FVaux).^(0.5)).*sign(FVaux); %power renormalization
            FVaux = FVaux/norm(FVaux); %L2 renormalization
            end
            FV = [FV FVaux];
        end
        
    else
        
        % Encode the image from its PCA weights, using the FV representation
        dataToBeEncoded = double(d);
        encoding = vl_fisher(dataToBeEncoded, means, covariances, priors);
        FV = encoding(:)';
        %Renormalization of Fisher vector
        if norma
        FV = (abs(FV).^(0.5)).*sign(FV); %power renormalization
        FV = FV/norm(FV); %L2 renormalization
        end
    end
    % Fill the matrix of images representation
    FV_data(i,1:numel(FV))=FV;
end
fprintf('. done.\n');

%% Write FV representations to file
str=sprintf('Writing Fisher Vector representation in file: %s...', output_filename);
fprintf(str);
% fid = fopen('FV_GMM1000_data.mat','wt');
save(output_filename,'FV_data','-v7.3');

% for i = 1:size(FV_data,1)
%     fprintf(fid,'%g\t',FV_data(i,1:128000));
%     fprintf(fid,'\n');
% end
% %fclose(fid)
fprintf('done.\n');
