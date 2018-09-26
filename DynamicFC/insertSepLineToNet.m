function netWithSepLine=insertSepLineToNet(net,sepIndex)
% 此代码的功能：在一个网络矩阵种插入网络分割线，此分割线将不同的脑网络分开
% input
%   net:一个网络矩阵，N*N,N为节点个数，必须为对称矩阵
%   sepIndex:分割线的index，为一个向量，比如[3,9]表示网络分割线分别位于3和9后面
% output
%   netWithSepLine:带有分割线的网络

%%
net=meanStd;
sepIndex=[5,10,17,28,30,44,57,57+[5,10,17,28,30,44]];
if size(net,1)~=size(net,2)
    error('不是对称矩阵');
end
nNetNode=length(net);
nLine=length(sepIndex);
netWithSepLine=inf(nNetNode+nLine,nNetNode+nLine);
sepIndex=sort(sepIndex)+(1:nLine);
index=setdiff((1:nNetNode+nLine), sepIndex);
netWithSepLine(index,index)=net;
%%
figure
% [i,j]=find(net>cutpoint);
% node=intersect(i,j);
% img='D:\myCodes\Github_Related\Github_Code\Template_CBIG\stable_projects\brain_parcellation\Yeo2011_fcMRI_clustering\1000subjects_reference\Yeo_JNeurophysiol11_SplitLabels\MNI152\Yeo2011_17Networks_N1000.split_components.FSL_MNI152_1mm.nii.gz'
% img=load_nii(img);
% img=img.img;
% zeroNode=setdiff(unique(img(:)),node);
% Data2Img_LC(img,'img.nii');
% img(ismember(img,zeroNode))=0;
imagesc(net)
colormap(jet)
figure
sorted=netWithSepLine(:);
sorted(isnan(sorted)|isinf(sorted))=0;
sorted=sort(sorted,'descend');
% cutpoint=sorted(fix(length(sorted)*0.001));
cutpoint=sorted(100);
netWithSepLine(netWithSepLine<=cutpoint)=0;
netWithSepLine(isnan(netWithSepLine))=0;
imagesc(netWithSepLine)
colormap(jet)
axis off