function [ NoZero_feature,lambda_best,alpha_best,B_final, Intercept_final] =...
           FeatureSelection_Logistic_Regression_ElasticNet(data,label,lambda,alpha,K)
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
Deviance1SE=inf(length(alpha),1);%����alpha��Ӧ����СMSE����
Lambda=zeros(length(alpha),1);%����alpha��Ӧ�����Lambda����
%% ���߳�
% initialize progress indicator
% parfor_progress(length(alpha));
% parfor(i = 1:length(alpha),parworkers)
%%
% hwait=waitbar(0,'��ȴ� Inner Loop>>>>>>>>');
    for i=1:length(alpha)
        [~,FitInfo] = lassoglm(data,label,'binomial',...
                               'Lambda',lambda,'Alpha',alpha(i),'CV',K);%Regularized Logistic regression using elastic net algorithms
        mse_Deviance1SE=FitInfo.Deviance(FitInfo.Index1SE);%ĳ��alphaֵʱ����СDeviance plus 1SE
        lambda_best=FitInfo.Lambda(FitInfo.Index1SE);%ĳ��alphaֵʱ�����lambda
        Deviance1SE(i)=mse_Deviance1SE;%����alpha��Ӧ����СDeviance plus 1SE����
        Lambda(i)=lambda_best;%����alpha��Ӧ�����Lambda����
%         waitbar(i/length(alpha));
    end
%     close (hwait)
lambda_best=Lambda(Deviance1SE==min(Deviance1SE));%����alpha��lambda�������ѵ�lambda
alpha_best=alpha(Deviance1SE==min(Deviance1SE));%����alpha��lambda�������ѵ�alpha
lambda_best=lambda_best(end);%����alpha��lambda�������ѵ�lambda
alpha_best=alpha_best(end);%����alpha��lambda�������ѵ�alpha
%% ����ѵ�alpha��lambda������elastic net regularized �ع�ģ�ͣ��Ӷ�ɸѡ������
[B_final ,FitInfo2] = lassoglm(data,label,'binomial','Lambda',lambda_best,'Alpha',alpha_best);
Intercept_final=FitInfo2.Intercept;
NoZero_feature=B_final~=0;%����ϵ����λ�ã��߼�������
end

