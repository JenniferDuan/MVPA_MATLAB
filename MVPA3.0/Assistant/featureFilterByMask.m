function [dataFilter,maskForFilter]=featureFilterByMask(data,maskForFilter,maskType)
% filter features outside a binary mask
% input��
%     data��4D matrix with dim4 is number of subject
%     maskForFilter��3D binary matrix
%     maskType:the implicit mask or the out external mask ('implicit' OR 'external')
% output:
%     dataFilter:filtered features, 4D matrix have the same dimension as the data
%     maskForFilter:reshaped mask
% 2018-03-08 by Lichao
if nargin<3
    maskType='implicit';
end
%%
[dim1,dim2,dim3,N]=size(data);
dataFilter=reshape(data,[dim1*dim2*dim3,N]);%�з���Ϊ��������ÿһ��Ϊһ��������ÿһ��Ϊһ������
if strcmp(maskType,'implicit')
    maskForFilter = sum(dataFilter,2)~=0;%�ڲ�mask,�����ۼ�
    dataFilter=dataFilter(maskForFilter,:);%�ڲ�mask�ڵ�data
    dataFilter=dataFilter';
    maskForFilter=maskForFilter';
else
    maskForFilter=reshape(maskForFilter,dim1*dim2*dim3,1);
    dataFilter=dataFilter(maskForFilter,:);
    dataFilter=dataFilter';
    maskForFilter=maskForFilter';
end
end