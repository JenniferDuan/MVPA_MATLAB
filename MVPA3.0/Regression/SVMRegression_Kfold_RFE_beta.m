function [ MAE_best,R_best,CombinedPerformance_best,Predict_best] =...
    SVMRegression_Kfold_RFE_beta(opt,label,data)
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
if nargin <1
    opt.K=5;opt.Initial_FeatureQuantity=50;opt.Max_FeatureQuantity=5000;opt.Step_FeatureQuantity=50;%options for outer K fold.
    opt.P_threshold=0.05;%options for univariate feature filter, if P_threshold=1,then equal to no univariate filter.
    opt.learner='leastsquares';opt.stepmethod='percentage';opt.step=10;%options for RFE, refer to related codes.
    opt.percentage_consensus=0.7;%options for indentifying the most important voxels.range=(0,1];
    %K fold��ĳ��Ȩ�ز�Ϊ������س��ֵĸ��ʣ���percentage_consensus=0.8��K=5�������5*0.8=4�����ϵ����ز���Ϊ��consensus����
    opt.weight=0;opt.viewperformance=0;opt.saveresults=0;opt.standard='scale';opt.min_scale=0;opt.max_scale=1;
    opt.permutation=0;
end
Initial_FeatureQuantity=opt.Initial_FeatureQuantity;
Max_FeatureQuantity=opt.Max_FeatureQuantity;Step_FeatureQuantity=opt.Step_FeatureQuantity;
P_threshold=opt.P_threshold;percentage_consensus=opt.percentage_consensus;
%%
% p1=genpath('J:\lichao\MATLAB_Code\LC_script\Scripts_LC\little tools');
% addpath(p1, '-begin');
% p2 = genpath('J:\lichao\MATLAB_Code\LC_script\Scripts_LC\MVPA3.0');
% addpath(p2, '-begin');
%% ===transform .nii/.img into .mat data, and achive corresponding label=========
if nargin<3 %������û������򲻶�ͼ����������һ������ṩ
    [~,path,data_patients ] = Img2Data_LC;
    [~,~,data_controls ] = Img2Data_LC;
    data=cat(4,data_patients,data_controls);%data
    n_patients=size(data_patients,4);
    n_controls=size(data_controls,4);
    if opt.permutation;disp(['number of patients and controls are ', num2str([n_patients, n_controls])]);end
end
if nargin<2
    label=[ones(n_patients,1);zeros(n_controls,1)];%label
end
[dim1,dim2,dim3,N]=size(data);
%% �ж�label��data�Ƿ���Ŀƥ��
if numel(label)~=N
    warning('The number of label is inconsistent with data');
end
%% just keep data in inmask
data=reshape(data,[dim1*dim2*dim3,N]);%�з���Ϊ��������ÿһ��Ϊһ��������ÿһ��Ϊһ������
implicitmask = sum(data,2)~=0;%�ڲ�mask,�����ۼ�
data_inmask=data(implicitmask,:);%�ڲ�mask�ڵ�data
data_inmask=data_inmask';
%% Ԥ����ռ�
Number_FeatureSet=numel(Initial_FeatureQuantity:Step_FeatureQuantity:Max_FeatureQuantity);
Num_loop=length(Initial_FeatureQuantity:Step_FeatureQuantity:Max_FeatureQuantity);
W_M_Brain=zeros(Num_loop,dim1*dim2*dim3);
W_Brain=zeros(Num_loop,sum(implicitmask),opt.K);
Real_label=cell(opt.K,1);
Predict=cell(opt.K,Number_FeatureSet);
%%  K fold loop
% ���߳�Ԥ��
% if nargin < 2
%   parworkers=0;%default
% end
% ���߳�׼�����
h=waitbar(0,'Please wait: Outer Loop>>>>>>','Position',[50 50 280 60]);
indices = crossvalind('Kfold', N, opt.K);%�˴�����������ӵ���ƣ����ÿ�ν�����ǲ�һ����
switch opt.K<N
    case 1
        % initialize progress indicator
        %         parfor_progress(K);
        for i=1:opt.K
            waitbar(i/opt.K,h,sprintf('%2.0f%%', i/opt.K*100)) ;
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
                train_data= Train_data(:,Index_selectfeature);
                test_data=Test_data(:,Index_selectfeature);
                % step2�� ��׼�����߹�һ��
                [train_data,test_data ] = Standard( train_data,test_data,opt);
                %% ѵ��ģ��&Ԥ��
                model= fitrlinear(train_data,Train_label,'Learner',opt.learner);
                [predict_label] = predict(model,test_data );
                Predict{i,j}=predict_label;
                %% estimate mode/SVM
                
                %%  �ռ��б�ģʽ
                if opt.weight
                    w_Brain = model.Beta;
                    W_Brain(j,Index_selectfeature,i) = w_Brain;%��W_Brian��Index(1:N_feature)����λ�õ�����Ȩ����Ϊ0
                end
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
        for i=1:opt.K
            waitbar(i/opt.K,h,sprintf('%2.0f%%', i/opt.K*100)) ;
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
                train_data= Train_data(:, Index_selectfeature);
                test_data=Test_data(:, Index_selectfeature);
                % step2�� ��׼�����߹�һ��
                [train_data,test_data ] = Standard( train_data,test_data,opt);
                %% ѵ��ģ��
                model= fitrlinear(train_data,Train_label);
                %% Ԥ�� or ����
                [predict_label] = predict(model,test_data);
                Predict{i,j}=predict_label;
                %%  �ռ��б�ģʽ
                if opt.weight
                    w_Brain = model.Beta;
                    W_Brain(j,Index_selectfeature,i) = w_Brain;%��W_Brian��Index(1:N_feature)����λ�õ�����Ȩ����Ϊ0
                end
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
if opt.weight
    %% consensus��ƽ���Ŀռ��б�ģʽ
    binary_mask=W_Brain~=0;
    sum_binary_mask=sum(binary_mask,3);
    loc_consensus=sum_binary_mask>=percentage_consensus*opt.K; num_consensus=sum(loc_consensus,2)';%location and number of consensus weight
    disp(['consensus voxel = ' num2str(num_consensus)]);
    W_mean=mean(W_Brain,3);%ȡ����fold�� W_Brain��ƽ��ֵ
    W_mean(~loc_consensus)=0;%set weights located in the no consensus location to zero.
    W_M_Brain(:,implicitmask)=W_mean;%��ͬfeature ��Ŀʱ��ȫ������Ȩ��
end
%% �����������

%% ����ģ������ MAE��
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
CombinedPerformance=z_R_ALL+1./z_MAE_ALL;%refer to Cui ZaiXu's paper (Cerebral Cortex)
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
if opt.viewperformance
    figure;plot(feature_array,MAE_ALL,'--o');title('MAE_ALL');
    figure;plot(feature_array,R_ALL,'--o');title('R_ALL');
    figure;plot(feature_array,CombinedPerformance,'--o');title('CombinedPerformance');
end
%% save results
Time=datestr(now,30);
if  opt.saveresults
    %Ŀ¼
    loc= find(path=='\');
    outdir=path(1:loc(length(find(path=='\'))-2)-1);%path����һ��Ŀ¼
    W_M_Brain_3D=reshape(W_M_Brain_best,dim1,dim2,dim3);%best W_M_Brain_3D
    % �������Ȩ��ͼ
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
end
%save results
if opt.saveresults
    save([outdir filesep [Time,' Results_MVPA.mat']],...
        'W_M_Brain_best', 'W_M_Brain_3D','Predict_best','Real_label',...
        'MAE_ALL','MAE_best','R_ALL','R_best','CombinedPerformance','CombinedPerformance_best');
end
end

