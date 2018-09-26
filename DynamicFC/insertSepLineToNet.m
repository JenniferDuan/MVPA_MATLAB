function netWithSepLine=insertSepLineToNet(net,sepIndex)
% �˴���Ĺ��ܣ���һ����������ֲ�������ָ��ߣ��˷ָ��߽���ͬ��������ֿ�
% input
%   net:һ���������N*N,NΪ�ڵ����������Ϊ�Գƾ���
%   sepIndex:�ָ��ߵ�index��Ϊһ������������[3,9]��ʾ����ָ��߷ֱ�λ��3��9����
% output
%   netWithSepLine:���зָ��ߵ�����

%%
net=meanStd;
sepIndex=[5,10,17,28,30,44,57,57+[5,10,17,28,30,44]];
if size(net,1)~=size(net,2)
    error('���ǶԳƾ���');
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