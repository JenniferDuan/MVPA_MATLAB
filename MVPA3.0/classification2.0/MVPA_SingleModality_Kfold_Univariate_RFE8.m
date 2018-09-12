function [AUC_best, Accuracy_best,Sensitivity_best,Specificity_best] =...
    MVPA_SingleModality_Kfold_Univariate_RFE8(opt,dataMat,label)
%=========Classification using PCA and RFE========================
% usage��
%       
%      refer to��Multivariate classification of social anxiety disorder
%      using whole brain functional connectivity�� and PMID:18672070��
%      1. �˴��뱣���Ȩ��ͼΪN-fold��consensus��ƽ��Ȩ��ͼ��
%      2. ����fitclinear��indices������ԣ�ÿ�εĽ�������в��죡����
%      3. �ڿ�ʼRFE֮ǰ���Լ��뵥�������������˻���������ά����F-score ��opt.Kendall Tau��Two-sample
%      t-test�ȣ��˴�����Two-sample t-test��
%      4. �˴���û����nested RFE
% input��
%        opt.K=K-fold cross validation(opt.K<=N)        
%        [opt.Initial_FeatureQuantity,opt.Max_FeatureQuantity,opt.Step_FeatureQuantity]=[��ʼ��������,���������,ÿ�����ӵ�������]
%        opt.P_threshold =�����������������ǵ�P��ֵ;
%        opt.percentage_consensus=K fold��ĳ��Ȩ�ز�Ϊ������س��ֵĸ���
%        ��opt.percentage_consensus=0.8��opt.K=5�������5*0.8=4�����ϵ����ز���Ϊ��consensus���ء�
% output��
%        ��������Լ�K-fold��ƽ������Ȩ��(����ֱ�ӱ���Ϊ.mat�ļ�)
% New: 
%       ��չ������classifier��2018-04-10 By Li Chao
%       ʹ��GPU�������㣬�Ӷ��ӿ������ٶȡ�2018-04-30 By Li Chao
%% set options
if nargin<1
    % style of loading data
    opt.loadOrderOfData='groupFirst';
    % mask :'implicit' OR 'external'
    opt.maskSource='implicit';
    % how many modality/feature types
    opt.numOfFeatureType=1;
    % permutation test
    opt.permutation=0;
    % outer K fold CV
    opt.K=5;
    % load old indices
    opt.IfLoadIndices=0;
    % standardization
    opt.standardizationMethod='normalizing';
    opt.min_scale=0;
    opt.max_scale=1;
    % univariate feature filter.
    opt.P_threshold=0.01;
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
    opt.percentage_consensus=0.7;
    % view performances
    opt.viewperformance=1;
    % save results
    opt.saveresults=1;
    % gpu
    opt.gpu=0;
end
%% ===============image to data and produce label==================
% ������û������򲻶�ͼ����������һ������ṩ
% data
if nargin<2
    [fileName,folderPath,dataCell] =Img2Data_MultiGroup('on',2);
    path=folderPath{1};
    name_patients=fileName{1};
    name_controls=fileName{2};
%     [dataMatCell]=dataCell2Mat(dataCell,opt.numOfFeatureType,'groupFirst');
   [dataMatCell,nameFirstModality]=...
       dataCell2Mat(dataCell,fileName,opt.numOfFeatureType,opt.loadOrderOfData);% ���������䵽����cell
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
% indices_p=indiceCell{1};
% indices_c=indiceCell{2};
name_all_sorted=sortNameAccordIndices(nameFirstModality,indiceCell,label,opt);

%% =======================Ԥ����ռ�===============================
numOfFeatureSet=length(opt.Initial_FeatureQuantity:opt.Step_FeatureQuantity:opt.Max_FeatureQuantity);
Accuracy=zeros(opt.K,numOfFeatureSet);Sensitivity =zeros(opt.K,numOfFeatureSet);Specificity=zeros(opt.K,numOfFeatureSet);
AUC=zeros(opt.K,numOfFeatureSet);Decision=cell(opt.K,numOfFeatureSet);PPV=zeros(opt.K,numOfFeatureSet); NPV=zeros(opt.K,numOfFeatureSet);
W_M_Brain=zeros(numOfFeatureSet,dim1*dim2*dim3);
W_Brain=zeros(numOfFeatureSet,sum(maskForFilter),opt.K);
label_ForPerformance=cell(opt.K,1);
labelPredict=cell(opt.K,numOfFeatureSet);
%%  ====================K fold loop===============================
tic;
 [data_inmask]=gpuArray(data_inmask); % GPU
h=waitbar(0,'��ȴ� Outer Loop>>>>>>>>','Position',[50 50 280 60]);
% Outer K-fold + Inner RFE
for i=1:opt.K
    waitbar(i/opt.K,h,sprintf('%2.0f%%', i/opt.K*100)) ;
    % step1�������ݷֳ�ѵ�������Ͳ����������ֱ�ӻ��ߺͶ������г�ȡ��Ŀ����Ϊ������ƽ�⣩
    [dataTrain,dataTest,labelTrain,labelTest]=...
        BalancedSplitDataAndLabel(data_inmask,label,indiceCell,i);
    % step2�� ��׼�����߹�һ��
    [dataTrain,dataTest]=gather(dataTrain,dataTest); % back to CPU
    [dataTrain,dataTest]=Standardization(dataTrain,dataTest,opt);
    % step3�����뵥��������������
    [~,P,~,~]=ttest2(dataTrain(labelTrain==1,:), dataTrain(labelTrain==2,:),'Tail','both');
    %         [~,P]=featureSelection_ANOCOVA(dataTrain,labelTrain, []);% ʹ��GRETNA�Ĵ��룬ע��Ҫ���á�
    Index_ttest2=find(P<=opt.P_threshold);
    dataTrain= dataTrain(:,Index_ttest2);
    dataTest=dataTest(:,Index_ttest2);
    %             [COEFF,dataTrain] = pca(dataTrain);%�ֱ��ѵ�����������������������ɷֽ�ά��
    %             dataTest = dataTest*COEFF;
    % step4��Feature selection---RFE
%     [dataTrain,dataTest]=gather(dataTrain,dataTest); % back to CPU
    [ feature_ranking_list ] = featureSelection_RFE_SVM2( dataTrain,labelTrain,opt );
    % step5�� training model and predict test data using different feature subset
    numOfMaxFeatureQuantity=min(opt.Max_FeatureQuantity,length(Index_ttest2));%���������
    [dataTrain]=gpuArray(dataTrain); % GPU
    [dataTest]=gpuArray(dataTest); % GPU
%     label=gpuArray(label);
    j=0;% count
    for FeatureQuantity=opt.Initial_FeatureQuantity:opt.Step_FeatureQuantity:numOfMaxFeatureQuantity
        j=j+1;%����
        Index_selectfeature=feature_ranking_list(1:FeatureQuantity);
        dataTrainTemp= dataTrain(:,Index_selectfeature);
        dataTestTemp=dataTest(:,Index_selectfeature);
        label_ForPerformance{i,1}=labelTest;
        % training and predict/testing
        [dataTrainTemp,dataTestTemp]=gather(dataTrainTemp,dataTestTemp); % back to CPU
        model= classifier(dataTrainTemp,labelTrain);
        [labelPredict{i,j}, dec_values] = predict(model,dataTestTemp);
        Decision{i,j}=dec_values(:,2);
        % Calculate performance of model
        [accuracy,sensitivity,specificity,ppv,npv]=Calculate_Performances(labelPredict{i,j},labelTest);
        Accuracy(i,j) =accuracy;
        Sensitivity(i,j) =sensitivity;
        Specificity(i,j) =specificity;
        PPV(i,j)=ppv;
        NPV(i,j)=npv;
        [AUC(i,j)]=AUC_LC(labelTest,dec_values(:,1));
        %  �ռ��б�ģʽ
        if opt.weight
            wei=model.Beta;
            W_Brain(j,:,i)=data2originIndex({Index_ttest2,Index_selectfeature},...
                reshape(wei,1,numel(wei)), size( data_inmask,2));
        end
    end
    % step 5 completed!
end
close (h);
toc
%% ====================���õĴ���==================================
% ����ƽ���Ŀռ��б�ģʽ�����ų���Ƶ�ʵ͵�weight
if opt.weight
    W_mean=AverageWeightMap(W_Brain,opt.percentage_consensus);% W_mean��ά�Ⱥ�maskForFilterһ�¡�
    %     W_M_Brain=data2originIndex({find(maskForFilter~=0)},W_mean,length(maskForFilter));
    W_M_Brain(:,maskForFilter~=0)=W_mean;%��ͬfeature ��Ŀʱ��ȫ������Ȩ��
end
% ������ѵķ�������
[loc_best,predict_label_best,~,Accuracy_best,Sensitivity_best,Specificity_best,...
    ~,~,AUC_best]=...
    IdentifyBestPerformance(labelPredict,Accuracy,Sensitivity,Specificity,PPV,NPV,AUC,'accuracy');
% disply best performances
if ~opt.permutation
    disp(['best AUC,Accuracy,Sensitivity and Specificity = '...
        ,num2str([AUC_best,Accuracy_best,Sensitivity_best,Specificity_best])]);
end
if opt.weight
    % ���labelֻ����������˵����һ�鱻�Ե�labelΪ��label����weight��Ҫȡ�෴��
    if numel(unique(label))==2
        W_M_Brain_best=W_M_Brain(loc_best,:);
        W_M_Brain_3D=-reshape(W_M_Brain_best,dim1,dim2,dim3);%best W_M_Brain_3D
    else
        W_M_Brain_best=W_M_Brain(loc_best,:);
        W_M_Brain_3D=reshape(W_M_Brain_best,dim1,dim2,dim3);%best W_M_Brain_3D
    end
end
%% visualize performance
if opt.viewperformance
    plotPerformance(Accuracy,Sensitivity,Specificity,AUC,...
        opt.Initial_FeatureQuantity,opt.Step_FeatureQuantity,opt.Max_FeatureQuantity)
end
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
    loc_badsubjects=(label_ForPerformance-predict_label_best)~=0;
    name_badsubjects=name_all_sorted(loc_badsubjects);
    save([outdir filesep [Time,'Results_MVPA.mat']],...
        'Accuracy', 'Sensitivity', 'Specificity','PPV', 'NPV', 'Decision', 'AUC',...
        'label_ForPerformance','predict_label_best','name_badsubjects',...
        'AUC_best','Accuracy_best','Sensitivity_best','Specificity_best',...
        'indiceCell');
end
end

