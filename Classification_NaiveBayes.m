%% Classification using naive Bayes for Bag of Words

clear all
close all

%%
filename = 'data_features/BoW_3.txt';

M = dlmread(filename,'');
Y = dlmread('data_features/labels.txt');

cv_param = 10;

%%
M = M/min(M(M>0));

numTokens = size(M,2);
accuracy = zeros(cv_param,1);
n = length(Y)/cv_param;
smoothing = 1;

permut = randperm(size(M,1));

for i=1:cv_param
    Mtrain = M([permut(1:floor((i-1)*n)) permut(floor(i*n)+1:end)],:);
    Ytrain = Y([permut(1:floor((i-1)*n)) permut(floor(i*n)+1:end)]);
    Mcv = M(permut(floor((i-1)*n)+1:floor(i*n)),:);
    Ycv = Y(permut(floor((i-1)*n)+1:floor(i*n)));
    numTrainDocs = length(Ytrain);
    
    % train
    for cat=1:7
        phi(cat) = sum(Ytrain == cat)/numTrainDocs;
        phi_ky(:,cat) = ((Ytrain' == cat)*Mtrain + smoothing) / ...
            ((Ytrain' == cat)*sum(Mtrain,2)+numTokens*smoothing);
    end
    
    % test
    P = repmat(log(phi),size(Mcv,1),1) + Mcv*log(phi_ky);
    
    [tmp,L] = max(P');
    accuracy(i) = sum(L' == Ycv)/length(L);
%     disp(sprintf('%i',i));
end

CV_accuracy = mean(accuracy)*100
