function univariateFilterBeforeRFE()
% ��RFE֮ǰ���뵥������ttest2�����������ˣ��Լ��ټ��㸺��
% input:
%
%
%
%%
% step3�����뵥��������������
[~,P,~,~]=ttest2(Train_data(Train_label==1,:), Train_data(Train_label==2,:),'Tail','both');
Index_ttest2=find(P<=opt.P_threshold);%��С�ڵ���ĳ��Pֵ������ѡ�������
Train_data= Train_data(:,Index_ttest2);
Test_data=Test_data(:,Index_ttest2);
% step4��Feature selection---RFE
[ feature_ranking_list ] = FeatureSelection_RFE_SVM2( Train_data,Train_label,opt );
% step5�� training model and predict test data using different feature subsets which were selected by step4
j=0; % ����;
if ~opt.permutation; h2 = waitbar(0,'...');end
% for FeatureQuantity=opt.Initial_FeatureQuantity:opt.Step_FeatureQuantity:opt.Max_FeatureQuantity %
FeatureQuantity=opt.Initial_FeatureQuantity; % initiate FeatureQuantity
while FeatureQuantity<=opt.Max_FeatureQuantity && FeatureQuantity<=length(Index_ttest2)
    j=j+1;%����
    if ~opt.permutation
        numOfMaxItration=min(opt.Max_FeatureQuantity,length(Index_ttest2));
        waitbar(j/numOfMaxItration,h1,sprintf('%2.0f%%', j/numOfMaxItration*100)) ;
    end
    Index_selectfeature=feature_ranking_list(1:FeatureQuantity);
    train_data= Train_data(:,Index_selectfeature);
    test_data=Test_data(:,Index_selectfeature);
    label_ForPerformance{i,1}=Test_label;
    % ѵ��ģ��&Ԥ��
    model= fitcsvm(train_data,Train_label);
    [predict_label{i,j}, dec_values] = predict(model,test_data);
    Decision{i,j}=dec_values(:,2);
    % estimate mode/SVM
    [accuracy,sensitivity,specificity,ppv,npv]=Calculate_Performances(predict_label{i,j},Test_label);
    Accuracy(i,j) =accuracy;
    Sensitivity(i,j) =sensitivity;
    Specificity(i,j) =specificity;
    PPV(i,j)=ppv;
    NPV(i,j)=npv;
    [AUC(i,j)]=AUC_LC(Test_label,dec_values(:,2));
    %  �ռ��б�ģʽ
    if opt.weight
        W_Brain(j,:,i)=data2originIndex({Index_ttest2,Index_selectfeature},...
            reshape(model.Beta,1,numel(model.Beta)),67541);
    end
    FeatureQuantity=FeatureQuantity+opt.Step_FeatureQuantity; % updata FeatureQuantity
end
if ~opt.permutation
    close (h1);
end
end