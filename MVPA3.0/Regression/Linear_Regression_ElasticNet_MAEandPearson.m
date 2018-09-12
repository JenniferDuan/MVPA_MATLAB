function [ Predict_label,Real_label, B_ALL, M_B_ALL, MAE, R ] = ...
    Linear_Regression_ElasticNet_MAEandPearson(data,label,lambda,alpha,K)
%�κ�������û��~MSE�ĸ�
%����elastic net����������ɸѡ���������Իع�ģ��
%���룺��ο� FeatureSelection_Linear_Regression_ElasticNet
%�����Ԥ���ǩ����ʵ��ǩ�Լ�Ӧ������ԭʼֵ���������ۻع����ܣ�Pearson���ϵ����mean absolute
%error(MAE)�ĵ�����ע��˶�����Ҫ��׼������Ϊԭʼ���ݲ����
%% ����׼��
[N,M]=size(data);
MAE=inf(K,1);
R=zeros(K,1);
B_ALL=NaN(K,M);
indices = crossvalind('Kfold', N, K);
Predict_label=cell(K,1); Real_label=cell(K,1);
h=waitbar(0,'��ȴ� Outer Loop>>>>>>>>','Position',[50 50 280 60]);
set(h, 'Color','c');
for i = 1:K
    %% ���ѭ�� Outer
    waitbar(i/K);
    test_index_out = (indices == i); train_index_out = ~test_index_out;
    train_data_out=data(train_index_out,:);test_data_out=data(test_index_out,:);%���ѭ����������data and ���ѭ��ѵ������data
    train_label_out=label(train_index_out,:);test_label_out=label(test_index_out,:);%���ѭ����������label and ���ѭ��ѵ������label
    %% �ڲ�Ƕ��ѭ�� Inner
    [lambda_best,alpha_best, ~,~]=...
        FeatureSelection_Linear_Regression_ElasticNet_MAEandPearson(train_data_out,train_label_out,alpha,lambda,K);
    [B,FitInfo] = lasso(train_data_out,train_label_out,'Alpha',alpha_best,'Lambda',lambda_best);
    % �����߼��ع�ģ�Ͳ�Ԥ������������
    B_ALL(i,:)=B;
    M_B_ALL=mean(B_ALL);
    preds =test_data_out*B+ FitInfo.Intercept;
    Predict_label{i}= preds; Real_label{i}=test_label_out;
    MAE(i)=sum(abs(preds-test_label_out))/numel(test_data_out);
    [R(i),~]=corr(preds,test_label_out);
end
close (h)
end

