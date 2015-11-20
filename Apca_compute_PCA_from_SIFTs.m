% Principal Component Analysis on the SIFT of the images
% Keep the first 64 components, according to litt. ref.

clear all
close all
clc

M=327;
SIFT_mat = dlmread('SIFT_data.txt');
data_folder='averaged_images/';
%
A=[];
for i=1:M
     line = squeeze(SIFT_mat(i,:));
    nbfeatures = line(1);
    d=zeros(128,nbfeatures);
    for k=1:nbfeatures
        aux = line((6+(k-1)*132):(6+(k-1)*132)+127);
        d(:,k)=aux(:)';
    end 
    A = [A d];
end
% number of SIFT descriptors.
nSifts=size(A,2);

%showim = 25;

%% Chosen std and mean.
% It can be any number that it is close to the std and mean of most of the images.
um=100;
ustd=55;




%% Covariance matrix C=A'A, L=AA'
L=A*A';
% vv are the eigenvector for L
% dd are the eigenvalue for both L=dbx'*dbx and C=dbx*dbx';
[vv dd]=eig(L);
% Sort and eliminate those whose eigenvalue is zero
v=[];
d=[];
for i=1:size(vv,2)
    if(dd(i,i)>1e-4)
        v=[v vv(:,i)];
        d=[d dd(i,i)];
    end
end

%% sort, will return an ascending sequence
[B index]=sort(d);
ind=zeros(size(index));
dtemp=zeros(size(index));
vtemp=zeros(size(v));
len=length(index);
for i=1:len
    dtemp(i)=B(len+1-i);
    ind(i)=len+1-index(i);
    vtemp(:,ind(i))=v(:,i);
end
d=dtemp;
v=vtemp;


%% Normalization of eigenvectors
for i=1:size(v,2) %access each column
    kk=v(:,i);
    temp=sqrt(sum(kk.^2));
    v(:,i)=v(:,i)./temp;
end


%% Take the first 64 eigenvectors
numModes = 64;
V = v(:,1:numModes);

%% Extract the corresponding weights
omega = (V'*A)';


%% write file of weights
weights_file_name = 'PCA_SIFT_data.txt';

dlmwrite('eigenvectorsSIFT.mat',V);

fid = fopen(weights_file_name,'w');
%size(omega)
for i=1:size(omega,1)
    fprintf(fid,'%g ',omega(i,:));
    fprintf(fid,'\n');
end
fclose(fid);
