function [Accuracy, Sensitivity, Specificity, PPV, NPV, AUC,Decision,label_ForPerformance,weight] = SVM_FCmatrix(opt)
%% =====================����˵��==================================
% ��;���Թ������Ӿ�����л���ѧϰ(PCA ��ά)
% input:
% data/label=����/������ǩ,����ѡ��
% p_start:p_step:p_end=��ʼpֵ��ÿ�����ӵ�pֵ������pֵ
% opt:�������ο���Ӧ���룺FeatureSelection_RFE_SVM
%output�� ���ɸ��������ܣ�size=K*N_subfeature,K=K fold; N_subfeature=sub��feature����
%% ======================Ĭ�ϲ���=================================
%��һЩ�����õģ�����Ӱ��
if nargin<1
    opt.K=5;opt.Initial_FeatureQuantity=50;opt.Max_FeatureQuantity=5000;opt.Step_FeatureQuantity=50;% outer K fold.
    opt.P_threshold=0.05;% univariate feature filter.
    opt.learner='svm';opt.stepmethod='percentage';opt.step=10; % inner RFE.
    opt.percentage_consensus=0.7;% The most frequent voxels/features;range=(0,1] to obtain weight map;
    opt.weight=0;opt.viewperformance=1;opt.saveresults=0;
    opt.standard='scale';opt.min_scale=0;opt.max_scale=1;%���ݱ�׼����ʽ������
    opt.permutation=0;%�Ƿ��ǽ��е��û�����
    p_start=0.001;p_step=0.001;p_end=0.05;%ttest2
end
%% ==============load all MAT files==============================
fprintf('==============load all MAT files====================\n');
%��һ��
[file_name,path_source,~] = uigetfile({'*.mat;','All Image Files';...
    '*.*','All Files'},'MultiSelect','on','��һ�����');
if iscell(file_name)
    n_sub=length(file_name);
    mat_template=importdata([path_source,char(file_name(1))]);
else
    n_sub=1;
    mat_template=importdata([path_source,char(file_name)]);
end
mat_p=zeros(size(mat_template,1), size(mat_template,2),n_sub);
for i=1:n_sub
    if iscell(file_name)
        mat_p(:,:,i)=importdata([path_source,char(file_name(i))]);
        mat_p(:,:,i)=triu( mat_p(:,:,i));%ȡ������
    else
        mat_p(:,:,i)=importdata([path_source,char(file_name)]);
        mat_p(:,:,i)=triu( mat_p(:,:,i));%ȡ������
    end
end
label_p=ones(n_sub,1);
%�ڶ���
[file_name,path_source,~] = uigetfile({'*.mat;','All Image Files';...
    '*.*','All Files'},'MultiSelect','on','�ڶ������');
if iscell(file_name)
    n_sub=length(file_name);
    mat_template=importdata([path_source,char(file_name(1))]);
else
    n_sub=1;
    mat_template=importdata([path_source,char(file_name)]);
end
mat_c=zeros(size(mat_template,1), size(mat_template,2),n_sub);
for i=1:n_sub
    if iscell(file_name)
        mat_c(:,:,i)=importdata([path_source,char(file_name(i))]);
        %         mat_c(:,:,i)=triu( mat_c(:,:,i));%ȡ������
    else
        mat_c(:,:,i)=importdata([path_source,char(file_name)]);
        %         mat_c(:,:,i)=triu( mat_c(:,:,i));%ȡ������
    end
end
label_c=zeros(n_sub,1);
fprintf('==============Load MAT files completed!====================\n');

%% ===============������-����label-��ȡ������=======================
fprintf('=================�����ں�-����label-��ȡ������=================\n');
data=cat(3,mat_p,mat_c);
data(isnan(data))=0;
label=[label_p;label_c-1];
% �����ǣ��������Խ��ߣ���������ȡ
size_mask_triu=[size(data,1),size(data,2)];
mask_triu=ones(size_mask_triu);
mask_triu(tril(mask_triu)==1)=0;
N_sub=size(data,3);
for n_sub=1:N_sub
    data_temp=data(:,:,n_sub);
    data_triu(n_sub,:)=data_temp(mask_triu==1)';
end
fprintf('============�����ں�-����label-��ȡ������ Completed!============\n');

%%
fprintf('=======================K fold ������֤��ʼ====================\n');
% preallocate
Accuracy=zeros(opt.K,1);Sensitivity =zeros(opt.K,1);Specificity=zeros(opt.K,1);
AUC=zeros(opt.K,1);Decision=cell(opt.K,1);PPV=zeros(opt.K,1); NPV=zeros(opt.K,1);
label_ForPerformance=cell(opt.K,1);
%
hh = waitbar(0,'please wait..');
N_sub=size(data_triu,1);
indices = crossvalind('Kfold', N_sub, opt.K);%�˴�����������ӵ���ƣ����ÿ�ν�����ǲ�һ����
for i = 1:opt.K
    waitbar(i/opt.K)
    Test_index = (indices == i); Train_index = ~Test_index;
    dataTrain =data_triu(Train_index,:);
    labelTrain = label(Train_index,:);
    dataTest=data_triu(Test_index,:);
    labelTest=label(Test_index,:);
    label_ForPerformance{i,1}=labelTest;
    %���ݱ�׼��
    [dataTrain,PS] = mapminmax(dataTrain');
    dataTrain=dataTrain';
    dataTest = mapminmax('apply',dataTest',PS);
    dataTest =dataTest';
    %% ����ɸѡ�ҶԶ��sub-feature���н�ģ��Ԥ��
    % PCA
    dataTrain(isnan( dataTrain))=0;
    dataTrain(isinf( dataTrain))=0;
    [COEFF,dataTrain] = pca(dataTrain);%�ֱ��ѵ�����������������������ɷֽ�ά��
    dataTest = dataTest*COEFF;
    % training and testing
    model=fitclinear(dataTrain,labelTrain);
    [labelPredict,dec]=predict(model,dataTest);
     [Accuracy(i),Sensitivity(i),Specificity(i),PPV(i),NPV(i)]=Calculate_Performances(labelPredict,labelTest);
     [AUC(i)]=AUC_LC(labelTest,dec(:,1));
     Decision{i}=dec;
     %  �ռ��б�ģʽ
     wei = model.Beta;
     weight(i,:) = wei' * COEFF';
     % Ttest2
    %     [Accuracy(i,:), Sensitivity(i,:), Specificity(i,:), PPV(i,:), NPV(i,:), AUC(i,:)]=...
    %         Ttest2_MultiSubFeature(train_data,train_label, test_data, test_label, p_start, p_step, p_end,opt);
    %% �����������
    Accuracy(isnan(Accuracy))=0; Sensitivity(isnan(Sensitivity))=0; Specificity(isnan(Specificity))=0;
    PPV(isnan(PPV))=0; NPV(isnan(NPV))=0; AUC(isnan(AUC))=0;
end
close (hh)
fprintf('=======================All Completed!====================\n');