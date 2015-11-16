I = vl_impattern('roofs1') ;
image(I) ;

%The vl_sift command requires a single precision gray scale image. 
% It also expects the range to be normalized in the [0,255] interval
% (while this is not strictly required, the default values of some internal thresholds are tuned for this case).
%The image I is converted in the appropriate format by
I = single(rgb2gray(I)) ;

%We compute the SIFT frames (keypoints) and descriptors by
[f,d] = vl_sift(I) ;
% The matrix f has a column for each frame. 
% A frame is a disk of center f(1:2), scale f(3) and orientation f(4) .

% % We visualize a random selection of 50 features by:
% perm = randperm(size(f,2)) ;
% sel = perm(1:50) ;
% h1 = vl_plotframe(f(:,sel)) ;
% h2 = vl_plotframe(f(:,sel)) ;
% set(h1,'color','k','linewidth',3) ;
% set(h2,'color','y','linewidth',2) ;

% %We can also overlay the descriptors by:
% h3 = vl_plotsiftdescriptor(d(:,sel),f(:,sel)) ;
% set(h3,'color','g') ;

%% Detector parameters

%The SIFT detector is controlled mainly by two parameters: the peak threshold and the (non) edge threshold.

%% Peak Threshold
%The peak threshold filters peaks of the DoG scale space that are too small (in absolute value).
%For instance, consider a test image of 2D Gaussian blobs:

Itest = double(rand(100,500) <= .005) ; %Creating a test image
Itest = (ones(100,1) * linspace(0,1,500)) .* Itest ;
Itest(:,1) = 0 ; Itest(:,end) = 0 ;
Itest(1,:) = 0 ; Itest(end,:) = 0 ;
Itest = 2*pi*4^2 * vl_imsmooth(Itest,4) ;
Itest = single(255 * Itest) ;

%We run the detector with peak threshold peak_thresh by:
%f = vl_sift(Itest, 'PeakThresh', peak_thresh) ;

[ftest0,dtest0] = vl_sift(Itest, 'PeakThresh', 0) ;
[ftest10,dtest10] = vl_sift(Itest, 'PeakThresh', 10) ;
[ftest20,dtest20] = vl_sift(Itest, 'PeakThresh', 20) ;
[ftest30,dtest30] = vl_sift(Itest, 'PeakThresh', 30) ;

%Visualization
subplot(2,2,1)       % add first plot in 2 x 2 grid
image(Itest);
nbfeatures = size(ftest0,2); % nombre de features est le nombre de columns de ftest
permtest = randperm(size(ftest0,2)) ;
seltest = permtest(1:nbfeatures) ;
h1test = vl_plotframe(ftest0(:,seltest)) ;
h2test = vl_plotframe(ftest0(:,seltest)) ;
set(h1test,'color','k','linewidth',3) ;
set(h2test,'color','y','linewidth',2) ;
title('Subplot 1')

subplot(2,2,2)       % add second plot in 2 x 2 grid

image(Itest);
nbfeatures = size(ftest10,2); % nombre de features est le nombre de columns de ftest
permtest = randperm(size(ftest10,2)) ;
seltest = permtest(1:nbfeatures) ;
h1test = vl_plotframe(ftest10(:,seltest)) ;
h2test = vl_plotframe(ftest10(:,seltest)) ;
set(h1test,'color','k','linewidth',3) ;
set(h2test,'color','y','linewidth',2) ;      % scatter plot
title('Subplot 2')

subplot(2,2,3)       % add third plot in 2 x 2 grid

image(Itest);
nbfeatures = size(ftest20,2); % nombre de features est le nombre de columns de ftest
permtest = randperm(size(ftest20,2)) ;
seltest = permtest(1:nbfeatures) ;
h1test = vl_plotframe(ftest20(:,seltest)) ;
h2test = vl_plotframe(ftest20(:,seltest)) ;
set(h1test,'color','k','linewidth',3) ;
set(h2test,'color','y','linewidth',2) ;
title('Subplot 3')

subplot(2,2,4)       % add fourth plot in 2 x 2 grid

image(Itest);
nbfeatures = size(ftest30,2); % nombre de features est le nombre de columns de ftest
permtest = randperm(size(ftest30,2)) ;
seltest = permtest(1:nbfeatures) ;
h1test = vl_plotframe(ftest30(:,seltest)) ;
h2test = vl_plotframe(ftest30(:,seltest)) ;
set(h1test,'color','k','linewidth',3) ;
set(h2test,'color','y','linewidth',2) ;    % two y axis plot
title('Subplot 4')

%% Edge Threshold
%The edge threshold eliminates peaks of the DoG scale space whose curvature is too small
%(such peaks yield badly localized frames).
%For instance, consider the test image:

I = zeros(100,500) ;
for i=[10 20 30 40 50 60 70 80 90]
I(50-round(i/3):50+round(i/3),i*5) = 1 ;
end
I = 2*pi*8^2 * vl_imsmooth(I,8) ;
I = single(255 * I) ;

%We run the detector with edge threshold edge_thresh by:
f = vl_sift(I, 'edgethresh', 5) ; %test 3.5, 5, 7.5, 10
%obtaining more features as edge_thresh is increased:
image(I);
nbfeatures = size(f,2); % nombre de features est le nombre de columns de ftest
perm = randperm(size(f,2)) ;
sel = perm(1:nbfeatures) ;
h1 = vl_plotframe(f(:,sel)) ;
h2 = vl_plotframe(f(:,sel)) ;
set(h1,'color','k','linewidth',3) ;
set(h2,'color','y','linewidth',2) ;
