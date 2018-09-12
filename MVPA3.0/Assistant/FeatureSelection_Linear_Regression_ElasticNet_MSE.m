function [ NoZero_feature,lambda_best,alpha_best,B_final, Intercept_final] =...
           FeatureSelection_Linear_Regression_ElasticNet_MSE(data,label,lambda,alpha,K)
%�˺�����~MAEandPearson�ľ��ȸ�
%author email:lichao19870617@gmail.com; please feel free to contact me
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
%%
MSE=inf(length(alpha),1);%����alpha��Ӧ����СMSE����
Lambda=zeros(length(alpha),1);%����alpha��Ӧ�����Lambda����
%% ���߳�
% initialize progress indicator
% parfor_progress(length(alpha));
% parfor(i = 1:length(alpha),parworkers)
%%
hwait=waitbar(0,'��ȴ� Inner Loop>>>>>>>>');
    for i=1:length(alpha)
        waitbar(i/length(alpha));
        [~,FitInfo] = lasso(data,label,'Lambda',lambda,'Alpha',alpha(i),'CV',K);%Regularized least-squares regression using elastic net algorithms
        mse_min=FitInfo.MSE(FitInfo.IndexMinMSE);%ĳ��alphaֵʱ����СMSE
        lambda_best=FitInfo.Lambda(FitInfo.IndexMinMSE);%ĳ��alphaֵʱ�����lambda
        MSE(i)=mse_min;%����alpha��Ӧ����СMSE����
        Lambda(i)=lambda_best;%����alpha��Ӧ�����Lambda����
%         parfor_progress;
    end
    close (hwait)
lambda_best=Lambda(MSE==min(MSE));
lambda_best=lambda_best(end);%����alpha��lambda�������ѵ�lambda
alpha_best=alpha(MSE==min(MSE));
alpha_best=alpha_best(end);%����alpha��lambda�������ѵ�alpha
%% ����ѵ�alpha��lambda�������ع�ģ�ͣ��Ӷ�ɸѡ������
[B_final ,FitInfo2] = lasso(data,label,'Lambda',lambda_best,'Alpha',alpha_best);
Intercept_final=FitInfo2.Intercept;
NoZero_feature=B_final~=0;%����ϵ����λ�ã��߼�������
end

