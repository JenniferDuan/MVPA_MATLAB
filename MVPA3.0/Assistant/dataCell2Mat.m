function [dataMatCell,nameFirstModality]=dataCell2Mat(dataCell,fileName,numOfFeatureType,loadOrderOfData)
% ��data��cell��ʽת��Ϊdata��.mat��ʽ�������ݱ��Ե�����˳�����data��˳���Է�������Ĵ���
% input��
%      dataCell: cell����ÿ��cell��һ��4D matrix������һ�鱻�Ե�ȫ��data������dimension 4 is the number of subjects
%      NumOfFeatureType: how many type of feature (such as 2 modality: fmri and structure)
%      LoadOrderOfData��data�����ط�ʽ�������Ȱѵ�һ�鱻�Ե����������������أ�
%      Ȼ��...;�����Ȱ��������ĳ����������ȫ�����أ�LoadOrderOfFeature='groupFirst' OR 'featureTypeFirst'��
%      fileName:���б��Ե����֡�A 1* N_group cell, according which the potential different order of individual data
%      were changed into the same order
% output:
%      dataMatCell:cell matrix with dimension 1*NumOfFeatureType. ÿһ��cell��һ���������������ݣ�ά��=dim1*dim2*dim3*N_allSub
%      nameFirstFeature:all subjects' name of the first modality, Note.
%      data order of other modalities were re-ranked according the first
%      one
%%
if nargin<4
    loadOrderOfData= 'groupFirst';
end
if nargin <3
    numOfFeatureType=1;
end
%%
numOfImgGroup=numel(dataCell);
numOfGroup=numOfImgGroup/numOfFeatureType;
dataMatCell=cell(1,numOfFeatureType);
Name=cell(1,numOfFeatureType);
% ��dataֻ������Ԫ��ʱ��˵��ֻ�������飬һ����������
% if numOfImgGroup==2
%     dataMatCell{1}=cat(4,dataCell{1},dataCell{2});
%     Name=cat(1,fileName{1},fileName{2});
% end
%
if numOfImgGroup>=2
    % ���������
    if strcmp(loadOrderOfData,'groupFirst')
        % ����������˳�����������
        for i=1:numOfFeatureType
            dataMat=[];
            name=[];
            countF=1;
            for j=i:numOfFeatureType:numOfImgGroup
                dataMat=cat(4,dataMat,dataCell{j});
                f=@(x) strcat(['G',num2str(countF),'_'],x);
                name_temp=cellfun(f,fileName{j},'UniformOutput',false);
                name=cat(1,name,name_temp);
                countF=countF+1;
            end
            dataMatCell{i}=dataMat;%ĳ�������Ķ�������
            Name{i}=name;
        end
        % ���ǵ����ֵ�˳��(ȫ�����ݵ�һ�����������б��Ե�����˳��)������˳��
        for i=2:numOfFeatureType
            [~,index]=ismember(Name{i},Name{1});
            data_temp=dataMatCell{i};
            dataMatCell{i}=data_temp(:,:,:,index);
        end
    end
    % �����������
    if strcmp(loadOrderOfData,'featureTypeFirst')
        countF=1;
        for i=1:numOfGroup:numOfImgGroup
            dataMat=[];
            name=[];
            countG=1;
            for j=i:1:i+numOfGroup-1
                dataMat=cat(4,dataMat,dataCell{j});
                f=@(x) strcat(['G',num2str(countG),'_'],x);
                name_temp=cellfun(f,fileName{j},'UniformOutput',false);
                name=cat(1,name,name_temp);
                countG=countG+1;
            end
            dataMatCell{countF}=dataMat;%ĳ�������Ķ�������
            Name{countF}=name;
            countF=countF+1;
        end
        % ���ǵ����ֵ�˳��(ȫ�����ݵ�һ�����������б��Ե�����˳��)������˳��
        for i=2:numOfFeatureType
            [~,index]=ismember(Name{i},Name{1});
            data_temp=dataMatCell{i};
            dataMatCell{i}=data_temp(:,:,:,index);
        end
    end
end
nameFirstModality=Name{1};
end