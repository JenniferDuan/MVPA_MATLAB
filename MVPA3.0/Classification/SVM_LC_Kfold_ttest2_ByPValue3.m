function [ PER,Accuracy, Sensitivity, Specificity, PPV, NPV, Decision, AUC, W_M_Brain,performances] =...
    SVM_LC_Kfold_ttest2_ByPValue3(K,Initial_PValue,Max_PValue,Step_PValue,opt)
%feature selection by ttest2
%�˴�����heart���ݼ��ϲ��Գɹ�
%input��K=K-fold cross validation,K<N
%input:Initial_FeatureNum=��ʼ����������Max_FeatureNum=�����������Step_FeatureNum=ÿ�����ӵ���������
%output����������Լ�K-fold��ƽ������Ȩ��
% path=pwd;
% addpath(path);
if nargin<5
    opt.standard='normalizing';
end
if nargin<1
    K=3;Initial_PValue=0.01;Max_PValue=0.1;Step_PValue=0.005;
    opt.standard='normalizing';
end

%% transform .nii/.img into .mat data, and achive corresponding label
[~,~,data_patients ] = Img2Data_LC;
[~,~,data_controls ] = Img2Data_LC;
[dim1,dim2,dim3,n_patients]=size(data_patients);
[~,~,~,n_controls]=size(data_controls);
data=cat(4,data_patients,data_controls);%data
label=[ones(n_patients,1);zeros(n_controls,1)];%label
%% just keep data in inmask
N=n_patients+n_controls;
data=reshape(data,[dim1*dim2*dim3,N]);%�з���Ϊ��������ÿһ��Ϊһ��������ÿһ��Ϊһ������
implicitmask = sum(data,2)~=0;%�ڲ�mask,�����ۼ�
data_inmask=data(implicitmask,:);%�ڲ�mask�ڵ�data
data_inmask=data_inmask';
data_inmask_p=data_inmask(label==1,:);
data_inmask_c=data_inmask(label==0,:);
%%
PER=[];%��ͬ������Ŀ��ƽ���������
% for PValue=Initial_PValue:Step_PValue:Max_PValue % ��ͬ������Ŀ�����
%% Ԥ����ռ�
% w_M_Brain=zeros(1,sum(implicitmask));
Num_loop_Pvalue=length(Initial_PValue:Step_PValue:Max_PValue);
Accuracy=zeros(K,Num_loop_Pvalue);Sensitivity =zeros(K,Num_loop_Pvalue);Specificity=zeros(K,Num_loop_Pvalue);
AUC=zeros(K,Num_loop_Pvalue);Decision=cell(K,Num_loop_Pvalue);PPV=zeros(K,Num_loop_Pvalue); NPV=zeros(K,Num_loop_Pvalue);
W_M_Brain=zeros(Num_loop_Pvalue,dim1*dim2*dim3);
W_Brain=zeros(Num_loop_Pvalue,sum(implicitmask),K);%weight map of implicit mask
label_ForPerformance=NaN(N,1);
Predict=NaN(K,N,1);
%%  K fold loop
% ���߳�Ԥ��
% if nargin < 2
%   parworkers=0;%default
% end
% ���߳�׼�����
h=waitbar(0,'��ȴ� Outer Loop>>>>>>>>','Position',[50 50 280 60]);
% s=rng;%���ظ���һ��
% rng(s);%���ظ���һ��
indices = crossvalind('Kfold', N, K);%�˴�����������ӵ���ƣ����ÿ�ν�����ǲ�һ����
indices_p = crossvalind('Kfold', n_patients, K);%�˴�����������ӵ���ƣ����ÿ�ν�����ǲ�һ����
indices_c = crossvalind('Kfold', n_controls, K);%�˴�����������ӵ���ƣ����ÿ�ν�����ǲ�һ����
switch K<N
    case 1
        % initialize progress indicator
        %         parfor_progress(K);
        for i=1:K
            waitbar(i/K,h,sprintf('%2.0f%%', i/K*100)) ;
            %% �����ݷֳ�ѵ�������Ͳ����������ֱ�ӻ��ߺͶ������г�ȡ��Ŀ����Ϊ������ƽ�⣩
            % patients data
            Test_index_p = (indices_p == i); Train_index_p = ~Test_index_p;
            Test_data_p =data_inmask_p(Test_index_p,:);Train_data_p =data_inmask_p(Train_index_p,:);
            % controls data
            Test_index_c = (indices_c == i); Train_index_c = ~Test_index_c;
            Test_data_c =data_inmask_c(Test_index_c,:);Train_data_c =data_inmask_c(Train_index_c,:);
            % all data
            Train_data=[Train_data_p;Train_data_c];
            Test_data=[Test_data_p;Test_data_c];
            % all label
            Test_label = [ones(sum(indices_p==i),1);zeros(sum(indices_c==i),1)];
            Train_label =  [ones(sum(indices_p~=i),1);zeros(sum(indices_c~=i),1)];
            %˫����t���飨filter��
            [~,P,~,~]=ttest2(Train_data(Train_label==1,:), Train_data(Train_label==0,:),'Tail','both');
            %% inner loop: ttest2, feature selection and scale
            j=0;%������ΪW_M_Brain��ֵ��
            h1 = waitbar(0,'...');
            for PValue=Initial_PValue:Step_PValue:Max_PValue % ��ͬP value�����
                j=j+1;%������
                waitbar(j/Num_loop_Pvalue,h1,sprintf('%2.0f%%', j/Num_loop_Pvalue*100)) ;
                Index=find(P<=PValue);%��С�ڵ���ĳ��Pֵ������ѡ�������
                train_data= Train_data(:,Index);
                test_data=Test_data(:,Index);
                % step2�� ��׼�����߹�һ��
                if strcmp(opt.standard,'normalizing')
                    MeanValue = mean(Train_data);
                    StandardDeviation = std(Train_data);
                    [row_quantity, columns_quantity] = size(Train_data);
                Train_data_temp=zeros(row_quantity, columns_quantity);
                for ii = 1:columns_quantity
                    if StandardDeviation(ii)
                        Train_data_temp(:, ii) = (Train_data(:, ii) - MeanValue(ii)) / StandardDeviation(ii);
                    end
                end
                Test_data_temp = (Test_data - MeanValue) ./ StandardDeviation;
                Train_data=Train_data_temp;Test_data=Test_data_temp;
            end
            
            if strcmp(opt.standard,'scale')
                [Train_data_temp,PS] = mapminmax(Train_data');
                Train_data_temp=Train_data_temp';
                Test_data_temp = mapminmax('apply',Test_data',PS);
                Test_data_temp =Test_data_temp';
                Train_data=Train_data_temp;Test_data=Test_data_temp;
            end
                %% ѵ��ģ��
                model= fitcsvm(train_data,Train_label);
                %%
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
                w_Brain = model.Beta;
                W_Brain(j,Index,i) = w_Brain;%��W_Brian��Index(1:N_feature)����λ�õ�����Ȩ����Ϊ0
                %��Index(1:N_feature)�ڵ�Ȩ���򱻸�ֵ��ǰ����Ԥ����0������
                %             if ~randi([0 4])
                %                 parfor_progress;%������
                %             end
            end
            close (h1)
        end
        close (h)
    case 0 %equal to leave one out cross validation, LOOCV
        clear Predict
        for i=1:K
            waitbar(i/K,h,sprintf('%2.0f%%', i/K*100)) ;
            %K fold
            test_index = (indices == i); train_index = ~test_index;
            Train_data =data_inmask(train_index,:);
            Train_label = label(train_index,:);
            Test_data = data_inmask(test_index,:);
            Test_label = label(test_index);
            label_ForPerformance(i)=Test_label;
            [~,P,~,~]=ttest2(Train_data(Train_label==1,:), Train_data(Train_label==0,:));%patients VS controls;
            %% ttest2, feature selection and scale
            %% inner loop: ttest2, feature selection and scale
            j=0;%������ΪW_M_Brain��ֵ��
            h1 = waitbar(0,'...');
            for PValue=Initial_PValue:Step_PValue:Max_PValue % ��ͬ������Ŀ�����
                j=j+1;%������
                waitbar(j/Num_loop_Pvalue,h1,sprintf('%2.0f%%', j/Num_loop_Pvalue*100)) ;
                Index=find(P<=PValue);%��С�ڵ���ĳ��Pֵ������ѡ�������
                train_data= Train_data(:,Index);
                test_data=Test_data(:,Index);
                %���з����һ��
                % [train_data,test_data,~] = ...
                %    scaleForSVM(train_data,test_data,0,1);%һ���з����һ�����˴������飬����ʵ�ʽǶ���˵���ǿ��Եġ�
                [train_data,PS] = mapminmax(train_data');
                train_data=train_data';
                test_data = mapminmax('apply',test_data',PS);
                test_data =test_data';
                %% ѵ��ģ��
                model= fitclinear(train_data,Train_label);
                %% Ԥ�� or ����
                [predict_label, dec_values] = predict(model,test_data);
                Decision{i,j}=dec_values(:,2);
                Predict(i,j)=predict_label;
                %%  �ռ��б�ģʽ
                w_Brain = model.Beta;
                W_Brain(j,Index,i) = w_Brain;%��W_Brian��Index(1:N_feature)����λ�õ�����Ȩ����Ϊ0
                %��Index(1:N_feature)�ڵ�Ȩ���򱻸�ֵ��ǰ����Ԥ����0������
                %             if ~randi([0 4])
                %                 parfor_progress;%������
                %             end
            end
            close (h1)
        end
        close (h)
end
%% ƽ���Ŀռ��б�ģʽ
W_mean=mean(W_Brain,3);%ȡ����LOOVC��w_brain��ƽ��ֵ��ע��˴����ǵ�loop��δ��ѡ�е����أ���������ǰ�潫��Ȩ����Ϊ0
W_M_Brain(:,implicitmask)=W_mean;%��ͬP valueʱ��ȫ������Ȩ��
% W_M_Brain_3D=reshape(W_M_Brain,dim1,dim2,dim3);
%% �����������
Accuracy(isnan(Accuracy))=0; Sensitivity(isnan(Sensitivity))=0; Specificity(isnan(Specificity))=0;
PPV(isnan(PPV))=0; NPV(isnan(NPV))=0; AUC(isnan(AUC))=0;
%% ��ʾģ������ K < N
if K<N
    performances=[[mean(Accuracy);mean(Sensitivity);mean(Specificity);mean(PPV);mean(NPV);mean(AUC)],...
        [std(Accuracy);std(Sensitivity);std(Specificity);std(PPV);std(NPV);std(AUC)]];%ǰһ����Mean ��һ����Std
end
%% ��ʾģ������ K==N���ȼ���LOOCV
if K==N
    clear Accuracy Sensitivity Specificity PPV NPV AUC
    for k=1:size(Predict,2)
        [Accuracy(k), Sensitivity(k), Specificity(k), PPV(k), NPV(k)]=Calculate_Performances(Predict(:,k),label_ForPerformance);
        AUC(k)=AUC_LC(label_ForPerformance,cell2mat(Decision(:,k)));
        performances=[Accuracy;Sensitivity;Specificity;PPV;NPV];%��ʾ�������
    end
end

%% visualize performance
Name_plot={'accuracy','sensitivity', 'specificity', 'PPV', 'NPV','AUC'};
N_plot=length(Initial_PValue:Step_PValue:Max_PValue);
h=figure;
h.Name='Mean performance';
% for j=1:6
% subplot(3,2,j);
plot((Initial_PValue:Step_PValue:Max_PValue),performances(1,(1:1:N_plot)),'-','markersize',10,'LineWidth',3.5);
hold on;
plot((Initial_PValue:Step_PValue:Max_PValue),performances(2,(1:1:N_plot)),'-','markersize',10,'LineWidth',3.5);
hold on;
plot((Initial_PValue:Step_PValue:Max_PValue),performances(3,(1:1:N_plot)),'-','markersize',10,'LineWidth',3.5);
% plot((Initial_PValue:Step_PValue:Max_PValue),PER(1,[2:2:2*N_plot]),'--o','LineWidth',3);
xlabel('P value','FontName','Times New Roman','FontWeight','bold','FontSize',20);
ylabel([Name_plot{6}],'FontName','Times New Roman','FontWeight','bold','FontSize',20);
set(gca,'Fontsize',15);%�������������С
fig=legend('accuracy','sensitivity', 'specificity');
% fig=legend('mean','standard deviation');
set(fig,'Fontsize',15);%����legend�����С
fig.Location='NorthEastOutside';
% set(gca,'XTick',Initial_PValue:Step_PValue:Max_PValue);%����x��ļ������Χ��
xlim([0 Max_PValue]);
set(gca,'YTick',0.1:0.1:1);%����y��ļ������Χ��
grid on;
%% errorbar
if K<N
    h1=figure;
    h1.Name='accuracy';
    errorbar((Initial_PValue:Step_PValue:Max_PValue),performances(1,(1:1:N_plot)),performances(3,(N_plot+1:1:2*N_plot)))
end
end

