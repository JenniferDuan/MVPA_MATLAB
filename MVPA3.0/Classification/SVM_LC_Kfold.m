function [Accuracy, Sensitivity, Specificity, PPV, NPV, Decision, AUC, w_M_Brain, w_M_Brain_3D, label_ForPerformance] =...
    SVM_LC_Kfold(K, Lambda)
%�˴�����heart���ݼ��ϲ��Գɹ�
%input��K=K-fold cross validation,K<N
%output����������Լ�K-fold��ƽ������Ȩ��; label_ForPerformance=�����������label����������ROC����
% path=pwd;
% addpath(path);
%% ��ͼ��תΪdata,������label
[~,path,data_patients ] = Img2Data_LC;
[~,~,data_controls ] = Img2Data_LC;
data=cat(4,data_patients,data_controls);%data
[dim1,dim2,dim3,n_patients]=size(data_patients);
[~,~,~,n_controls]=size(data_controls);
label=[ones(n_patients,1);zeros(n_controls,1)];%label
%% inmask
N=n_patients+n_controls;
data=reshape(data,[dim1*dim2*dim3,N]);%�з���Ϊ��������ÿһ��Ϊһ��������ÿһ��Ϊһ������
implicitmask = sum(data,2)~=0;%�ڲ�mask,�����ۼ�
data_inmask=data(implicitmask,:);%�ڲ�mask�ڵ�data
data_inmask=data_inmask';
%% Ԥ����ռ�
Accuracy=zeros(K,1);Sensitivity =zeros(K,1);Specificity=zeros(K,1);
AUC=zeros(K,1);Decision=cell(K,1);PPV=zeros(K,1); NPV=zeros(K,1);
w_Brain=zeros(K,sum(implicitmask));
label_ForPerformance=NaN(N,1);
w_M_Brain=zeros(1,dim1*dim2*dim3);
Predict=NaN(N,1);
%%  K fold loop
h = waitbar(0,'...');
indices = crossvalind('Kfold', N, K);%�˴�����������ӵ���ƣ����ÿ�ν�����ǲ�һ����
switch K<N
    case 1
        for i=1:K
            waitbar(i/K,h,sprintf('%2.0f%%', i/K*100)) ;
            %K fold
            test_index = (indices == i); train_index = ~test_index;
            train_data =data_inmask(train_index,:);
            train_label = label(train_index,:);
            test_data = data_inmask(test_index,:);
            test_label = label(test_index);
            j=sum(~isnan(label_ForPerformance))+1;
            label_ForPerformance(j:j+numel(test_label)-1,1)=test_label;
            %% ��ά����һ��
            %���з����һ��
            %             [train_data,test_data,~] = ...
            %                scaleForSVM(train_data,test_data,0,1);%һ���з����һ�����˴������飬����ʵ�ʽǶ���˵���ǿ��Եġ�
            [train_data,PS] = mapminmax(train_data');
            train_data=train_data';
            test_data = mapminmax('apply',test_data',PS);
            test_data =test_data';
            %% ѵ��ģ��
            CVMdl = fitclinear(train_data,train_label,'KFold',5,...
                'Learner','svm','Solver','sparsa','Regularization','lasso',...
                'Lambda',Lambda,'GradientTolerance',1e-8);%�ڲ�CV
            ce = kfoldLoss(CVMdl);%Estimate the cross-validated classification error.
            loc_MinMSE=find(ce==min(ce));
            loc_MinMSE=loc_MinMSE(1);
            Lambda_best= Lambda(loc_MinMSE);%�ڲ�CV�ҵ������lambda��best��
            Mdl= fitclinear(train_data,train_label,...
                'Learner','svm','Solver','sparsa','Regularization','lasso',...
                'Lambda',Lambda_best,'GradientTolerance',1e-8);%���lambda��train data��ѵ��ģ��
            %%
            [predict_label, dec_values] = predict(Mdl,test_data);
            Decision{i}=dec_values(:,2);
            %% ����ģ��
            [accuracy,sensitivity,specificity,ppv,npv]=Calculate_Performances(predict_label,test_label);
            Accuracy(i) =accuracy;
            Sensitivity(i) =sensitivity;
            Specificity(i) =specificity;
            PPV(i)=ppv;
            NPV(i)=npv;
            [AUC(i)]=AUC_LC(test_label,dec_values(:,2));
            %%  �ռ��б�ģʽ
            w_Brain_Component = Mdl.Beta;
            w_Brain(i,:) = w_Brain_Component;
        end
    case 0 %equal to leave one out cross validation, LOOCV
        for i=1:K
            waitbar(i/K,h,sprintf('%2.0f%%', i/K*100)) ;
            %K fold
            test_index = (indices == i); train_index = ~test_index;
            train_data =data_inmask(train_index,:);
            train_label = label(train_index,:);
            test_data = data_inmask(test_index,:);
            test_label = label(test_index);
            label_ForPerformance(i)=test_label;
            %% ��ά����һ��
            %���з����һ��
            %             [train_data,test_data,~] = ...
            %                scaleForSVM(train_data,test_data,0,1);%һ���з����һ�����˴������飬����ʵ�ʽǶ���˵���ǿ��Եġ�
            [train_data,PS] = mapminmax(train_data');
            train_data=train_data';
            test_data = mapminmax('apply',test_data',PS);
            test_data =test_data';
            %% ѵ��ģ��
            CVMdl = fitclinear(train_data,train_label,'KFold',5,...
                'Learner','svm','Solver','sparsa','Regularization','lasso',...
                'Lambda',Lambda,'GradientTolerance',1e-8);%�ڲ�CV
            ce = kfoldLoss(CVMdl);%Estimate the cross-validated classification error.
            loc_MinMSE=find(ce==min(ce));
            loc_MinMSE=loc_MinMSE(1);
            Lambda_best= Lambda(loc_MinMSE);%�ڲ�CV�ҵ������lambda��best��
            Mdl= fitclinear(train_data,train_label,...
                'Learner','svm','Solver','sparsa','Regularization','lasso',...
                'Lambda',Lambda_best,'GradientTolerance',1e-8);%���lambda��train data��ѵ��ģ��
            %%
            [predict_label, dec_values] = predict(Mdl,test_data);
            Decision{i}=dec_values(:,2);
            Predict(i,1)=predict_label;
            %%  �ռ��б�ģʽ
            w_Brain_Component = Mdl.Beta;
            w_Brain(i,:) = w_Brain_Component;
        end
end
%% ƽ���Ŀռ��б�ģʽ
W_mean=mean(w_Brain);%ȡ����LOOVC��w_brain��ƽ��ֵ
w_M_Brain(implicitmask)=W_mean;
w_M_Brain_3D=reshape(w_M_Brain,dim1,dim2,dim3);
%% �����������
Accuracy(isnan(Accuracy))=0; Sensitivity(isnan(Sensitivity))=0; Specificity(isnan(Specificity))=0;
PPV(isnan(PPV))=0; NPV(isnan(NPV))=0; AUC(isnan(AUC))=0;
%% ��ʾģ������ K < N
if K<N
    performances=[mean([Accuracy,Sensitivity, Specificity, PPV, NPV,AUC]);...
        std([Accuracy,Sensitivity, Specificity, PPV, NPV,AUC],1)];%��ʾ�������,std�ķ�ĸ�ǡ�N��
    performances=performances';
    f = figure;
    title(['Performance with',' ',num2str(K),'-fold']);
    axis off
    t = uitable(f);
    d = performances;
    t.Data = d;
    t.ColumnName = {'mean performance','std'};
    t.RowName={'MAccuracy','MSensitivity','MSpecificity','MPPV','MNPV','MAUC'};
    t.Position = [50 0 400 300];
end
close (h)
%% ��ʾģ������ K==N���ȼ���LOOCV
if K==N
    [Accuracy, Sensitivity, Specificity, PPV, NPV]=Calculate_Performances(Predict,label_ForPerformance);
    AUC=AUC_LC(label_ForPerformance,cell2mat(Decision));
    performances=[Accuracy, Sensitivity, Specificity, PPV, NPV,AUC]';%��ʾ�������
    f = figure;
    title(['Performance with',' ',num2str(K),'-fold']);
    axis off
    t = uitable(f);
    d = performances;
    t.Data = d;
    t.ColumnName = {'performance'};
    t.RowName={'Accuracy','Sensitivity','Specificity','PPV','NPV','AUC'};
    %             t.ColumnEditable = true;
    t.Position = [50 0 300 300];
end
%% �������Ȩ��ͼ��������
%gray matter mask
[file_name,path_source1,~]= uigetfile( ...
    {'*.img;*.nii;','All Image Files';...
    '*.*','All Files' },...
    '��ѡ��mask����ѡ��', ...
    'MultiSelect', 'off');
img_strut_temp=load_nii([path_source1,char(file_name)]);
mask_graymatter=img_strut_temp.img~=0;
w_M_Brain_3D(~mask_graymatter)=0;
% save nii
data=datestr(now,30);
Data2Img_LC(w_M_Brain_3D,['w_M_Brain_3D_',data,'.nii']);
%save results
%Ŀ¼
loc= find(path=='\');
outdir=path(1:loc(length(find(path=='\'))-2)-1);%path����һ��Ŀ¼
save([outdir filesep 'Results_MVPA.mat'],...
    'Accuracy', 'Sensitivity', 'Specificity',...
    'PPV', 'NPV', 'Decision', 'AUC', 'w_M_Brain', 'w_M_Brain_3D', 'label_ForPerformance');
%save mean performances as .tif figure
cd (outdir)
print(gcf,'-dtiff','-r600','Mean Performances')
end


