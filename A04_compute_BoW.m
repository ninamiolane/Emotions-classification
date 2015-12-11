% Encode images w. Bag of Words representation

clear all
close all
clc

disp('## Script A04: Compute Bag of Words representation for each image:');

% Global Parameters
SIFT_type= 'dSIFT';
M=327;
withPCA=0;
SPM=1;
norma = 1;

%% Input and output files
Kmeans_filename = strcat('Kmeans_centers.mat');
filename = strcat('data_features/SIFT_perIMG_data.txt');
output_filename = 'data_features/BoW.txt';

%% Load K means
str = sprintf('Loading Kmeans from file %s...',Kmeans_filename);
fprintf(str);
centers = dlmread(Kmeans_filename);
K = size(centers,2);
fprintf('done.\n');

%% Bag of Words encoding

str = sprintf('Loading PCA weights per IMG from file %s...',filename);
fprintf(str);
X=load(filename);
fprintf('done.\n');

% Open file in which we write
fid = fopen(output_filename,'wt');
if SPM
BoW_data = zeros(M,9*K);
else
    BoW_data = zeros(M,K);
end

fprintf('Computing the BoW representations...');
reverseStr = '';

for i=1:M
    percentDone = 100 * i / M;
    msg = sprintf(' : %3.0f%%%%', percentDone);
    fprintf([reverseStr, msg]);
    reverseStr = repmat(sprintf('\b'), 1, length(msg)-1);
    
        BoW = zeros(1,K);
    BoW_line = [];
    
    if withPCA
        % Get PCA weights of the SIFTs for image i
        line = X(i,:);
        nbfeatures = line(1);
        d=zeros(64,nbfeatures);
        for k=1:nbfeatures
            aux = line((2+(k-1)*64):(1+k*64));
            if strcmp(SIFT_type,'SIFT')
                auxpos = line((2+(k-1)*132):(2+(k-1)*132)+1);
            else
                auxpos= line((2+(k-1)*130):(2+(k-1)*130)+1);
            end
            d(:,k)=aux(:)';
            pos(:,k)=auxpos(:)';
        end
    else
        line = X(i,:);
        nbfeatures = line(1);
        d=zeros(128,nbfeatures);
        pos = zeros(2,nbfeatures);
        for k=1:nbfeatures
            if strcmp(SIFT_type,'SIFT')
                aux = line((6+(k-1)*132):(6+(k-1)*132)+127); % extract SIFT
                auxpos = line((2+(k-1)*132):(2+(k-1)*132)+1);
            else
                aux = line((4+(k-1)*130):(4+(k-1)*130)+127); % extract SIFT
                auxpos= line((2+(k-1)*130):(2+(k-1)*130)+1);
                
            end
            d(:,k)=aux(:)';
            pos(:,k)=auxpos(:)';
        end
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
        
        for j=1:9
            str = strcat('zone=zone',int2str(j),';');    % concatenates two strings that form the name of the image
            eval(str);
            d_zone = d(:,zone);
            IDcenters = knnsearch(centers', d_zone');
            % to which center is assignated each PCA-descriptor
            for h=1:K
                BoW(h) = sum(IDcenters==h) ;
            end
            
            if norma
                BoW = BoW.^(0.5); %power renormalization
                BoW = BoW/norm(BoW); %L2 renormalization
            end
            BoW_line=[BoW_line BoW];
                   end
    else
        IDcenters = knnsearch(centers', d'); % to which center is assignated each PCA-descriptor
        for h=1:K
            BoW(h) = sum(IDcenters == h)/nbfeatures; %histogram of centers' assignments
        end
        if norma
            BoW = BoW.^(0.5); %power renormalization
            BoW = BoW/norm(BoW); %L2 renormalization
        end
        BoW_line=BoW;
        %BoW_line
    end
   % BoW_line
    BoW_data(i,:) = BoW_line;
    
    fprintf(fid,'%g\t',BoW_data(i,:));
    fprintf(fid,'\n');
    
end
fprintf(' .done.\n');

str= sprintf('DONE: BoW representations written to file %s',output_filename);
disp(str);
