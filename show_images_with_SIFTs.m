SIFT_mat = dlmread('SIFT_data.txt');
M=1;
data_folder='averaged_images/';
i = 4;
% for i=1:M
    str = strcat(data_folder,int2str(i),'.png');    % concatenates two strings that form the name of the image
    eval('img=imread(str);');
   % subplot(ceil(sqrt(M)),ceil(sqrt(M)),i)
    imshow(img)
    %The vl_sift command requires a single precision gray scale image.
    I = single(img);
    line = squeeze(SIFT_mat(i,:));
    nbfeatures = line(1);
    f=zeros(4,nbfeatures);
    for k=1:nbfeatures
        aux = line((2+(k-1)*132):(5+(k-1)*132));
        f(:,k)=aux(:)';
    end
    %disp(sprintf('%i ',size(f)));
    perm = randperm(size(f,2)) ;
    sel = perm(1:nbfeatures) ;
    h1 = vl_plotframe(f(:,sel)) ;
    h2 = vl_plotframe(f(:,sel)) ;
    set(h1,'color','k','linewidth',3) ;
    set(h2,'color','y','linewidth',2) ;
    % h3 = vl_plotsiftdescriptor(d(:,sel),f(:,sel)) ;
    % set(h3,'color','g') ;
% end
