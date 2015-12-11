% Extract dense SIFTs of each image
% Write in dSIFT_data.txt

clear all
close all
clc


% Global Parameters
SIFT_type= 'dSIFT';
M=327;

%Input and Output file
data_folder='resized_images/';
filename = strcat('data_features/SIFT_perIMG_data.txt');
filename_perSIFT = strcat('data_features/SIFT_data.txt');

% SIFT Parameters
peak = 2;
edge = 10;

% dSIFT Parameters
step = 3;

%% Start
str = sprintf('## Script A01: Compute  %s local descriptors of each image',SIFT_type);
disp(str);

fid = fopen(filename,'wt');
fid_perSIFT = fopen(filename_perSIFT,'wt');

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
        sift = double(d(:,k)');
        fprintf(fid_perSIFT,'%g\t',sift);
        fprintf(fid_perSIFT,'\n');
        data = [data f(:,k)' double(d(:,k)')];
    end
    %line = [double(nbfeatures) data];
    line = [single(nbfeatures(i)) single(data)]; % for storage purposes
        
    % Write in output file
    fprintf(fid,'%g\t',line);
    fprintf(fid,'\n');
end
fprintf('. done.\n');
str = strcat('Note: average number of descriptors per image =', int2str(mean(nbfeatures)), ' (normally around 30,000 per img!)');
disp(str);


str= sprintf('DONE: local descriptors per image written in file %s', filename);
disp(str);
str= sprintf('and local descriptors written in file %s', filename_perSIFT);
disp(str);



