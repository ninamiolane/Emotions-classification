% Learn the K clusters associated to the principal weights of
% the SIFTs


clear all
close all
clc

disp('## Script A03: Learn the Kmeans of the PCA weights of local descriptors:');

% Global Parameters
SIFT_type= 'dSIFT';
M=327;
filename = strcat('PCAweights_',SIFT_type,'_per', SIFT_type,'_data.txt');

% Read Design matrix
str=sprintf('Loading %s local descriptors from file %s...', SIFT_type, filename);
fprintf(str);
X = dlmread(filename);
m = size(X,1); % # of training samples, i.e. total # of SIFTs
fprintf('done.\n');

fprintf('Computing the Kmeans...');
reverseStr = '';

%% Learn Kmeans model, with CV for the number numCenters of centers

k = 10; % number of folds for the k-folds CV
cv_numData = floor(m/k);
cv_numsCenters = [10 100 200];
cv_costs = zeros(length(cv_numsCenters),1);
i=0;
for numCenters=cv_numsCenters
    i=i+1;
      percentDone = 100 * i / length(cv_numsCenters);
    msg = sprintf(' : %3.0f%%%%', percentDone);
    fprintf([reverseStr, msg]);
    reverseStr = repmat(sprintf('\b'), 1, length(msg)-1);
    cost = zeros(k,1);
    for h=1:k
        % Separate into train and test sets
        X_test = X(((h-1)*cv_numData+1):(h*cv_numData),:);
        X_train = X([1:((h-1)*cv_numData+1) ((h*cv_numData)+1):end],:);
        % Learn the Kmeans model
        [centers, ~] = vl_kmeans(X_train', numCenters);
        % Test on the test set: compute the cost
        IDcenters = knnsearch(centers', X_test);
        assigned_centers = centers(:,IDcenters)';
        Loss = X_test - assigned_centers;
        cost(h) = sum(sum(Loss.^2,2));
    end
    cv_costs(i) = mean(cost);
end
fprintf('. done.\n');
%% Write Kmean model parameters, for lowest CV-ed cost

plot(cv_numsCenters, cv_costs);
[~, I] = min(cv_costs);
numCenters = cv_numsCenters(I);
[centers, ~] = vl_kmeans(X', numCenters);

output_filename = strcat('Kmeans_', SIFT_type,'_centers.mat');
str=sprintf('Write centers of Kmeans in file %s...', output_filename);
fprintf(str);
dlmwrite(output_filename,centers);
fprintf('done.\n');
