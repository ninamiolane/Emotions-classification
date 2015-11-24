% Compute PCA on the SIFTs, and keep first 64 components
% Write the eigenvectors matrix in eigenvectors_ ... .mat
% Write the PCA weights of the images in '... _data.txt'

clear all
close all
clc

% Global Parameters
M=327;
SIFT_type = 'dSIFT';
filename = strcat(SIFT_type,'_data.txt');
data_folder='averaged_images/';
numModes = 64; % number of eigenvectors to keep for PCA

str = sprintf('## Compute PCA on the %s local descriptors', SIFT_type);
disp(str);

% Load matrix of (d)SIFTs
str = sprintf('Loading %s descriptors from file %s...',SIFT_type,filename);
fprintf(str);
SIFT_mat = dlmread(filename); % one line = one image
fprintf('done.\n');

%% Extract SIFTS
str = sprintf('Constructing Design matrix A of %s descriptors...',SIFT_type);
fprintf(str);
A=[];
for i=1:2
    line = squeeze(SIFT_mat(i,:));
    nbfeatures = line(1);
    d=zeros(128,nbfeatures);
    for k=1:nbfeatures
        if strcmp(SIFT_type,'SIFT') % SIFT = position 2D + orientation/scale + 128 dim = 132 dim
            aux = line((6+(k-1)*132):(6+(k-1)*132)+127);
        else % dSIFT = orientation/cale + 128 dim = 130 dim
            aux = line((4+(k-1)*130):(4+(k-1)*130)+127);
        end
        d(:,k)=aux(:)';
    end
    A = [A d]; % one column = one SIFT
end
nSifts=size(A,2); % number of SIFT descriptors.
fprintf('done.\n');

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
eigenvectors_filename = strcat('eigenvectors_',SIFT_type,'.mat');
dlmwrite(eigenvectors_filename,V);
fprintf('done.\n');

str= strcat('Writing PCA weights per ',SIFT_type,'...');
fprintf(str)
weights_file_name = strcat('PCAweights_',SIFT_type,'_per', SIFT_type,'_data.txt');
fid = fopen(weights_file_name,'w');
fprintf('done.\n');

for i=1:size(omega,1)
    fprintf(fid,'%g ',omega(i,:));
    fprintf(fid,'\n');
end
fclose(fid);

%% Write PCA weights per image
% (one line = one image)
fprintf('Writing PCA weights per image...');
weights_file_name = strcat('PCAweights_',SIFT_type,'_perIMG_data.txt');
fid = fopen(weights_file_name,'w');
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
