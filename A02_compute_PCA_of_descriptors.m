% Compute PCA on the SIFTs, and keep first 64 components
% Write the eigenvectors matrix in eigenvectors_ ... .mat
% Write the PCA weights of the images in '... _data.txt'

clear all
close all
clc

% Global Parameters
M=327;
SIFT_type = 'dSIFT';
numModes = 64; % number of eigenvectors to keep for PCA

% Input and output files
filename_perIMG = strcat('data_features/SIFT_perIMG_data.txt');
filename_perSIFT = strcat('data_features/SIFT_data.txt');
eigenvectors_filename = strcat('data_features/eigenvectors_data.txt.mat');
weights_perSIFT_filename = strcat('data_features/PCAweights_perSIFT_data.txt');
weights_perIMG_filename = strcat('data_features/PCAweights_perIMG_data.txt');


%data_folder='averaged_images/';

str = sprintf('## Script A02: Compute PCA on the %s local descriptors', SIFT_type);
disp(str);

% Load matrix of (d)SIFTs
str = sprintf('Loading %s descriptors per IMG from file %s...',SIFT_type,filename_perIMG);
fprintf(str);
%SIFT_mat = dlmread(filename_perIMG,'\t'); %,[0 0 5 1]); % one line = one image
SIFT_mat = load(filename_perIMG);
fprintf('done.\n');

%% Extract SIFTS
str = sprintf('Loading %s descriptors per SIFT from file %s...',SIFT_type,filename_perSIFT);
fprintf(str);
%A = dlmread(filename_perSIFT,'\t');
A = load(filename_perSIFT);
%A = A.FV_data;
%,[0 0 5 1]); % one line = one SIFT
A = A';
if (size(A,1)==129)
    A = A(1:128,:);
end
fprintf('done.\n');
% fprintf(str);
% A=[];
% for i=1:M
%     line = squeeze(SIFT_mat(i,:));
%     nbfeatures = line(1);
%     %disp(nbfeatures);
%     d=zeros(128,nbfeatures);
%     for k=1:nbfeatures
%         if strcmp(SIFT_type,'SIFT') % SIFT = position 2D + orientation/scale + 128 dim = 132 dim
%             aux = line((6+(k-1)*132):(6+(k-1)*132)+127);
%         else % dSIFT = orientation/cale + 128 dim = 130 dim
%             aux = line((4+(k-1)*130):(4+(k-1)*130)+127);
%         end
%         d(:,k)=aux(:)';
%     end
%     A = [A d]; % one column = one SIFT
% end
% nSifts=size(A,2); % number of SIFT descriptors.
% %disp(nSifts);
%fprintf('done.\n');

%% Normalize: extract mean and std dev. to standardize the SIFTs?
% For now, assume they are normalized.

%% Compute Eigenvectors and Eigenvalues

fprintf('Eigen-decomposition of Covariance matrix ...');
% Covariance matrix C=A'A, L=AA'
L=A*A';

% vv are the eigenvector for L
% dd are the eigenvalue for both L=dbx'*dbx and C=dbx*dbx';
[vv, dd]=eig(L);

% Eliminate those whose eigenvalue is zero
v=[];
d=[];
for i=1:size(vv,2)
    if(dd(i,i)>1e-4)
        v=[v vv(:,i)];
        d=[d dd(i,i)];
    end
end

% Sort, will return an ascending sequence
[B, index]=sort(d);
ind=zeros(size(index));
dtemp=zeros(size(index));
vtemp=zeros(size(v));
len=length(index);
for i=1:len
    dtemp(i)=B(len+1-i); % take eigenvalues by decreasing order
    ind(i)=len+1-index(i);
    vtemp(:,ind(i))=v(:,i);
end
d=dtemp;
v=vtemp;

% Normalize eigenvectors
for i=1:size(v,2) %access each column
    kk=v(:,i);
    temp=sqrt(sum(kk.^2));
    v(:,i)=v(:,i)./temp;
end
fprintf('done.\n');

%% Take first 64 eigenvectors +  write in file
str = sprintf('Projecting %s descriptors on the first %d eigenvectors...', SIFT_type, numModes);
fprintf(str);
V = v(:,1:numModes);
% Take corresponding 64 weights of each SIFT + write in file
% (one line = one sift)
omega = (V'*A)';
fprintf('done.\n');

%% Write matrix of eigenvectors and matrix of weights
fprintf('Writing matrix of eigenvectors...');
dlmwrite(eigenvectors_filename,V);
fprintf('done.\n');

str= strcat('Writing PCA weights per ',SIFT_type,'...');
fprintf(str)
fid = fopen(weights_perSIFT_filename,'w');
fprintf('done.\n');

for i=1:size(omega,1)
    fprintf(fid,'%g ',omega(i,:));
    fprintf(fid,'\n');
end
fclose(fid);

%% Write PCA weights per image
% (one line = one image)
fprintf('Writing PCA weights per image...');
fid = fopen(weights_perIMG_filename,'w');
for i=1:M
    line = squeeze(SIFT_mat(i,:));
    nbfeatures = line(1);
    B = [];
    B(1) = nbfeatures;
    for k=1:nbfeatures
        if strcmp(SIFT_type,'SIFT') 
        aux = line((6+(k-1)*132):(6+(k-1)*132)+127); % extract SIFT
        else
        aux = line((4+(k-1)*130):(4+(k-1)*130)+127); % extract SIFT

        end
        weights = aux * V; % project SIFT on PCA first 64 eigenvectors
        B = [squeeze(B) squeeze(weights)];
    end
    fprintf(fid,'%g ',B(:));
    fprintf(fid,'\n');
end
fprintf('done.\n');
