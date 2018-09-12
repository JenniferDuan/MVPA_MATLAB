function [label]=generateLabel(dataCell,numOfFeatureType,loadOrderOfData)
% ����data������label��������ÿ��group�ı��Ը���
% input��
%      dataCell: cell����ÿ��cell��һ��4D matrix������һ�鱻�Ե�ȫ��data������dimension 4 is
%      number of subjects
%      NumOfFeatureType: �ж��ٸ���������
%      LoadOrderOfFeature�����������ط�ʽ�������Ȱѵ�һ�鱻�Ե����������������أ�
%      Ȼ��...;�����Ȱ��������ĳ����������ȫ�����أ�LoadOrderOfFeature='groupFirst' OR 'featureTypeFirst'��
% output:
%      label:���б��Ե�label��N_all*1 array, N_all=number of all
%      subjects��ֵ��ע�⣺��ֻ������ʱ������load��group��label��󣬱��繲��2�飬���һ��load��group
%      labelΪ2
%      numOfSub: ÿ�鱻�Եĸ���, N_group*1��N_group=number of group
%
%
%%
if nargin<3
    loadOrderOfData= 'groupFirst';
end
if nargin <2
    numOfFeatureType=1;
end
%%
numOfImgGroup=numel(dataCell);
label=[];
% ��dataֻ������Ԫ��ʱ��˵��ֻ�������飬һ����������
if numOfImgGroup==2
    label=[ones(size(dataCell{1},4),1);ones(size(dataCell{2},4),1)+1];
end
%
if numOfImgGroup>2
    % ���������
    if strcmp(loadOrderOfData,'groupFirst')
        count=0;
        for i=1:numOfFeatureType:numOfImgGroup
            label=cat(1,label,ones(size(dataCell{i},4),1)+count);
            count=count+1;
        end
    end
    % �����������
    if strcmp(loadOrderOfData,'featureTypeFirst')
        numOfGroup=numOfImgGroup/numOfFeatureType;
        count=0;
        for i=1:numOfGroup
            label=cat(1,label,ones(size(dataCell{i},4),1)+count);
            count=count+1;
        end
    end
end
end