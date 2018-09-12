function [ Predict_label,Real_label, MAE, R ] = ...
    Linear_Regression_ElasticNet_MAEandPearson_PCA(data,label,lambda,alpha,K)
%����elastic net����������ɸѡ���������Իع�ģ��
%���룺��ο� FeatureSelection_Linear_Regression_ElasticNet
%�����Ԥ���ǩ����ʵ��ǩ�Լ�Ӧ������ԭʼֵ���������ۻع����ܣ�Pearson���ϵ����mean absolute
%error(MAE)�ĵ�����ע��˶�����Ҫ��׼������Ϊԭʼ���ݲ����
%% ����׼��
[N,M]=size(data);
B_ALL=NaN(K,M);
MAE=inf(K,1);
R=zeros(K,1);
indices = crossvalind('Kfold', N, K);
Predict_label=cell(K,1); Real_label=cell(K,1);
h=waitbar(0,'��ȴ� Outer Loop>>>>>>>>','Position',[50 50 280 60]);
set(h, 'Color','c');
for i = 1:K
    %% ���ѭ�� Outer
    waitbar(i/K);
    test_index_out = (indices == i); train_index_out = ~test_index_out;
    train_data=data(train_index_out,:);test_data=data(test_index_out,:);%���ѭ����������data and ���ѭ��ѵ������data
    train_label=label(train_index_out,:);test_label=label(test_index_out,:);%���ѭ����������label and ���ѭ��ѵ������label
    %% ��ά����һ��
    %���з����һ��
%     [train_data,test_data,~] = ...
%         scaleForSVM(train_data,test_data,0,1);%һ���з����һ�����˴������飬����ʵ�ʽǶ���˵���ǿ��Եġ�
%                 [train_data,PS] = mapminmax(train_data');
%                 train_data=train_data';
%                 test_data = mapminmax('apply',test_data',PS);
%                 test_data =test_data';
    %���ɷֽ�ά
    [COEFF, train_data] = pca(train_data);%�ֱ��ѵ�����������������������ɷֽ�ά��
    test_data = test_data*COEFF;
    %% �ڲ�Ƕ��ѭ�� Inner
    [lambda_best,alpha_best, ~,~]=...
        FeatureSelection_Linear_Regression_ElasticNet_MAEandPearson(train_data,train_label,alpha,lambda,K);
    [B_PCA,FitInfo] = lasso(train_data,train_label,'Alpha',alpha_best,'Lambda',lambda_best);
    % �����߼��ع�ģ�Ͳ�Ԥ������������
    B_OrignalSpace = B_PCA' * COEFF';
    B_ALL(i,:)=B_OrignalSpace;
    preds =test_data*B_PCA+ FitInfo.Intercept;
    Predict_label{i}= preds; Real_label{i}=test_label;
    MAE(i)=sum(abs(preds-test_label))/numel(test_data);
    [R(i),~]=corr(preds,test_label);
end
close (h)
end

