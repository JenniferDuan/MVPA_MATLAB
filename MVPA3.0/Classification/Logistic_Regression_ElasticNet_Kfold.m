function [ Predict_label,Real_label,B0,Decision ] = ...
          Logistic_Regression_ElasticNet_Kfold(data,label,lambda,alpha,K)
%����elastic net����������ɸѡ�������߼��ع�ģ��
%���룺��ο� FeatureSelection_Logistic_Regression_ElasticNet
%�����Ԥ���ǩ����ʵ��ǩ�Լ�Ӧ������ԭʼֵ������ROC��
%example
% data=rand(100,50);r=[1;2;3;4;5;6;7;8;9;8;7;6;5;4;3;2;1;1;2;3;4;5;6;7;8;9;9;8;7;6;5;4;3;21;zeros(50-34,1)];
%label=data*r;
%lambda=exp(-6:6);alpha=0.5:0.1:1;K=5;
%[ cell2mat(Predict_label),cell2mat(Real_label)]
%for i=1:K;[accuracy(i),sensitivity(i),specificity(i),PPV(i),NPV(i)]=Calculate_Performances(Predict_label{i},Real_label{i});end
%a=[accuracy;sensitivity;specificity;PPV;NPV]
%mean(a,2)
%% ����׼��
label=label==1;%����1��Ϊ0.
[N,~]=size(data);
Predict_label=cell(K,1); Real_label=cell(K,1);Decision=cell(K,1);
%% K fold ready
indices = crossvalind('Kfold', N, K);
h=waitbar(0,'��ȴ� Outer Loop>>>>>>>>','Position',[50 50 280 60]);
set(h, 'Color','c'); 
for i = 1:K
    %% ���ѭ��
    waitbar(i/K);
    test_index = (indices == i); train_index = ~test_index;
    train_data=data(train_index,:);test_data=data(test_index,:);%���ѭ����������data and ���ѭ��ѵ������data
    train_label=label(train_index,:);test_label=label(test_index,:);%���ѭ����������label and ���ѭ��ѵ������label
    %% �ڲ�Ƕ��ѭ��
        [ ~,~,~,B_final, Intercept_final] =...
          FeatureSelection_Logistic_Regression_ElasticNet(train_data,train_label,lambda,alpha,K);
    %%
      % �����߼��ع�ģ�Ͳ�Ԥ������������
      B0=B_final;
      B1=[Intercept_final; B0];
      preds = glmval(B1,test_data,'logit');
      Decision{i}=preds;
      Predict_label{i}= preds>=0.5; Real_label{i}=test_label;
end
Predict_label=cell2mat(Predict_label);Real_label=cell2mat(Real_label);
close (h)
end

