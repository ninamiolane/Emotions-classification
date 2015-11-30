% Learn the K clusters associated to the principal weights of
% the SIFTs


clear all
close all
clc

disp('## Script A03: Learn the Kmeans of the PCA weights of local descriptors:');

% Global Parameters
SIFT_type= 'dSIFT';
M=327;
K = 500;

% Input and output file
filename = strcat('data_features/SIFT_perIMG_data.txt');
filename_perSIFT = strcat('data_features/SIFT_data.txt');
output_filename = strcat('Kmeans_centers.mat');

% Read Design matrix
str=sprintf('Loading %s local descriptors from file %s...', SIFT_type, filename_perSIFT);
fprintf(str);
X = dlmread(filename_perSIFT);
fprintf('done.\n');

%% Extract SIFTS
% str = sprintf('Constructing Design matrix A of %s descriptors...',SIFT_type);
% fprintf(str);
% A=[];
% for i=1:M
%     line = squeeze(SIFT_mat(i,:));
%     nbfeatures = line(1);
%     %disp(nbfeatures);
%     d=zeros(128,nbfeatures);
%     for k=1:nbfeatures
%         if strcmp(SIFT_type,'SIFT') % SIFT = position 2D + orientation/scale + 128 dim = 132 dim
%             aux = line((6+(k-1)*132):(6+(k-1)*132)+127);
%         else % dSIFT = orientation/cale + 128 dim = 130 dim
%             aux = line((4+(k-1)*130):(4+(k-1)*130)+127);
%         end
%         d(:,k)=aux(:)';
%     end
%     A = [A d]; % one column = one SIFT
% end
% nSifts=size(A,2); % number of SIFT descriptors.
% %disp(nSifts);
%X=A';
% 
% m = size(X,1); % # of training samples, i.e. total # of SIFTs
% fprintf('done.\n');

%% Un comment for CV
% fprintf('Computing the Kmeans...');
% reverseStr = '';
% 
% %% Learn Kmeans model, with CV for the number numCenters of centers
% 
% k = 10; % number of folds for the k-folds CV
% cv_numData = floor(m/k);
% cv_numsCenters = [10 100 200];
% cv_costs = zeros(length(cv_numsCenters),1);
% i=0;
% for numCenters=cv_numsCenters
%     i=i+1;
%     percentDone = 100 * i / length(cv_numsCenters);
%     msg = sprintf(' : %3.0f%%%%', percentDone);
%     fprintf([reverseStr, msg]);
%     reverseStr = repmat(sprintf('\b'), 1, length(msg)-1);
%     cost = zeros(k,1);
%     for h=1:k
%         % Separate into train and test sets
%         X_test = X(((h-1)*cv_numData+1):(h*cv_numData),:);
%         X_train = X([1:((h-1)*cv_numData+1) ((h*cv_numData)+1):end],:);
%         % Learn the Kmeans model
%         [centers, ~] = vl_kmeans(X_train', numCenters);
%         % Test on the test set: compute the cost
%         IDcenters = knnsearch(centers', X_test);
%         assigned_centers = centers(:,IDcenters)';
%         Loss = X_test - assigned_centers;
%         cost(h) = sum(sum(Loss.^2,2));
%     end
%     cv_costs(i) = mean(cost);
% end
% fprintf('. done.\n');

%% Write Kmean model parameters, for lowest CV-ed cost

% plot(cv_numsCenters, cv_costs);
% [~, I] = min(cv_costs);
% numCenters = cv_numsCenters(I);
% [centers, ~] = vl_kmeans(X', numCenters);

str=sprintf('Computing the Kmeans (K= %d)..', K);
fprintf(str);
[centers, ~] = vl_kmeans(X', K);
fprintf('done.\n');

str=sprintf('Write centers of Kmeans in file %s...', output_filename);
fprintf(str);
dlmwrite(output_filename,centers);
fprintf('done.\n');
