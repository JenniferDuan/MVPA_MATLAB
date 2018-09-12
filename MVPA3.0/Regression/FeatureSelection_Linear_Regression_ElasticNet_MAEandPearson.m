function [lambda_best,alpha_best, M_MAE_best, M_R_best]=...
          FeatureSelection_Linear_Regression_ElasticNet_MAEandPearson(data,label,alpha,lambda,K)
%author email:lichao19870617@gmail.com; please feel free to contact me
%�ο������������� cerebral cortex �ڿ�
%Regularized least-squares regression using lasso or elastic net
%��lasso��Ϊlassoglm,��ִ��lasso�����һ������ģ��,��Ӧ��������'binomial'�ֲ�ʱ����Ϊlogistics�ع飨MATLAB example��Regularize Logistic Regression��
%algorithms(least-squares��min(1/2(f(x)-y)^2))
%��Nested cross validation����������ѡ��
% refrence: Individualized Prediction of Reading Comprehension Ability Using Gray Matter Volume;doi: 10.1093/cercor/bhx061
%input======lambdaΪһ����ֵ��������Խ����ϵ��Խ�ࣨlambda=e^gama,gama=[-6,5]��
%alphaΪһ����ֵ��������alpha=1Ϊlasso�ع飬=0Ϊ��ع飬������ֵΪElastic Net �ع�,alpha=[0.1,1]
%k����k-fold ������֤
%output=====NoZero_feature=ϵ��Ϊ�����������mask;
%lambda_best=���lambda,
%alpha_best=���alpha,
%B_final=���յ�ϵ��������0ϵ����,
%Intercept_final=���սؾࣨbeta0/bias��
%ע�⣺������û�н��������淶��Ԥ����
%Regularize Logistic Regression���Կ��ӻ�lambda��ϵ���Ĺ�ϵ��
%% Ԥ����ռ�
[N,~]=size(data);
%  B_final=cell(length(alpha),length(lambda),K);
MAE=inf(length(alpha),length(lambda),K);
R=zeros(length(alpha),length(lambda),K);
%% loop
hwait=waitbar(0,'��ȴ� Inner Loop>>>>>>>>');set(hwait, 'Color','c');
for i=1:length(alpha)
    for j=1:length(lambda)
        indices = crossvalind('Kfold', N, K);
        for k = 1:K
            %% �ڲ�K-fold
            test_index = (indices == k); train_index_out = ~test_index;
            data_train=data(train_index_out,:);data_test=data(test_index,:);%���ѭ����������data and ���ѭ��ѵ������data
            label_train=label(train_index_out,:);label_test=label(test_index,:);%���ѭ����������label and ���ѭ��ѵ������label
            [B,FitInfo] = lasso(data_train,label_train,'Lambda',lambda(j),'Alpha',alpha(i));
            preds =data_test*B+ FitInfo.Intercept;
            MAE(i,j,k)=sum(abs(preds-label_test))/numel(label_test);
            [R(i,j,k),~]=corr(preds,label_test);
        end
    end
    waitbar(i/length(alpha)); 
end
%% ����MAE��R�ļ�Ȩ��score��R��+1/zscore(MAE)
clear i j k;
M_MAE=mean(MAE,3);
M_R=mean(R,3);
M_MAE(isnan(M_MAE))=inf;
M_R(isnan(M_R))=0;
zscore_MAE=zscore(M_MAE(:)); zscore_MAE=reshape(zscore_MAE,length(alpha),length(lambda));
zscore_R=zscore(M_R(:)); zscore_R=reshape(zscore_R,length(alpha),length(lambda));
accuracy_weighted=zscore_R+1./zscore_MAE;
[i,j]=find(accuracy_weighted==max(accuracy_weighted(:)));
alpha_best=alpha(i);lambda_best=lambda(j); M_MAE_best=M_MAE(i,j); M_R_best=M_R(i,j);
close(hwait)
end

