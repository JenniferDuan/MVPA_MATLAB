function [AUC,Accuracy,Sensitivity,Specificity] =...
    MVPA_PCA_nestedRFE2(opt,dataMat,label)
%=========Classification using PCA and RFE========================
% usage��
%       
%      refer to��Multivariate classification of social anxiety disorder
%      using whole brain functional connectivity�� and PMID:18672070��
%      1. �˴��뱣���Ȩ��ͼΪN-fold��consensus��ƽ��Ȩ��ͼ��
%      2. ����fitclinear��indices������ԣ�ÿ�εĽ�������в��죡����
%      3. �ڿ�ʼRFE֮ǰ���Լ��뵥�������������˻���������ά����F-score ��opt.Kendall Tau��Two-sample
%      t-test�ȣ��˴�����PCA��ά��
%      4. �˴����õ���nested RFE
% input��
%        opt.K=K-fold cross validation(opt.K<=N)        
%        [opt.Initial_FeatureQuantity,opt.Max_FeatureQuantity,opt.Step_FeatureQuantity]=[��ʼ��������,���������,ÿ�����ӵ�������]
%        opt.P_threshold =�����������������ǵ�P��ֵ;
%        opt.percentage_consensus=K fold��ĳ��Ȩ�ز�Ϊ������س��ֵĸ���
%        ��opt.percentage_consensus=0.8��opt.K=5�������5*0.8=4�����ϵ����ز���Ϊ��consensus���ء�
% output��
%        ��������Լ�K-fold��ƽ������Ȩ��(����ֱ�ӱ���Ϊ.mat�ļ�)
% new:
%         nested RFE �ҵ���ѵ�������Ŀ���������ѵ������������������Ŀ����ģ��
%% set options
if nargin<1
    % mask :'implicit' OR 'external'
    opt.maskSource='implicit';
    % how many modality/feature types
    opt.numOfFeatureType=1;
    % permutation test
    opt.permutation=0;
    % K fold CV
    opt.K=5;
    opt.innerK=10;
    % load old indices
    opt.IfLoadIndices=0;
    % standardization
    opt.standard='normalizing';
    opt.min_scale=0;
    opt.max_scale=1;
    % univariate feature filter.
    opt.P_threshold=0.1;
    % RFE
    opt.learner='fitclinear';
    opt.stepmethod='percentage';
    opt.step=5;
    % feature subset
    opt.Initial_FeatureQuantity=10;
    opt.Max_FeatureQuantity=5000;
    opt.Step_FeatureQuantity=50;
    % classifier
    classifier=@fitclinear;
    % calculate weight map
    opt.weight=1;
    % The frequence of the occurrence of the same voxels/features which used to generate weight map; range=(0,1];
    opt.percentage_consensus=0.4;
    % view performances
    opt.viewperformance=1;
    % save results
    opt.saveresults=1;
end
%% ===============image to data and produce label==================
% ������û������򲻶�ͼ����������һ������ṩ
% data
if nargin<2
    [fileName,folderPath,dataCell] =Img2Data_MultiGroup('on',2);
    path=folderPath{1};
    name_patients=fileName{1};
    name_controls=fileName{2};
    [dataMatCell]=dataCell2Mat(dataCell,opt.numOfFeatureType,'groupFirst');% ���������䵽����cell
    dataMat=dataMatCell{1};
end
% label
if nargin<3
    [label]=generateLabel(dataCell,opt.numOfFeatureType, 'groupFirst');
end
[dim1,dim2,dim3,~]=size(dataMat);
%% ===========just keep data in mask,and reshape data=============
% ������������ڵ�2ά���ϵ��ӣ�����mask��ɸѡ
data_inmask=[];
maskForFilter=[];
for ith_featureType=1:opt.numOfFeatureType
    [data_inmask_temp,maskForFilter_temp]=featureFilterByMask(dataMatCell{ith_featureType},[],opt.maskSource);
    data_inmask=cat(2,data_inmask,data_inmask_temp);
    maskForFilter=cat(1,maskForFilter,maskForFilter_temp);
end
%% ȷ���Ƿ��������еĽ�����֤��ʽ,��Ϊ����ȷ����Щ�������಻����׼��
if ~opt.permutation
    % �������û�����ʱ���͸����û���ȷ���Ƿ��������еĽ�����֤��ʽ
    if opt.IfLoadIndices==0
        indiceCell=generateIndiceForKfoldCV(label,opt.K);
    else
        [~,indices_p,indices_c]=LoadIndices();
    end
else
    % �����û�����ʱ������ƽ�����֤
    indiceCell=generateIndiceForKfoldCV(label,opt.K);
end
% �������û�����ʱ����ȷ���ļ�����˳��Ϊ���ı�����Щ�������಻����׼��
indices_p=indiceCell{1};
indices_c=indiceCell{2};
name_all_sorted=SortNameAccordIndices(name_patients,name_controls,indices_p,indices_c,opt);

%% =======================Ԥ����ռ�===============================
Accuracy=zeros(opt.K,1);
Sensitivity =zeros(opt.K,1);
Specificity=zeros(opt.K,1);
AUC=zeros(opt.K,1);
Decision=cell(opt.K,1);
PPV=zeros(opt.K,1); 
NPV=zeros(opt.K,1);
%
W_M_Brain=zeros(1,dim1*dim2*dim3);
W_Brain=zeros(opt.K,sum(maskForFilter));
label_ForPerformance=cell(opt.K,1);
labelPredict=cell(opt.K,1);
%%  ====================K fold loop===============================
tic;
h=waitbar(0,'��ȴ� Outer Loop>>>>>>>>','Position',[50 50 280 60]);
% Outer K-fold + Inner RFE
for i=1:opt.K
    waitbar(i/opt.K,h,sprintf('%2.0f%%', i/opt.K*100)) ;
    % balance split
    [dataTrain,dataTest,labelTrain,labelTest]=...
        BalancedSplitDataAndLabel(data_inmask,label,indiceCell,i);
    label_ForPerformance{i}=labelTest;
    % standardization
    [dataTrain,dataTest]=Standardization(dataTrain,dataTest,opt.standard);
    % PCA
    [COEFF,dataTrain] = pca(dataTrain);%�ֱ��ѵ�����������������������ɷֽ�ά��
    dataTest = dataTest*COEFF;
    % =========================nested RFE=============================
    indexOfRankedFeatures_Nested=zeros(opt.innerK,size(dataTrain,2));
    accuracy_Nested=zeros(opt.innerK,size(dataTrain,2));
    %
    indiceCell_Nested=generateIndiceForKfoldCV(labelTrain,opt.innerK);
    for iterInner=1:opt.innerK
        [dataTrain_Nested,dataTest_Nested,labelTrain_Nested,labelTest_Nested]=...
            BalancedSplitDataAndLabel(dataTrain,labelTrain,indiceCell_Nested,iterInner);
        % rfe feature selection
        indexOfRankedFeatures_Nested(iterInner,:)= FeatureSelection_RFE_SVM2( dataTrain_Nested,labelTrain_Nested,opt );
        % obtain accuracy using different feature subset
        for numOfFeature_Nested=1:1:size(dataTrain_Nested,2)
            index_Nested=indexOfRankedFeatures_Nested(iterInner,:);
            index_Nested= index_Nested(1:numOfFeature_Nested);
            dataTrainTemp_Nested=dataTrain_Nested(:,index_Nested);
            dataTestTemp_Nested=dataTest_Nested(:,index_Nested);
            model_Nested= classifier(dataTrainTemp_Nested,labelTrain_Nested);
            [labelPredict_Nested, ~] = predict(model_Nested,dataTestTemp_Nested);
            [accuracy_Nested(iterInner,numOfFeature_Nested),~,~,~,~]=Calculate_Performances(labelPredict_Nested,labelTest_Nested);
        end
    end
    % identify best feature subset(�������ѵ�������Ŀ�󣬸���������inner K-fold�г��ֵ�Ƶ����ѡ������)
    numOfBestFeatureSubset=find(mean(accuracy_Nested)==max(mean(accuracy_Nested)));
%     indexOfBestFeatureSubset=indexOfRankedFeatures_Nested(:,1:numOfBestFeatureSubset);
%     uniIndexOfBestFeatureSubset=unique(indexOfBestFeatureSubset);
%     myMinus=@(x) x-indexOfBestFeatureSubset;
%     cmpCell=arrayfun(myMinus,uniIndexOfBestFeatureSubset,'UniformOutput',false);
%     countZero=@(x) sum(sum(x==0));
%     numOfuniIndexOfBestFeatureSubset=cell2mat(cellfun(countZero,cmpCell,'UniformOutput',false));
%     freqOfuniIndexOfBestFeatureSubset=numOfuniIndexOfBestFeatureSubset/opt.innerK;
%     indOfSelectedFeature=freqOfuniIndexOfBestFeatureSubset>opt.percentage_consensus;
%     featureSelected=uniIndexOfBestFeatureSubset(indOfSelectedFeature);
    % =========================finished nested RFE=============================
    % training and predict/testing using optimized feature subsets
    model= classifier(dataTrain(:,1:numOfBestFeatureSubset),labelTrain);
    [labelPredict{i}, dec_values] = predict(model,dataTest(:,1:numOfBestFeatureSubset));
    Decision{i}=dec_values(:,2);
    % Calculate performance of model
    [Accuracy(i),Sensitivity(i),Specificity(i),PPV(i),NPV(i)]=Calculate_Performances(labelPredict{i},labelTest);
    [AUC(i)]=AUC_LC(labelTest,dec_values(:,1));
    %  �ռ��б�ģʽ
    weightOfComponent = model.Beta;
    weightOfFeature= weightOfComponent' * COEFF(:,1:numOfBestFeatureSubset)';
    weightOfFeature=reshape(weightOfFeature,1,numel(weightOfFeature));
    if opt.weight
        W_Brain(i,:)=weightOfFeature;
    end
end
toc
close (h);
toc
mean([AUC,Accuracy,Sensitivity,Specificity])
std([AUC,Accuracy,Sensitivity,Specificity])
%% ====================���õĴ���==================================
% ����ƽ���Ŀռ��б�ģʽ�����ų���Ƶ�ʵ͵�weight
if opt.weight
    W_mean= mean(W_Brain);
    W_M_Brain(:,maskForFilter~=0)=W_mean;%��ͬfeature ��Ŀʱ��ȫ������Ȩ��
end
% ������ѵķ�������

if opt.weight
    % ���labelֻ����������˵����һ�鱻�Ե�labelΪ��label����weight��Ҫȡ�෴��
    if numel(unique(label))==2
        W_M_Brain_3D=-reshape(W_M_Brain,dim1,dim2,dim3);%best W_M_Brain_3D
    else
        W_M_Brain_3D=reshape(W_M_Brain,dim1,dim2,dim3);%best W_M_Brain_3D
    end
end
%% visualize performance

%% ������ѵķ���Ȩ��ͼ��������
Time=datestr(now,30);
if opt.saveresults
    % ��Ž��·��
    loc= find(path=='\');
    outdir=path(1:loc(length(find(path=='\'))-2)-1);%path����һ��Ŀ¼
    % gray matter mask
    if opt.weight
        [file_name,path_source1,~]= uigetfile( ...
            {'*.img;*.nii;','All Image Files';...
            '*.*','All Files' },...
            '��ѡ��mask����ѡ��', ...
            'MultiSelect', 'off');
        img_strut_temp=load_nii([path_source1,char(file_name)]);
        mask_graymatter=img_strut_temp.img~=0;
        W_M_Brain_3D(~mask_graymatter)=0;
        % save nii
        cd (outdir)
        Data2Img_LC(W_M_Brain_3D,['W_M_Brain_3D_',Time,'.nii']);
    end
    % ������������ȷ����Щ���Եķ���Ч������
    label_ForPerformance= cell2mat( label_ForPerformance);
    labelPredict=cell2mat(labelPredict);
%     loc_badsubjects=(label_ForPerformance-predict_label_best)~=0;
%     name_badsubjects=name_all_sorted(loc_badsubjects);
    save([outdir filesep [Time,'Results_MVPA.mat']],...
        'Accuracy', 'Sensitivity', 'Specificity','PPV', 'NPV', 'Decision', 'AUC',...
        'label_ForPerformance','labelPredict',...
        'indiceCell');
end
end
