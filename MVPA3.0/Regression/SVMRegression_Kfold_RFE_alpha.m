function [ W_M_Brain, Real_label, Predict_best, MAE_ALL,MAE_best, R_ALL,R_best,CombinedPerformance, CombinedPerformance_best] =...
    SVMRegression_Kfold_RFE_alpha(label,opt)
%��ȷ�Ȳ���
%�ڿ�ʼRFE֮ǰ���Լ��뵥�������������ˣ���F-score ��kendall Tau��Two-sample t-test��
%refer to PMID:18672070

%addpath('J:\lichao\MATLAB_Code\LC_script\Scripts_LC\little tools')
%SVM classification using RFE
%input��K=K-fold cross validation,K<=N;
%[Initial_FeatureQuantity,Max_FeatureQuantity,Step_FeatureQuantity]=��ʼ��������,���������,ÿ�����ӵ���������
%output����������Լ�K-fold��ƽ������Ȩ��
% path=pwd;
% addpath(path);
%%
if nargin<1
    opt.K=5;opt.Initial_FeatureQuantity=50;opt.Max_FeatureQuantity=5000;opt.Step_FeatureQuantity=50;%options for outer K fold.
    opt.P_threshold=0.05;%options for univariate feature filter.
    opt.learner='svm';opt.stepmethod='percentage';opt.step=10;%options for RFE, refer to related codes.
    opt.percentage_consensus=0.7;%options for indentifying the most important voxels.range=(0,1];
    %K fold��ĳ��Ȩ�ز�Ϊ������س��ֵĸ��ʣ���percentage_consensus=0.8��K=5�������5*0.8=4�����ϵ����ز���Ϊ��consensus����
end
K=opt.K;Initial_FeatureQuantity=opt.Initial_FeatureQuantity;
Max_FeatureQuantity=opt.Max_FeatureQuantity;Step_FeatureQuantity=opt.Step_FeatureQuantity;
%%
if nargin <=5
    opt.stepmethod='percentage';opt.step=10;opt.learner='leastsquares';%linear regression;
end
p1=genpath('J:\lichao\MATLAB_Code\LC_script\Scripts_LC\little tools');
addpath(p1, '-begin');
p2 = genpath('J:\lichao\MATLAB_Code\LC_script\Scripts_LC\MVPA3.0');
addpath(p2, '-begin');
%% transform .nii/.img into .mat data, and achive corresponding label
[~,path,data ] = Img2Data_LC;
% [~,~,data_controls ] = Img2Data_LC;
% data=cat(4,data,data_controls);%data
[dim1,dim2,dim3,N]=size(data);
% [~,~,~,n_controls]=size(data_controls);
%% just keep data in inmask
data=reshape(data,[dim1*dim2*dim3,N]);%�з���Ϊ��������ÿһ��Ϊһ��������ÿһ��Ϊһ������
implicitmask = sum(data,2)~=0;%�ڲ�mask,�����ۼ�
data_inmask=data(implicitmask,:);%�ڲ�mask�ڵ�data
data_inmask=data_inmask';
%% Ԥ����ռ�
Number_FeatureSet=numel(Initial_FeatureQuantity:Step_FeatureQuantity:Max_FeatureQuantity);
Num_loop=length(Initial_FeatureQuantity:Step_FeatureQuantity:Max_FeatureQuantity);
W_M_Brain=zeros(Num_loop,dim1*dim2*dim3);
W_Brain=zeros(Num_loop,sum(implicitmask),K);
Real_label=cell(K,1);
Predict=cell(K,Number_FeatureSet);
%%  K fold loop
% ���߳�Ԥ��
% if nargin < 2
%   parworkers=0;%default
% end
% ���߳�׼�����
h=waitbar(0,'Please wait: Outer Loop>>>>>>','Position',[50 50 280 60]);
indices = crossvalind('Kfold', N, K);%�˴�����������ӵ���ƣ����ÿ�ν�����ǲ�һ����
switch K<N
    case 1
        % initialize progress indicator
        %         parfor_progress(K);
        for i=1:K
            waitbar(i/K,h,sprintf('%2.0f%%', i/K*100)) ;
            %K fold
            Test_index = (indices == i); Train_index = ~Test_index;
            Train_data =data_inmask(Train_index,:);
            Train_label = label(Train_index,:);
            Test_data = data_inmask(Test_index,:);
            Test_label = label(Test_index);
            Real_label{i}=Test_label;
            %% inner loop: feature selection
            [ feature_ranking_list ] =FeatureSelection_RFE_SVM_Regression( Train_data,Train_label,opt );
            j=0;%������ΪW_M_Brain��ֵ��
            h1 = waitbar(0,'Please wait: different feature subsets for outer k-fold>>>>>>');
            for FeatureQuantity=Initial_FeatureQuantity:Step_FeatureQuantity:Max_FeatureQuantity % ��ͬfeature subset�����
                j=j+1;%������
                waitbar(j/Num_loop,h1,sprintf('%2.0f%%', j/Num_loop*100)) ;
                Index_selectfeature=feature_ranking_list(1:FeatureQuantity);
                z_MAE_ALL= Train_data(:,Index_selectfeature);
                z_R_ALL=Test_data(:,Index_selectfeature);
                %���з����һ��
                % [train_data,test_data,~] = ...
                %    scaleForSVM(train_data,test_data,0,1);%һ���з����һ�����˴������飬����ʵ�ʽǶ���˵���ǿ��Եġ�
                [z_MAE_ALL,PS] = mapminmax(z_MAE_ALL');
                z_MAE_ALL=z_MAE_ALL';
                z_R_ALL = mapminmax('apply',z_R_ALL',PS);
                z_R_ALL =z_R_ALL';
                %% ѵ��ģ��&Ԥ��
                model= fitrlinear(z_MAE_ALL,Train_label,'Learner',opt.learner);
                [predict_label] = predict(model,z_R_ALL);
                Predict{i,j}=predict_label;
                %% estimate mode/SVM
                
                %%  �ռ��б�ģʽ
                w_Brain = model.Beta;
                W_Brain(j,Index_selectfeature,i) = w_Brain;%��W_Brian��Index(1:N_feature)����λ�õ�����Ȩ����Ϊ0
                %��Index(1:N_feature)�ڵ�Ȩ���򱻸�ֵ��ǰ����Ԥ����0������
                %             if ~randi([0 4])
                %                 parfor_progress;%������
                %             end
            end
            close (h1)
        end
        close (h)
        Predict=cell2mat(Predict);
        Real_label=cell2mat(Real_label);
    case 0 %equal to leave one out cross validation, LOOCV
        for i=1:K
            waitbar(i/K,h,sprintf('%2.0f%%', i/K*100)) ;
            %K fold
            test_index = (indices == i); train_index = ~test_index;
            Train_data =data_inmask(train_index,:);
            Train_label = label(train_index,:);
            Test_data = data_inmask(test_index,:);
            Test_label = label(test_index);
            Real_label{i}=Test_label;
            %% inner loop: ttest2, feature selection and scale
            opt.stepmethod='percentage';opt.step=10;
            [ feature_ranking_list ] = FeatureSelection_RFE_SVM_Regression( Train_data,Train_label,opt );
            j=0;%������ΪW_M_Brain��ֵ��
            h1 = waitbar(0,'...');
            for FeatureQuantity=Initial_FeatureQuantity:Step_FeatureQuantity:Max_FeatureQuantity % ��ͬ������Ŀ�����
                j=j+1;%������
                waitbar(j/Num_loop,h1,sprintf('%2.0f%%', j/Num_loop*100));
                Index_selectfeature=feature_ranking_list(1:FeatureQuantity);
                z_MAE_ALL= Train_data(:, Index_selectfeature);
                z_R_ALL=Test_data(:, Index_selectfeature);
                %���з����һ��
                % [train_data,test_data,~] = ...
                %    scaleForSVM(train_data,test_data,0,1);%һ���з����һ�����˴������飬����ʵ�ʽǶ���˵���ǿ��Եġ�
                [z_MAE_ALL,PS] = mapminmax(z_MAE_ALL');
                z_MAE_ALL=z_MAE_ALL';
                z_R_ALL = mapminmax('apply',z_R_ALL',PS);
                z_R_ALL =z_R_ALL';
                %% ѵ��ģ��
                model= fitrlinear(z_MAE_ALL,Train_label);
                %% Ԥ�� or ����
                [predict_label] = predict(model,z_R_ALL);
                 Predict{i,j}=predict_label;
                %%  �ռ��б�ģʽ
                w_Brain = model.Beta;
                W_Brain(j,Index_selectfeature,i) = w_Brain;%��W_Brian��Index(1:N_feature)����λ�õ�����Ȩ����Ϊ0
                %             if ~randi([0 4])
                %                 parfor_progress;%������
                %             end
            end
            close (h1)
        end
         Predict=cell2mat(Predict);
        Real_label=cell2mat(Real_label);
        close (h)
end
%% ƽ���Ŀռ��б�ģʽ
W_mean=mean(W_Brain,3);%ȡ����LOOVC��w_brain��ƽ��ֵ��ע��˴����ǵ�loop��δ��ѡ�е����أ���������ǰ�潫��Ȩ����Ϊ0
W_M_Brain(:,implicitmask)=W_mean;%��ͬfeature ��Ŀʱ��ȫ������Ȩ��
%% �����������

%% ����ģ������ MAE
% ALL MAE and ALL R
MAE_ALL=Predict-Real_label;
MAE_ALL=sum(abs(MAE_ALL),1)/numel(Real_label);
[R_ALL,~]=corr(Predict,Real_label);
% combine MAE and R to calculate combined performance
% z_MAE_ALL=zscore(MAE_ALL);
% z_R_ALL=zscore(R_ALL);
[z_MAE_ALL,~] = mapminmax(MAE_ALL,0.1,1);
[z_R_ALL,~] = mapminmax(R_ALL,0.1,1);
z_MAE_ALL=reshape(z_MAE_ALL,1,numel(z_MAE_ALL));
z_R_ALL=reshape(z_R_ALL,1,numel(z_R_ALL));
CombinedPerformance=z_R_ALL+1./z_MAE_ALL;
% best feature subset
loc_maxCombinedPerformance=find(CombinedPerformance==max(CombinedPerformance));
loc_maxCombinedPerformance=loc_maxCombinedPerformance(1);
%min MAE and max Pearson R
Predict_best=Predict(:,loc_maxCombinedPerformance);
CombinedPerformance_best=CombinedPerformance(loc_maxCombinedPerformance);
MAE_best=MAE_ALL(loc_maxCombinedPerformance);
R_best=R_ALL(loc_maxCombinedPerformance);
% find best Weight and Predict
W_M_Brain_best=W_M_Brain(loc_maxCombinedPerformance,:);
feature_array=Initial_FeatureQuantity:Step_FeatureQuantity:Max_FeatureQuantity;
% Num_feature_best=feature_array(loc_maxCombinedPerformance);
%% ��ʾ��ͬ����ֵ����ʵĸ�������
 figure;plot((Initial_FeatureQuantity:Step_FeatureQuantity:Max_FeatureQuantity),MAE_ALL,'--o');title('MAE_ALL');
 figure;plot((Initial_FeatureQuantity:Step_FeatureQuantity:Max_FeatureQuantity),R_ALL,'--o');title('R_ALL');
 figure;plot((Initial_FeatureQuantity:Step_FeatureQuantity:Max_FeatureQuantity),CombinedPerformance,'--o');title('CombinedPerformance');
%% save results
%Ŀ¼
loc= find(path=='\');
outdir=path(1:loc(length(find(path=='\'))-2)-1);%path����һ��Ŀ¼
W_M_Brain_3D=reshape(W_M_Brain_best,dim1,dim2,dim3);%best W_M_Brain_3D
%% �������Ȩ��ͼ��������
%gray matter mask
[file_name,path_source1,~]= uigetfile( ...
    {'*.img;*.nii;','All Image Files';...
    '*.*','All Files' },...
    '��ѡ��mask����ѡ��', ...
    'MultiSelect', 'off');
img_strut_temp=load_nii([path_source1,char(file_name)]);
mask_graymatter=img_strut_temp.img~=0;
W_M_Brain_3D(~mask_graymatter)=0;
% save nii
Time=datestr(now,30);
cd (outdir)
Data2Img_LC(W_M_Brain_3D,['W_M_Brain_3D_',Time,'.nii']);
%save results
save([outdir filesep 'Results_MVPA.mat'],...
    'W_M_Brain_best', 'W_M_Brain_3D', 'Real_label', ...
    'Predict_best', 'MAE_ALL','MAE_best','R_ALL','R_best','CombinedPerformance','CombinedPerformance_best');
end

