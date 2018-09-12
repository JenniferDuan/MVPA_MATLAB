function [ Predict_label,Real_label, B_ALL,  M_B_ALL, MAE, R ] = ...
    PQSQ_Linear_regressin(data,label,lambda, K)
%refer to github��
%�˺����� Linear_Regression_ElasticNet_MSE�죬����ȷ���Եͣ����ܽ���
%���á�PQSQ����������������ɸѡ���������Իع�ģ��
%input �ο�����
%output B_ALL ����Kfold��ϵ����M_B_ALL= average ϵ�� ��MAE=����ƽ����R=Pearson ���ϵ��
%example
% data=rand(100,50);r=[1;2;3;4;5;6;7;8;9;8;7;6;5;4;3;2;1;1;2;3;4;5;6;7;8;9;9;8;7;6;5;4;3;21;zeros(50-34,1)];
% label=data*r;
% lambda=exp(-6:6);alpha=0.1:0.1:1;
%  [ Predict_label,Real_label]
%% ����׼��
[N,M]=size(data);
B_ALL=NaN(K,M);
MAE=inf(K,1);
R=zeros(K,1);
indices = crossvalind('Kfold', N, K);
Predict_label=cell(K,1); Real_label=cell(K,1);
h=waitbar(0,'��ȴ� >>>>>>>>','Position',[50 50 280 60]);
set(h, 'Color','c');
for i = 1:K
    %% ���ѭ��
    waitbar(i/K);
    test_index = (indices == i); train_index = ~test_index;
    train_data=data(train_index,:);test_data=data(test_index,:);%���ѭ����������data and ���ѭ��ѵ������data
    train_label=label(train_index,:);test_label=label(test_index,:);%���ѭ����������label and ���ѭ��ѵ������label
    %% Train Baysian Gaussian Linear regressin
    [B, FitInfo] = PQSQRegularRegr(train_data,train_label,'Lambda',lambda);
    loc_bestMSE=FitInfo.MSE==min(FitInfo.MSE);B_best=B(:,loc_bestMSE);
    %% Predict
    B_ALL(i,:)=B_best;
    M_B_ALL=mean(B_ALL);
    preds =test_data*B_best+FitInfo.Intercept( loc_bestMSE);
    Predict_label{i}= preds; Real_label{i}=test_label;
    MAE(i)=sum(abs(preds-test_label))/numel(test_label);
    [R(i),~]=corr(preds,test_label);
end
Predict_label=cell2mat(Predict_label); Real_label=cell2mat(Real_label);
close (h)
end

