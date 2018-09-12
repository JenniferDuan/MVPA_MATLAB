function [fileName,folderPath,data] =Img2Data_MultiGroup(ifMultiple,NumOfGroup)
% ��һ������.img/.niiת��Ϊ.mat����
% input:
%      NumOfGroup:how many group image
%      ifMultiple='on' OR 'off',�Ƿ�Ϊ����ļ�
% output:
%      data{i}:4D matrix,the 4th dimension is equal to NumOfGroup
%      fileNmae{i}: all image's name
%      folderPath{i}: one group image's path
%
%%
if nargin<1
ifMultiple='on';
end
%%
fileName=cell(1,NumOfGroup);
folderPath=cell(1,NumOfGroup);
data=cell(1,NumOfGroup);
for i=1:NumOfGroup
    [fileName{i},folderPath{i},data{i} ] =...
        Img2Data_LC(ifMultiple,['select image in group ',num2str(i)]);
end
end