function [AUC_best, Accuracy_best,Sensitivity_best,Specificity_best] =...
    SVM_LC_Kfold_RFEandUnivariate4(opt,data,label)
%=========SVM classification using RFE========================
%ע�⣺
% �˴��뱣���Ȩ��ͼΪN-fold��consensus��ƽ��Ȩ��ͼ��refer to��Multivariate classification of social anxiety disorder
% using whole brain functional connectivity����
% ����fitclinear��indices������ԣ�ÿ�εĽ�������в��죡����
% �ڿ�ʼRFE֮ǰ���Լ��뵥�������������ˣ���F-score ��opt.Kendall Tau��Two-sample t-test��
% refer to PMID:18672070opt.Initial_FeatureQuantity
% input��opt.K=opt.K-fold cross validation,opt.K<=N;
% [opt.Initial_FeatureQuantity,opt.Max_FeatureQuantity,opt.Step_FeatureQuantity]=��ʼ��������,���������,ÿ�����ӵ���������
% opt.P_threshold Ϊ�����������������ǵ�P��ֵ;opt.percentage_consensusΪ��
% opt.K fold��ĳ��Ȩ�ز�Ϊ������س��ֵĸ��ʣ���opt.percentage_consensus=0.8��opt.K=5�������5*0.8=4�����ϵ����ز���Ϊ��consensus���ء�
% output����������Լ�opt.K-fold��ƽ������Ȩ��
% performances(:,1:size(performances,2)/2)=���ܣ����µ�Ϊ��׼�
% new feature:��fitclinear��Ϊfitcsvm���Ӷ�ʹÿ�ν����Ļ���ѧϰģ��һ��;2018-02-03 by Li Chao
% New: ����ģ�黯�������Ӵ������չ�Կ��Կ���ֲ�ԡ�2018-03-08 by Li Chao
%% set options
if nargin<1
    opt.K=5;opt.Initial_FeatureQuantity=50;opt.Max_FeatureQuantity=5000;opt.Step_FeatureQuantity=50;%uter opt.K fold.
    opt.P_threshold=0.05;% univariate feature filter.
    opt.learner='svm';opt.stepmethod='percentage';opt.step=10;% RFE.
    opt.percentage_consensus=0.1;%The most frequent voxels/features;range=(0,1];
    opt.weight=1;opt.viewperformance=1;opt.saveresults=1;
    opt.standard='normalizing';opt.min_scale=0;opt.max_scale=1;
    opt.permutation=0;
    opt.IfLoadIndices=0;
end
%% ===transform .nii/.img into .mat data, and produce corresponding label=========
% ������û������򲻶�ͼ����������һ������ṩ
% data
if nargin<2 
    [fileName,folderPath,data] =Img2Data_MultiGroup(2);
    data_patients=data{1};data_controls=data{2};
    path=folderPath{1};
    name_patients=fileName{1};name_controls=fileName{2};
    data=cat(4,data_patients,data_controls);
end
% label
if nargin<3
    n_patients=size(data_patients,4);
    n_controls=size(data_controls,4);
    label=[ones(n_patients,1);zeros(n_controls,1)];
end
[dim1,dim2,dim3,N]=size(data);
n_patients=sum(label==1);
n_controls=sum(label==0);
%% ==========just keep data in mask========================
[data_inmask,maskForFilter]=FeatureFilterByMask(data,[],'implicit');
data_inmask_p=data_inmask(label==1,:);
data_inmask_c=data_inmask(label==0,:);
%% ȷ���Ƿ��������еĽ�����֤��ʽ,��Ϊ����ȷ����Щ�������಻����׼��
if ~opt.permutation
    % �������û�����ʱ���͸����û���ȷ���Ƿ��������еĽ�����֤��ʽ
    if opt.IfLoadIndices==0
        indices = crossvalind('Kfold', N, opt.K);%�˴�����������ӵ���ƣ����ÿ�ν�����ǲ�һ����
        indices_p = crossvalind('Kfold', n_patients, opt.K);%�˴�����������ӵ���ƣ����ÿ�ν�����ǲ�һ����
        indices_c = crossvalind('Kfold', n_controls, opt.K);%�˴�����������ӵ���ƣ����ÿ�ν�����ǲ�һ����
    else
        [~,indices_p,indices_c]=LoadIndices();
    end
else
    % �����û�����ʱ������ƽ�����֤
    indices = crossvalind('Kfold', N, opt.K);%�˴�����������ӵ���ƣ����ÿ�ν�����ǲ�һ����
    indices_p = crossvalind('Kfold', n_patients, opt.K);%�˴�����������ӵ���ƣ����ÿ�ν�����ǲ�һ����
    indices_c = crossvalind('Kfold', n_controls, opt.K);%�˴�����������ӵ���ƣ����ÿ�ν�����ǲ�һ����
end
% �������û�����ʱ����ȷ���ļ�����˳��Ϊ����ȷ����Щ�������಻����׼��
name_all_sorted=SortNameAccordIndices(name_patients,name_controls,indices_p,indices_c,opt);
%% ==================ȷ��t�������ܳ��ֵ���С��������================
Num_FeatureSet_min=Inf;
Index_ttest2=cell(opt.K,1);
for i=1:opt.K
    %% �����ݷֳ�ѵ�������Ͳ����������ֱ�ӻ��ߺͶ������г�ȡ��Ŀ����Ϊ������ƽ�⣩
    [Train_data,Test_data,Train_label,~]=...
    BalancedSplitDataAndLabel(data_inmask_p,data_inmask_c,indices_p,indices_c,i);
    %% step2�� ��׼�����߹�һ��
    [Train_data,~]=Standardization(Train_data,Test_data,opt.standard);
    % ���뵥��������������
    [~,P,~,~]=ttest2(Train_data(Train_label==1,:), Train_data(Train_label==0,:),'Tail','both');
    Index_ttest2{i}=find(P<=opt.P_threshold);
    if ~opt.permutation
        disp(['Number of remained feature of the ',num2str(i),'it ','fold',' = ',num2str(numel(Index_ttest2{i}))]);
    end
    if Num_FeatureSet_min>=numel(Index_ttest2{i})
        Num_FeatureSet_min=numel(Index_ttest2{i});
    end
end

%% ==============�����С����С��Ԥ����������,�����������Ϊt�����г��ֵ���С����������Ӧ�Ĳ�������ʵҲ�ı�========
if Num_FeatureSet_min< opt.Max_FeatureQuantity
    if ~opt.permutation
        disp(['t������������Ŀ�����趨���������������ִ�и�����С�������ĳ�����С����Ϊ��',num2str(Num_FeatureSet_min)]);
    end
    opt.Initial_FeatureQuantity=10;opt.Step_FeatureQuantity=floor(Num_FeatureSet_min/100);opt.Max_FeatureQuantity=Num_FeatureSet_min;
end
%% =======================Ԥ����ռ�===============================
Num_FeatureSet=length(opt.Initial_FeatureQuantity:opt.Step_FeatureQuantity:opt.Max_FeatureQuantity);
Accuracy=zeros(opt.K,Num_FeatureSet);Sensitivity =zeros(opt.K,Num_FeatureSet);Specificity=zeros(opt.K,Num_FeatureSet);
AUC=zeros(opt.K,Num_FeatureSet);Decision=cell(opt.K,Num_FeatureSet);PPV=zeros(opt.K,Num_FeatureSet); NPV=zeros(opt.K,Num_FeatureSet);
W_M_Brain=zeros(Num_FeatureSet,dim1*dim2*dim3);
W_Brain=zeros(Num_FeatureSet,sum(maskForFilter),opt.K);
label_ForPerformance=cell(opt.K,1);
predict_label=cell(opt.K,Num_FeatureSet);
%%  ====================K fold loop===============================
h1=waitbar(0,'��ȴ� Outer Loop>>>>>>>>','Position',[50 50 280 60]);
for i=1:opt.K %Outer opt.K-fold + Inner RFE
    waitbar(i/opt.K,h1,sprintf('%2.0f%%', i/opt.K*100)) ;
    % step1��split data into training data and testing  data
    % �����ݷֳ�ѵ�������Ͳ����������ֱ�ӻ��ߺͶ������г�ȡ��Ŀ����Ϊ������ƽ�⣩
    [Train_data,Test_data,Train_label,Test_label]=...
        BalancedSplitDataAndLabel(data_inmask_p,data_inmask_c,indices_p,indices_c,i);
    %% step2�� ��׼�����߹�һ��
    [Train_data,Test_data]=Standardization(Train_data,Test_data,opt.standard);
    %% step3�����뵥��������������
    %             [~,P,~,~]=ttest2(Train_data(Train_label==1,:), Train_data(Train_label==0,:),'Tail','both');
    %             Index_ttest2=find(P<=opt.P_threshold);%��С�ڵ���ĳ��Pֵ������ѡ�������
    Train_data= Train_data(:,Index_ttest2{i});
    Test_data=Test_data(:,Index_ttest2{i});
    %% step4��Feature selection---RFE
    [ feature_ranking_list ] = FeatureSelection_RFE_SVM2( Train_data,Train_label,opt );
    %% step5�� training model and predict test data using different feature subsets which were selected by step4
    %step4��Feature selection---RFE
    j=0;%������ΪW_M_Brain��ֵ��
     if ~opt.permutation; h2 = waitbar(0,'...');end
    for FeatureQuantity=opt.Initial_FeatureQuantity:opt.Step_FeatureQuantity:opt.Max_FeatureQuantity %
        w_brain=zeros(1,sum(maskForFilter));
        j=j+1;%������
         if ~opt.permutation
             waitbar(j/Num_FeatureSet,h2,sprintf('%2.0f%%', j/Num_FeatureSet*100)) ;
         end
        Index_selectfeature=feature_ranking_list(1:FeatureQuantity);
        train_data= Train_data(:,Index_selectfeature);
        test_data=Test_data(:,Index_selectfeature);
        label_ForPerformance{i,1}=Test_label;
        % ѵ��ģ��&Ԥ��
        model= fitcsvm(train_data,Train_label);
        [predict_label{i,j}, dec_values] = predict(model,test_data);
        Decision{i,j}=dec_values(:,2);
        % estimate mode/SVM
        [accuracy,sensitivity,specificity,ppv,npv]=Calculate_Performances(predict_label{i,j},Test_label);
        Accuracy(i,j) =accuracy;
        Sensitivity(i,j) =sensitivity;
        Specificity(i,j) =specificity;
        PPV(i,j)=ppv;
        NPV(i,j)=npv;
        [AUC(i,j)]=AUC_LC(Test_label,dec_values(:,2));
        %  �ռ��б�ģʽ
        if opt.weight
            Index_ttest2_mask=Index_ttest2{i};
            loc_maskForFilter=Index_ttest2_mask(Index_selectfeature);
            w_brain(loc_maskForFilter) = reshape(model.Beta,1,numel(model.Beta));
            W_Brain(j,:,i) = w_brain;%��W_Brian��Index(1:N_feature)����λ�õ�����Ȩ����Ϊ0
        end
    end
     if ~opt.permutation; close (h2);end
end
close (h1)
%% ====================���õĴ���==================================
% ����ƽ���Ŀռ��б�ģʽ����ɸѡƵ�ʵ͵�weight
if opt.weight
    W_mean=AverageWeightMap(W_Brain,opt.percentage_consensus);% W_mean��ά�Ⱥ�maskForFilterһ�¡�
    W_M_Brain(:,maskForFilter)=W_mean;%��ͬfeature ��Ŀʱ��ȫ������Ȩ��
end
% ������ѵķ�������
 [loc_best,predict_label_best,performances,Accuracy_best,Sensitivity_best,Specificity_best,...
         ~,~,AUC_best]=...
         IdentifyBestPerformance(predict_label,Accuracy,Sensitivity,Specificity,PPV,NPV,AUC,'accuracy');
 % disply best performances
if ~opt.permutation
    disp(['best AUC,Accuracy,Sensitivity and Specificity = '...
        ,num2str([AUC_best,Accuracy_best,Sensitivity_best,Specificity_best])]);
end
%��Ӧ������������consensus������
if opt.weight
    W_M_Brain_best=W_M_Brain(loc_best,:);
    W_M_Brain_3D=reshape(W_M_Brain_best,dim1,dim2,dim3);%best W_M_Brain_3D
end
%% visualize performance
if opt.viewperformance
    plotPerformance(Accuracy,Sensitivity,Specificity,AUC,...
    opt.Initial_FeatureQuantity,opt.Step_FeatureQuantity,opt.Max_FeatureQuantity)
end
%% ������ѵķ���Ȩ��ͼ��������
Time=datestr(now,30);
if opt.saveresults
    %��Ž��·��
    loc= find(path=='\');
    outdir=path(1:loc(length(find(path=='\'))-2)-1);%path����һ��Ŀ¼
    %gray matter masopt.K
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
    predict_label=cell2mat(predict_label);
    loc_badsubjects=(label_ForPerformance-predict_label_best)~=0;
    name_badsubjects=name_all_sorted(loc_badsubjects);
    save([outdir filesep [Time,'Results_MVPA.mat']],...
        'Accuracy', 'Sensitivity', 'Specificity','PPV', 'NPV', 'Decision', 'AUC',...
        'label_ForPerformance','predict_label_best','name_badsubjects',...
        'AUC_best','Accuracy_best','Sensitivity_best','Specificity_best',...
        'indices','indices_p','indices_c');
end
end

