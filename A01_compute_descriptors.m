% Extract dense SIFTs of each image
% Write in dSIFT_data.txt

clear all
close all
clc


% Global Parameters
SIFT_type= 'dSIFT';
M=327;
data_folder='averaged_images/';

str = sprintf('## Compute  %s local descriptors of each image',SIFT_type);
disp(str);

% SIFT Parameters
peak = 5;
edge = 6;

% dSIFT Parameters
step = 30;

%Fichier dans lequel on ecrit
filename = strcat(SIFT_type,'_data.txt');
fid = fopen(filename,'wt');

if strcmp(SIFT_type,'SIFT')
    str = sprintf('Computing the SIFTs with Peak Threshold = %d and Edge Threshold = %d...',peak, edge);
else
    str = sprintf('Computing the dSIFTs with Step = %d', step);
end

fprintf(str);
reverseStr = '';
nbfeatures = zeros(1,M);
for i=1:M
    percentDone = 100 * i / M;
    msg = sprintf(' : %3.0f%%%%', percentDone);
    fprintf([reverseStr, msg]);
    reverseStr = repmat(sprintf('\b'), 1, length(msg)-1);
    
    str = strcat(data_folder,int2str(i),'.png');    % concatenates two strings that form the name of the image
    eval('img=imread(str);');
    %The vl_sift command requires a single precision gray scale image.
    I = single(img);
    
    if strcmp(SIFT_type,'SIFT') %We compute the SIFT descriptors
        [f,d] = vl_sift(I, 'PeakThresh',peak,'edgethresh', edge) ;
        
    else %We compute the dSIFT descriptors
        [f,d] = vl_dsift(I, 'step',step) ;
    end
    
    nbfeatures(i) = size(f,2);  %nombre de (d)SIFTs est le nombre de colonnes
    % Create line to write
    data = [];
    for k=1:nbfeatures(i)
        data = [data f(:,k)' double(d(:,k)')];
    end
    %line = [double(nbfeatures) data];
    line = [single(nbfeatures(i)) single(data)]; % for storage purposes
    
    
    % Write in output file
    fprintf(fid,'%g\t',line);
    fprintf(fid,'\n');
end
str = strcat('Note: average number of descriptors per image =', mean(nbfeatures));
disp(str);

str= strcat('DONE: local descriptors per image written in file ', filename);
disp(str);
