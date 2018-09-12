function [ PER,Accuracy, Sensitivity, Specificity, PPV, NPV, Decision, AUC, W_M_Brain,W_M_Brain_3D] =...
    SVM_LC_Kfold_ttest2(K,NMax_features,step)
%�˴�����heart���ݼ��ϲ��Գɹ�
%input��K=K-fold cross validation,K<N
%feature selection by ttest2
%output����������Լ�K-fold��ƽ������Ȩ��
% path=pwd;
% addpath(path);
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
PER=[];%��ͬ������Ŀ��ƽ���������
W_M_Brain=zeros(NMax_features,dim1*dim2*dim3);

%% �˴�����Ŀռ�̫����취��������������������������������������
%===================================
for N_feature=1:step:NMax_features % ��ͬ������Ŀ�����
%% Ԥ����ռ�
% w_M_Brain=zeros(1,sum(implicitmask));
Accuracy=zeros(K,1);Sensitivity =zeros(K,1);Specificity=zeros(K,1);
AUC=zeros(K,1);Decision=cell(K,1);PPV=zeros(K,1); NPV=zeros(K,1);
W_Brain=zeros(K,sum(implicitmask));
label_ForPerformance=NaN(N,1);
Predict=NaN(N,1);
%%  K fold loop
% ���߳�Ԥ��
% if nargin < 2
%   parworkers=0;%default
% end
% data_inmask1=data_inmask;
% data_inmask2=data_inmask;
% label1=label;
% label2=label;
% ���߳�׼�����
h = waitbar(0,'...');
% s=rng;%���ظ���һ��
% rng(s);%���ظ���һ��
indices = crossvalind('Kfold', N, K);%�˴�����������ӵ���ƣ����ÿ�ν�����ǲ�һ����
switch K<N
    case 1
        % initialize progress indicator
%         parfor_progress(K);
        for i=1:K
           waitbar(i/K,h,sprintf('%2.0f%%', i/K*100)) ;
            %K fold
            test_index = (indices == i); train_index = ~test_index;
            train_data =data_inmask(train_index,:);
            train_label = label(train_index,:);
            test_data = data_inmask(test_index,:);
            test_label = label(test_index);
          %% ttest2, feature selection and scale
            %ttest2
            [~,P,~,~]=ttest2(train_data(train_label==1,:), train_data(train_label==0,:));%patients VS controls;
            [P_sort,Index]=sort(P);
             train_data= train_data(:,Index(1:N_feature));
             test_data=test_data(:,Index(1:N_feature));
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
            w_Brain = model.Beta;
            W_Brain(i,Index(1:N_feature)) = w_Brain;%��W_Brian��Index(1:N_feature)����λ�õ�����Ȩ����Ϊ0
            %��Index(1:N_feature)�ڵ�Ȩ���򱻸�ֵ��ǰ����Ԥ����0������
%             if ~randi([0 4])
%                 parfor_progress;%������
%             end
        end
        close (h)
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
          %% ttest2, feature selection and scale
            %ttest2
            [~,P,~,~]=ttest2(train_data(train_label==1,:), train_data(train_label==0,:));%patients VS controls;
            [P_sort,Index]=sort(P);
             train_data= train_data(:,Index(1:N_feature));
             test_data=test_data(:,Index(1:N_feature));
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
            w_Brain = model.Beta;
            W_Brain(i,Index(1:N_feature)) = w_Brain;%��W_Brian��Index(1:N_feature)����λ�õ�����Ȩ����Ϊ0
            %��Index(1:N_feature)�ڵ�Ȩ���򱻸�ֵ��ǰ����Ԥ����0������
%             if ~randi([0 4])
%                 parfor_progress;%������
%             end
        end
        close (h)
end
%% ƽ���Ŀռ��б�ģʽ
W_mean=mean(W_Brain);%ȡ����LOOVC��w_brain��ƽ��ֵ��ע��˴����ǵ�loop��δ��ѡ�е����أ���������ǰ�潫��Ȩ����Ϊ0
W_M_Brain(N_feature,implicitmask)=W_mean;%��ͬ������Ŀʱ��ȫ������Ȩ��
% W_M_Brain_3D=reshape(W_M_Brain,dim1,dim2,dim3);
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
            PER=[PER performances];%��performanceΪ��ĳ��������Ŀ�£�K��fold��ƽ��ֵ��
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
            PER=[PER performances];%��performanceΪ��ĳ��������Ŀ�µ�ֵ����Ϊ��LOOCV����û��ƽ��ֵ�ͱ�׼�
        end     
end
           %% ��ʾ�ͱ���Ȩ��ͼ��
            %gray matter mask
            AUC_max=max(PER(6,(1:2:end)));%��ͬ������Ŀ�£�AUC��k-fold�µ�ƽ��ֵ�������ֵ��
            loc_MaxAUC=PER(6,(1:2:end))==AUC_max;
            feature_matrix=(1:step:NMax_features);
            location_Best_featureNum=feature_matrix(loc_MaxAUC);
            [file_name,path_source1,~] = uigetfile({'*.nii';'*.img'},'MultiSelect','off','��ѡ��maskģ��ͼ��');
            img_strut_temp=load_nii([path_source1,char(file_name)]);
            mask_graymatter=img_strut_temp.img~=0;
            W_M_Brain_BestAUC=W_M_Brain(location_Best_featureNum(1),:);%location_Best_featureNum(1)Ϊ������Ŀ���ٵģ�
            %��ѵ�location
            W_M_Brain_3D=reshape(W_M_Brain_BestAUC,dim1,dim2,dim3);
            W_M_Brain_3D(~mask_graymatter)=0;
            % save nii
            data=datestr(now,30);
            Data2Img_LC(W_M_Brain_3D,['W_M_Brain_3D_',data,'.nii'])
%% ��ͼ
Name_plot={'Accuracy','Sensitivity', 'Specificity', 'PPV', 'NPV','AUC'};
N_plot=length(1:step:NMax_features);
h=figure;
h.Name='Mean Performance';
for j=1:6
subplot(3,2,j);plot((1:step:NMax_features),PER(j,(1:2:2*N_plot)),'-');title(['Mean',' ',Name_plot{j}]);grid on;hold on;
end
g=figure;
g.Name= 'Std Performance';
for j=1:6
subplot(3,2,j);plot((1:step:NMax_features),PER(j,[2:2:2*N_plot]),'-');title( ['Std',' ',Name_plot{j}]);grid on;hold on;
end
end


