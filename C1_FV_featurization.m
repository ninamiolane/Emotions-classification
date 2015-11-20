


%% Fisher Encoding
M=327;
FV_data = zeros(327,7680);
for i=1:M
data_folder='averaged_images/';
str = strcat(data_folder,int2str(i),'.png');    % concatenates two strings that form the name of the image
eval('img=imread(str);');
%subplot(ceil(sqrt(M)),ceil(sqrt(M)),i)
%imshow(img)
%The vl_sift command requires a single precision gray scale image. 
I = single(img);

%We compute the SIFT frames (keypoints) and descriptors by
[f,d] = vl_sift(I, 'PeakThresh', 5,'edgethresh', 6) ;
nbfeatures = size(d,2);
numDataToBeEncoded = nbfeatures;
dataToBeEncoded = double(d);
%The Fisher vector encoding enc of these vectors is obtained by calling the vl_fisher function 
%(using the output of the vl_gmm function)
encoding = vl_fisher(dataToBeEncoded, means, covariances, priors);
FV_data(i,:)=encoding';
end

% Write this to file.
fid = fopen('FV_data.txt','wt');

for ii = 1:size(FV_data,1)
    fprintf(fid,'%g\t',FV_data(ii,:));
    fprintf(fid,'\n');
end
%fclose(fid)

