%% Softmax regression

clear all
close all

%% load parameters

%Mt = dlmread('data_features/PCA_FV_data.txt');
Mt = dlmread('BoWpca_data.txt');
Y = dlmread('data_features/labels.txt');

%% softmax regression

M = Mt(:,1:10);

cv_param = 10;
accuracy = zeros(cv_param,1);
n = length(Y)/cv_param;

parfor i=1:cv_param
    Mtrain = M([1:floor((i-1)*n) floor(i*n)+1:end],:);
    Ytrain = Y([1:floor((i-1)*n) floor(i*n)+1:end]);
    Mcv = M(floor((i-1)*n)+1:floor(i*n),:);
    Mcv = [ones(size(Mcv,1),1) Mcv];
    Ycv = Y(floor((i-1)*n)+1:floor(i*n));
    Theta = mnrfit(Mtrain,Ytrain);
    
    P = exp(Mcv*Theta);
    P = P./repmat(1+sum(P,2),1,size(P,2));
    P = [P 1-sum(P,2)];
    [tmp,L] = max(P');
    accuracy(i) = sum(L' == Ycv)/length(L);
%     disp(sprintf('%i',i));
end

CV_accuracy = mean(accuracy)*100

exit;