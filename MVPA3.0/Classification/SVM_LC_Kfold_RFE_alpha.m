function [Accuracy, Sensitivity, Specificity, PPV, NPV, Decision, AUC, W_M_Brain,performances] =...
    SVM_LC_Kfold_RFE_alpha(opt)
%SVM classification using RFE
%�ڿ�ʼRFE֮ǰ���Լ��뵥�������������ˣ���F-score ��kendall Tau��Two-sample t-test��
%refer to PMID:18672070
%input��K=K-fold cross validation,K<=N;
%[Initial_FeatureQuantity,Max_FeatureQuantity,Step_FeatureQuantity]=��ʼ��������,���������,ÿ�����ӵ���������
%output����������Լ�K-fold��ƽ������Ȩ��
% path=pwd;
% addpath(path);
%%
if nargin<1
    opt.K=5;opt.Initial_FeatureQuantity=50;opt.Max_FeatureQuantity=5000;opt.Step_FeatureQuantity=100;%options for outer K fold.
    opt.P_threshold=0.05;%options for univariate featutre filter.
    opt.learner='svm';opt.stepmethod='percentage';opt.step=10;%options for RFE, refer to related codes.
    opt.percentage_consensus=0.7;%options for indentifying the most important voxels.range=(0,1];
    %K fold��ĳ��Ȩ�ز�Ϊ������س��ֵĸ��ʣ���percentage_consensus=0.8��K=5�������5*0.8=4�����ϵ����ز���Ϊ��consensus����
end
K=opt.K;Initial_FeatureQuantity=opt.Initial_FeatureQuantity;
Max_FeatureQuantity=opt.Max_FeatureQuantity;Step_FeatureQuantity=opt.Step_FeatureQuantity;
% P_threshold=opt.P_threshold;percentage_consensus=opt.percentage_consensus;
%% transform .nii/.img into .mat data, and achive corresponding label
[~,path,data_patients ] = Img2Data_LC;
[~,~,data_controls ] = Img2Data_LC;
data=cat(4,data_patients,data_controls);%data
[dim1,dim2,dim3,n_patients]=size(data_patients);
[~,~,~,n_controls]=size(data_controls);
% label=[ones(n_patients,1);zeros(n_controls,1)];%label
label=[1;1;1;0;0;0;1;1;1;0;0;0;1;1;1;0;0;0;1;1;0;0;1;1;0;0;1;1;0;0;0;0;0;1;1;1;1;1;0;0;1;1;1;0;0;0;1;1;....
    1;1;1;0;0;0;1;1;1;1;0;0;1;1;1;1;1;1;0;0;0;0;0;0;1;1;1;0;0;1;1;0;0;1];
%% just keep data in inmask
N=n_patients+n_controls;
data=reshape(data,[dim1*dim2*dim3,N]);%�з���Ϊ��������ÿһ��Ϊһ��������ÿһ��Ϊһ������
implicitmask = sum(data,2)~=0;%�ڲ�mask,�����ۼ�
data_inmask=data(implicitmask,:);%�ڲ�mask�ڵ�data
data_inmask=data_inmask';
%% Ԥ����ռ�
% w_M_Brain=zeros(1,sum(implicitmask));
Num_FeatureSet=length(Initial_FeatureQuantity:Step_FeatureQuantity:Max_FeatureQuantity);
Accuracy=zeros(K,Num_FeatureSet);Sensitivity =zeros(K,Num_FeatureSet);Specificity=zeros(K,Num_FeatureSet);
AUC=zeros(K,Num_FeatureSet);Decision=cell(K,Num_FeatureSet);PPV=zeros(K,Num_FeatureSet); NPV=zeros(K,Num_FeatureSet);
W_M_Brain=zeros(Num_FeatureSet,dim1*dim2*dim3);%��ͬ�����Ӽ�ʱƽ����weight��outer k-fold��ƽ����
W_Brain=zeros(Num_FeatureSet,sum(implicitmask),K);
label_ForPerformance=NaN(N,1);
Predict=NaN(K,N,1);
%%  K fold loop
% ���߳�Ԥ��
% if nargin < 2
%   parworkers=0;%default
% end
% ���߳�׼�����
h1=waitbar(0,'��ȴ� Outer Loop>>>>>>>>','Position',[50 50 280 60]);
indices = crossvalind('Kfold', N, K);%�˴�����������ӵ���ƣ����ÿ�ν�����ǲ�һ����
switch K<N %k-fold or LOOCV
    case 1
        % initialize progress indicator
        %         parfor_progress(K);
        for i=1:K
            waitbar(i/K,h1,sprintf('%2.0f%%', i/K*100)) ;
            %K fold
            Test_index = (indices == i); Train_index = ~Test_index;
            Train_data =data_inmask(Train_index,:);
            Train_label = label(Train_index,:);
            Test_data = data_inmask(Test_index,:);
            Test_label = label(Test_index);
           %% ��׼�����߹�һ��
            %���з����һ��
            % [train_data,test_data,~] = ...
            %    scaleForSVM(train_data,test_data,0,1);%һ���з����һ�����˴������飬����ʵ�ʽǶ���˵���ǿ��Եġ�
            [Train_data,PS] = mapminmax(Train_data');
            Train_data=Train_data';
            Test_data = mapminmax('apply', Test_data',PS);
            Test_data = Test_data';
           %% inner loop: feature selection and different subsets
            opt.stepmethod='percentage';opt.step=10;
            [ feature_ranking_list ] = FeatureSelection_RFE_SVM( Train_data,Train_label,opt );
            j=0;%������ΪW_M_Brain��ֵ��
            h2 = waitbar(0,'...');
            for FeatureQuantity=Initial_FeatureQuantity:Step_FeatureQuantity:Max_FeatureQuantity % ��ͬfeature subset�����
                j=j+1;%������
                waitbar(j/Num_FeatureSet,h2,sprintf('%2.0f%%', j/Num_FeatureSet*100)) ;
                Index_selectfeature=feature_ranking_list(1:FeatureQuantity);
                train_data= Train_data(:,Index_selectfeature);
                test_data=Test_data(:,Index_selectfeature);
                label_ForPerformance(j:j+numel(Test_label)-1,1)=Test_label;
                %% ѵ��ģ��&Ԥ��
                model= fitclinear(train_data,Train_label);
                [predict_label, dec_values] = predict(model,test_data);
                Decision{i,j}=dec_values(:,2);
                %% estimate mode/SVM
                [accuracy,sensitivity,specificity,ppv,npv]=Calculate_Performances(predict_label,Test_label);
                Accuracy(i,j) =accuracy;
                Sensitivity(i,j) =sensitivity;
                Specificity(i,j) =specificity;
                PPV(i,j)=ppv;
                NPV(i,j)=npv;
                [AUC(i,j)]=AUC_LC(Test_label,dec_values(:,2));
                %%  �ռ��б�ģʽ
                w_brain = model.Beta;
                W_Brain(j,Index_selectfeature,i) = w_brain;%��W_Brian��Index(1:N_feature)����λ�õ�����Ȩ����Ϊ0
                %��Index(1:N_feature)�ڵ�Ȩ���򱻸�ֵ��ǰ����Ԥ����0������
                %             if ~randi([0 4])
                %                 parfor_progress;%������
                %             end
            end
            close (h2)
        end
        close (h1)
    case 0 %equal to leave one out cross validation, LOOCV
        for i=1:K
            waitbar(i/K,h1,sprintf('%2.0f%%', i/K*100)) ;
            %K fold
            test_index = (indices == i); train_index = ~test_index;
            Train_data =data_inmask(train_index,:);
            Train_label = label(train_index,:);
            Test_data = data_inmask(test_index,:);
            Test_label = label(test_index);
            label_ForPerformance(i)=Test_label;
            %% ��׼�����߹�һ��
            %���з����һ��
            % [train_data,test_data,~] = ...
            %    scaleForSVM(train_data,test_data,0,1);%һ���з����һ�����˴������飬����ʵ�ʽǶ���˵���ǿ��Եġ�
            [Train_data,PS] = mapminmax(Train_data');
            Train_data=Train_data';
            Test_data = mapminmax('apply', Test_data',PS);
            Test_data = Test_data';
            %% inner loop:feature selection
            opt.stepmethod='percentage';opt.step=10;
            [ feature_ranking_list ] = FeatureSelection_RFE_SVM( Train_data,Train_label,opt );
            j=0;%������ΪW_M_Brain��ֵ��
            h2 = waitbar(0,'...');
            for FeatureQuantity=Initial_FeatureQuantity:Step_FeatureQuantity:Max_FeatureQuantity % ��ͬ������Ŀ�����
                j=j+1;%������
                waitbar(j/Num_FeatureSet,h2,sprintf('%2.0f%%', j/Num_FeatureSet*100));
                Index_selectfeature=feature_ranking_list(1:FeatureQuantity);
                train_data= Train_data(:, Index_selectfeature);
                test_data=Test_data(:, Index_selectfeature);
                %% ѵ��ģ��
                model= fitclinear(train_data,Train_label);
                %% Ԥ�� or ����
                [predict_label, dec_values] = predict(model,test_data);
                Decision{i,j}=dec_values(:,2);
                Predict(i,j,1)=predict_label;
                %%  �ռ��б�ģʽ
                w_brain = model.Beta;
                W_Brain(j,Index_selectfeature,i) = w_brain;%��W_Brian��Index(1:N_feature)����λ�õ�����Ȩ����Ϊ0
                %             if ~randi([0 4])
                %                 parfor_progress;%������
                %             end
            end
            close (h2)
        end
        close (h1)
end
%% ƽ���Ŀռ��б�ģʽ
W_mean=mean(W_Brain,3);%ȡ����fold��W_Brain��ƽ��ֵ��ע��˴����ǵ�loop��δ��ѡ�е����أ���������ǰ�潫��Ȩ����Ϊ0
W_M_Brain(:,implicitmask)=W_mean;%��ͬfeature ��Ŀʱ��ȫ������Ȩ��
%% �����������
Accuracy(isnan(Accuracy))=0; Sensitivity(isnan(Sensitivity))=0; Specificity(isnan(Specificity))=0;
PPV(isnan(PPV))=0; NPV(isnan(NPV))=0; AUC(isnan(AUC))=0;
%% ����ģ������
if K<N
    performances=[[mean(Accuracy);mean(Sensitivity);mean(Specificity);mean(PPV);mean(NPV);mean(AUC)],...
        [std(Accuracy);std(Sensitivity);std(Specificity);std(PPV);std(NPV);std(AUC)]];%�ۺϷ�����֣�ǰһ����Mean ��һ����Std
elseif K==N
    [Accuracy, Sensitivity, Specificity, PPV, NPV]=Calculate_Performances(Predict,label_ForPerformance);
    AUC=AUC_LC(label_ForPerformance,cell2mat(Decision));
    performances=[Accuracy, Sensitivity, Specificity, PPV, NPV,AUC]';%�ۺϷ������
end
%% visualize performance
% Name_plot={'accuracy','sensitivity', 'specificity', 'PPV', 'NPV','AUC'};
N_plot=length(Initial_FeatureQuantity:Step_FeatureQuantity:Max_FeatureQuantity);
figure;
plot((Initial_FeatureQuantity:Step_FeatureQuantity:Max_FeatureQuantity),performances(1,(1:1:N_plot)),...
    '--o','markersize',10,'LineWidth',3.5);title('Mean accuracy');
figure;
plot((Initial_FeatureQuantity:Step_FeatureQuantity:Max_FeatureQuantity),performances(2,(1:1:N_plot)),...
    '--o','markersize',10,'LineWidth',3.5);title('Mean sensitivity');
figure;
plot((Initial_FeatureQuantity:Step_FeatureQuantity:Max_FeatureQuantity),performances(3,(1:1:N_plot)),...
    '--o','markersize',10,'LineWidth',3.5);title('Mean specificity');
figure;
plot((Initial_FeatureQuantity:Step_FeatureQuantity:Max_FeatureQuantity),performances(6,(1:1:N_plot)),...
    '--o','markersize',10,'LineWidth',3.5); title('Mean AUC');
%set figures
% xlabel('P value','FontName','Times New Roman','FontWeight','bold','FontSize',35);
% ylabel([Name_plot{6}],'FontName','Times New Roman','FontWeight','bold','FontSize',35);
% set(gca,'Fontsize',30);%�������������С
% fig=legend('accuracy','sensitivity', 'specificity');
% % fig=legend('mean','standard deviation');
% set(fig,'Fontsize',30);%����legend�����С
% fig.Location='NorthEastOutside';
% % set(gca,'XTick',Initial_FeatureQuantity:Step_FeatureQuantity:Max_FeatureQuantity);%����x��ļ������Χ��
% xlim([0 Max_FeatureQuantity]);
% set(gca,'YTick',0:0.1:1);%����y��ļ������Χ��
% grid on;
%% save results
%Ŀ¼
loc= find(path=='\');
outdir=path(1:loc(length(find(path=='\'))-2)-1);%path����һ��Ŀ¼
meanAccuracy=performances(1,(1:1:N_plot));
loc_best_meanAccuracy=find(meanAccuracy==max(meanAccuracy));
loc_best_meanAccuracy=loc_best_meanAccuracy(1);
W_M_Brain_best=W_M_Brain(loc_best_meanAccuracy,:);
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
    'Accuracy', 'Sensitivity', 'Specificity',...
    'PPV', 'NPV', 'Decision', 'AUC', 'W_M_Brain_best', 'label_ForPerformance');
%save mean performances as .tif figure
% cd (outdir)
% print(gcf,'-dtiff','-r600','Mean Performances')
end

