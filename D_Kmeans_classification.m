% use k-means

clear all
close all

%% load features

M = dlmread('PCA_FV60_data.txt');
M = M';

label_vector = dlmread('labels.txt');

%% run k-means

k = 7;

[centers, assignments] = vl_kmeans(M, k);

%% dumb ckeck

T = zeros(7,k);
for i=1:k
    cluster = find(assignments == i);
    T(:,i) = hist(label_vector(cluster),7);
    T(:,i) = T(:,i)/sum(T(:,i));
end

[tmp I] = max(T);
I

