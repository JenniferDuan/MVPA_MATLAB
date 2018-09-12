clear;clc
data=rand(500,5000);
r=[(1:100)';zeros(5000-100,1)];
% r=rand(100,1);
label=data*r;
K=10;
Initial_FeatureQuantity=1;Step_FeatureQuantity=50;Max_FeatureQuantity=numel(label)/2;
    opt.stepmethod='percentage';opt.step=10;opt.learner='leastsquares';%linear regression leastsquares;
%============================================
[N,~]=size(data);
implicitmask = sum(data,1)~=0;%�ڲ�mask,�����ۼ�
data_inmask=data(:,implicitmask);%�ڲ�mask�ڵ�data
%%
PER=[];%��ͬ������Ŀ��ƽ���������
%% Ԥ����ռ�
w_M_Brain=zeros(1,sum(implicitmask));
Num_loop=length(Initial_FeatureQuantity:Step_FeatureQuantity:Max_FeatureQuantity);
Accuracy=zeros(K,Num_loop);Sensitivity =zeros(K,Num_loop);Specificity=zeros(K,Num_loop);
AUC=zeros(K,Num_loop);Decision=cell(K,Num_loop);PPV=zeros(K,Num_loop); NPV=zeros(K,Num_loop);
W_Brain=zeros(Num_loop,sum(implicitmask),K);
label_ForPerformance=cell(K,Max_FeatureQuantity);
Predict_label=cell(K,Max_FeatureQuantity);
%%  K fold loop
% ���߳�Ԥ��
% if nargin < 2
%   parworkers=0;%default
% end
% ���߳�׼�����
Predict_label=[];Test_perf=[];
h=waitbar(0,'��ȴ� Outer Loop>>>>>>>>','Position',[50 50 280 60]);
indices = crossvalind('Kfold', N, K);%�˴�����������ӵ���ƣ����ÿ�ν�����ǲ�һ����
for i=1:K
    waitbar(i/K,h,sprintf('%2.0f%%', i/K*100)) ;
    %K fold
    Test_index = (indices == i); Train_index = ~Test_index;
    Train_data =data_inmask(Train_index,:);
    Train_label = label(Train_index,:);
    Test_data = data_inmask(Test_index,:);
    Test_label = label(Test_index);
    %% inner loop: feature selection
    [ feature_ranking_list ] =  FeatureSelection_RFE_SVM_Regression( Train_data,Train_label,opt );
    j=0;%������ΪW_M_Brain��ֵ��
    h1 = waitbar(0,'...');
    for FeatureQuantity=Initial_FeatureQuantity:Step_FeatureQuantity:Max_FeatureQuantity % ��ͬfeature subset�����
        j=j+1;%������
        waitbar(j/Num_loop,h1,sprintf('%2.0f%%', j/Num_loop*100)) ;
        Index_selectfeature=feature_ranking_list(1:FeatureQuantity);
        train_data= Train_data(:,Index_selectfeature);
        test_data=Test_data(:,Index_selectfeature);
        label_ForPerformance{i,j}=Test_label;
        %���з����һ��
        % [train_data,test_data,~] = ...
        %    scaleForSVM(train_data,test_data,0,1);%һ���з����һ�����˴������飬����ʵ�ʽǶ���˵���ǿ��Եġ�
%         [train_data,PS] = mapminmax(train_data');
%         train_data=train_data';
%         test_data = mapminmax('apply',test_data',PS);
%         test_data =test_data';
        %% ѵ��ģ��&Ԥ��
        model= fitrlinear(train_data,Train_label);
        [predict_label] = predict(model,test_data);
        Predict_label{i,j}=predict_label;
        %%  �ռ��б�ģʽ
        w_Brain = model.Beta;
        W_Brain(j,Index_selectfeature,i) = w_Brain;%��W_Brian��Index(1:N_feature)����λ�õ�����Ȩ����Ϊ0
    end
    close (h1)
end
close (h)
%% ƽ���Ŀռ��б�ģʽ
W_mean=mean(W_Brain,3);%ȡ����LOOVC��w_brain��ƽ��ֵ��ע��˴����ǵ�loop��δ��ѡ�е����أ���������ǰ�潫��Ȩ����Ϊ0
W_M_Brain=W_mean;%��ͬfeature ��Ŀʱ��ȫ������Ȩ��
Predict_label=cell2mat(Predict_label);  label_ForPerformance=cell2mat(label_ForPerformance); 
mm=[Predict_label-label_ForPerformance];
mse=abs(sum(mm,1));
loc_minmae=find(mse==min(mse));
loc_minmae=loc_minmae(1);
aa=[Predict_label(:,loc_minmae),label_ForPerformance(:,1)];
 MAE_SVMALL=sum(abs(Predict_label(:,loc_minmae)-label_ForPerformance(:,1)))/numel(label_ForPerformance)
  [RSVMALL,P]=corr(Predict_label(:,loc_minmae),label_ForPerformance(:,1))
  best_W=W_M_Brain(loc_minmae,:);
  feature_array=Initial_FeatureQuantity:Step_FeatureQuantity:Max_FeatureQuantity;
  [best_W_ALL,Index_ALL]=sort(abs(best_W),'descend');
  Num_feature_best=feature_array(loc_minmae);
%   [best_W_ALL(ii,:),Index_ALL(ii,:)]=sort(abs(best_W),'descend');
%   best_W_M=mean(best_W_ALL);

