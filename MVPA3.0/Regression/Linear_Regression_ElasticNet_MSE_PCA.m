function [ Predict_label,Real_label, B_ALL,  M_B_ALL, MAE, R ] = ...
    Linear_Regression_ElasticNet_MSE_PCA(data,label,lambda,alpha,K)
%ע�⣺��Ӧ��PCA��άʱ�������������������Ԥ�ⲻ׼ȷ������<=����ʱ׼ȷ�Բ�������PCA��ǡ����������Ӧ�á�
%����elastic net����������ɸѡ���������Իع�ģ��
%���룺��ο� FeatureSelection_Linear_Regression_ElasticNet
%�����Ԥ���ǩ����ʵ��ǩ�Լ�Ӧ������ԭʼֵ���������ۻع����ܣ�Pearson���ϵ����mean absolute
%error(MAE)�ĵ�����ע��˶�����Ҫ��׼������Ϊԭʼ���ݲ����
%% ����׼��
%K=5;
% data=rand(100,50);r=[1;2;3;4;5;6;7;8;9;zeros(50-9,1)];label=data*r;
% lambda=exp(-6:6);alpha=0.1:0.1:1;
[N,M]=size(data);
B_ALL=NaN(K,M);
MAE=inf(K,1);
R=zeros(K,1);
indices = crossvalind('Kfold', N, K);
Predict_label=cell(K,1); Real_label=cell(K,1);
h=waitbar(0,'��ȴ� Outer Loop>>>>>>>>','Position',[50 50 280 60]);
set(h, 'Color','c');
for i = 1:K
    %% ���ѭ��
    waitbar(i/K);
    test_index = (indices == i); train_index = ~test_index;
    train_data=data(train_index,:);test_data=data(test_index,:);%���ѭ����������data and ���ѭ��ѵ������data
    train_label=label(train_index,:);test_label=label(test_index,:);%���ѭ����������label and ���ѭ��ѵ������label
    %% ��ά����һ��
    %���з����һ��
    %     [train_data,test_data,~] = ...
    %         scaleForSVM(train_data,test_data,0,1);%һ���з����һ�����˴������飬����ʵ�ʽǶ���˵���ǿ��Եġ�
%     [train_data,PS] = mapminmax(train_data');
%     train_data=train_data';
%     test_data = mapminmax('apply',test_data',PS);
%     test_data =test_data';
    %���ɷֽ�ά
    [COEFF, train_data] = pca(train_data);%�ֱ��ѵ�����������������������ɷֽ�ά��
%     train_data=train_data(:,1:10);
    test_data = test_data*COEFF;
%     test_data=test_data(:,1:10);
%         [train_data,PS] = mapminmax(train_data');
%     train_data=train_data';
%     test_data = mapminmax('apply',test_data',PS);
%     test_data =test_data';
    %% �ڲ�Ƕ��ѭ��
    [ ~,~,~,B_PCA, Intercept_final] =...
        FeatureSelection_Linear_Regression_ElasticNet_MSE(train_data,train_label,lambda,alpha,K);
    %%
    % �����߼��ع�ģ�Ͳ�Ԥ������������
    B_OrignalSpace = B_PCA' * COEFF';
    B_ALL(i,:)=B_OrignalSpace;
    M_B_ALL=mean(B_ALL);
    preds =test_data*B_PCA+ Intercept_final;
    Predict_label{i}= preds; Real_label{i}=test_label;
    MAE(i)=sum(abs(preds-test_label))/numel(test_data);
    [R(i),~]=corr(preds,test_label);
end
close (h)
end

