function [Accuracy, Sensitivity, Specificity, PPV, NPV, Decision, AUC, w_M_Brain, w_M_Brain_3D] =...
    SVM_LC_Kfold_PCA_Par(K,parworkers)
%�˴�����heart���ݼ��ϲ��Գɹ�
%input��K=K-fold cross validation,K<N
%output����������Լ�K-fold��ƽ������Ȩ��
%% ��ͼ��תΪdata,������label
[~,~,data_patients ] = Img2Data_LC;
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
% ���߳�Ԥ��
if nargin < 2
  parworkers=0;%default
end
% data_inmask1=data_inmask;
% data_inmask2=data_inmask;
% label1=label;
% label2=label;
% ���߳�׼�����
s=rng(1);%���ظ���һ��
rng(s);%���ظ���һ��
indices = crossvalind('Kfold', N, K);
switch K<N
    case 1
        % initialize progress indicator
        parfor_progress(K);
        parfor (i=1:K,parworkers)
%             waitbar(i/K,h,sprintf('%2.0f',i)) ;
            %K fold
            test_index = (indices == i); train_index = ~test_index;
            train_data =data_inmask(train_index,:);
            train_label = label(train_index,:);
            test_data = data_inmask((indices == i),:);
            test_label = label(test_index,:);
            %% ��ά����һ��
            %���ɷֽ�ά
            [COEFF, train_data] = pca(train_data);%�ֱ��ѵ�����������������������ɷֽ�ά��
            test_data = test_data*COEFF;
            %���з����һ��
            % [train_data,test_data,~] = ...
            %    scaleForSVM(train_data,test_data,0,1);%һ���з����һ�����˴������飬����ʵ�ʽǶ���˵���ǿ��Եġ�
            [train_data,PS] = mapminmax(train_data');
            train_data=train_data';
            test_data = mapminmax('apply',test_data',PS);
            test_data =test_data';
            %% ѵ��ģ��
            model= fitclinear(train_data,train_label);
            %%
            [predict_label, dec_values] = predict(model,test_data);
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
            w_Brain_Component = model.Beta;
            w_Brain(i,:) = w_Brain_Component' * COEFF';
            if ~randi([0 4])
                parfor_progress;%������
            end
        end
        parfor_progress(0);
%% ��һ������֤
    case 0 %equal to leave one out cross validation, LOOCV
        parfor_progress(K);
        parfor (i=1:K,parworkers)
%             waitbar(i/K,h,sprintf('%2.0f',i)) ;
            %K fold
          new_data = data_inmask; new_label = label;
          test_data = data_inmask(i,:);new_data(i,:) = []; train_data = new_data;
          test_label = label(i,:);new_label(i,:) = [];train_label = new_label;
           label_ForPerformance(i)=test_label;
            %% ��ά����һ��
            %���ɷֽ�ά
            [COEFF, train_data] = pca(train_data);%�ֱ��ѵ�����������������������ɷֽ�ά��
            test_data = test_data*COEFF;
            %���з����һ��
            % [train_data,test_data,~] = ...
            %    scaleForSVM(train_data,test_data,0,1);%һ���з����һ�����˴������飬����ʵ�ʽǶ���˵���ǿ��Եġ�
            [train_data,PS] = mapminmax(train_data');
            train_data=train_data';
            test_data = mapminmax('apply',test_data',PS);
            test_data =test_data';
            %% ѵ��ģ��
            model= fitclinear(train_data,train_label);
            %%
            [predict_label, dec_values] = predict(model,test_data);
            Decision{i}=dec_values(:,2);
            Predict(i,1)=predict_label;
            %%  �ռ��б�ģʽ
            w_Brain_Component = model.Beta;
            w_Brain(i,:) = w_Brain_Component' * COEFF';
%             if ~randi([0 4])
                parfor_progress;%������
%             end
        end
        parfor_progress(0);
end
%% ƽ���Ŀռ��б�ģʽ
W_mean=mean(w_Brain);%ȡ����LOOVC��w_brain��ƽ��ֵ
w_M_Brain(implicitmask)=W_mean;
w_M_Brain_3D=reshape(w_M_Brain,dim1,dim2,dim3);
%% ��ʾģ������ K < N
        if K<N
           performances=[mean([Accuracy,Sensitivity, Specificity, PPV, NPV,AUC]);...
           std([Accuracy,Sensitivity, Specificity, PPV, NPV,AUC])];%��ʾ�������
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
%% ��ʾͼ��
Data2Img_LC(w_M_Brain_3D,'w_M_Brain_3D.nii')

