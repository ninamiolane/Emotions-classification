clear all
close all

%% setup MatConvNet
run  matconvnet-1.0-beta16/matlab/vl_setupnn

%% load the pre-trained CNN
% net = load('matconvnet-1.0-beta16/imagenet-vgg-f.mat') ;
net = load('matconvnet-1.0-beta16/examples/data/models/vgg-face.mat') ;

% ConvNet_features = zeros(327,1000);
ConvNet_features = zeros(327,4096);

%%

for i=1:327
    if mod(i,25) == 0
        i
    end
    % load and preprocess an image
    imgname = ['averaged_images/' int2str(i) '.png'];
    im = imread(imgname) ;
    im = im(1:250,:,:) ; % crop
    im_ = single(im) ; % note: 255 range
    im_ = imresize(im_, net.normalization.imageSize(1:2)) ;
    im_ = bsxfun(@minus,im_,net.normalization.averageImage) ;

    % run the CNN
    res = vl_simplenn(net, im_) ;
    tmp = squeeze(res(end-2).x);
    ConvNet_features(i,:) = tmp / norm(tmp);
end

%% save results
save('data_features/convnet_vgg-face_l-2.mat','ConvNet_features','-v7.3');


