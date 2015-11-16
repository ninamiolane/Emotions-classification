
M=327;
data_folder='averaged_images/';

%Fichier dans lequel on ecrit
fid = fopen('SIFT_data.txt','wt');

for i=1:M
    str = strcat(data_folder,int2str(i),'.png');    % concatenates two strings that form the name of the image
    eval('img=imread(str);');
    %The vl_sift command requires a single precision gray scale image.
    I = single(img);
    
    %We compute the SIFT frames (keypoints) and descriptors by
    [f,d] = vl_sift(I, 'PeakThresh',5,'edgethresh', 6) ;
    nbfeatures = size(f,2);  %nombre de keypoints est le nombre de colonnes
    % Create line to write
    data = [];
    for k=1:nbfeatures
        data = [data f(:,k)' double(d(:,k)')];
    end
    line = [double(nbfeatures) data];
    
    % Write
    fprintf(fid,'%g\t',line);
    fprintf(fid,'\n');
end

