%% visualize images and keypoints for training and test set

clear all
close all

%% params

v_training_images = 1:10;  % which training images to show (max 7049)
v_test_images = 1:10;      % which test images to show     (max 1783)

% booleans (1 or 0)
visualize_training = 1;
visualize_test = 1;

%time of pause between two images (in s)
pause_length = 1;

load('training.mat');
load('test.mat');

%% training

if visualize_training
    for i=v_training_images
        h = figure(1);
        imagesc(images_training(:,:,i)');
        colormap gray;
        title(sprintf('Training image number %i',i),'FontSize',20)
        hold on;
        scatter(keypoints_training(1,:,i),keypoints_training(2,:,i),100,...
            'ro','LineWidth',2);
        refresh(h);
        pause(pause_length);
    end
end

pause(1);

%% test

if visualize_test
    for i=v_test_images
        figure(2)
        imagesc(images_test(:,:,i)');
        colormap gray;
        title(sprintf('Test image number %i',i),'FontSize',20);
        pause(pause_length);
    end
end