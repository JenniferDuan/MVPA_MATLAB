function [ Predict_label,Real_label,Decision ] = ...
    Logistic_Regression_ElasticNet(data,label,opt)
%����elastic net����������ɸѡ�������߼��ع�ģ��
%���룺��ο� FeatureSelection_Logistic_Regression_ElasticNet
%�����Ԥ���ǩ����ʵ��ǩ�Լ�Ӧ������ԭʼֵ������ROC��
%example
% data=rand(100,500);r=[1;2;3;4;5;6;7;8;9;8;7;6;5;4;3;2;1;1;2;3;4;5;6;7;8;9;9;8;7;6;5;4;3;21;zeros(500-34,1)];
%label=data*r;
%lambda=exp(-6:6);alpha=0.1:0.1:1;
%[ Predict_label{1},Real_label{1}]
%for i=1:K;[accuracy(i),sensitivity(i),specificity(i),PPV(i),NPV(i)]=Calculate_Performances(Predict_label{i},Real_label{i});end
%a=[accuracy;sensitivity;specificity;PPV;NPV]
%mean(a,2)
if nargin <3
opt.lambda=exp(-6:6);opt.alpha=0.1:0.1:1;opt.K=5;
end
%% ����׼��
label=label==1;%����1��Ϊ0.
[N,~]=size(data);
Predict_label=cell(opt.K,1); Real_label=cell(opt.K,1);Decision=cell(opt.K,1);
%% K fold ready
indices = crossvalind('Kfold', N, opt.K);
h=waitbar(0,'��ȴ� Outer Loop>>>>>>>>','Position',[50 50 280 60]);
set(h, 'Color','c');
for i = 1:opt.K
    %% ���ѭ��
    waitbar(i/opt.K);
    Test_index = (indices == i); Train_index = ~Test_index;
    Train_data=data(Train_index,:);Test_data=data(Test_index,:);%���ѭ����������data and ���ѭ��ѵ������data
    Train_label=label(Train_index,:);Test_label=label(Test_index,:);%���ѭ����������label and ���ѭ��ѵ������label
    %% ���뵥��������������
    [~,P,~,~]=ttest2(Train_data(Train_label==1,:), Train_data(Train_label==0,:),'Tail','both');
    Index_ttest2=find(P<=opt.P_threshold);%��С�ڵ���ĳ��Pֵ������ѡ�������
    Train_data= Train_data(:,Index_ttest2);
    Test_data=Test_data(:,Index_ttest2);
    %% �ڲ�Ƕ��ѭ��
    [ ~,~,~,B_final, Intercept_final] =...
        FeatureSelection_Logistic_Regression_ElasticNet(Train_data,Train_label,opt.lambda,opt.alpha,opt.K);
    %%
    % �����߼��ع�ģ�Ͳ�Ԥ������������
    B0=B_final;
    B1=[Intercept_final; B0];
    preds = glmval(B1,Test_data,'logit');
    Decision{i}=preds;
    Predict_label{i}= preds>=0.5; Real_label{i}=Test_label;
end
close (h)
end

