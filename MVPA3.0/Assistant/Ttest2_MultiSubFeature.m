function  [Accuracy, Sensitivity, Specificity, PPV, NPV, AUC]=...
    Ttest2_MultiSubFeature(train_data,train_label, test_data, test_label, p_start, p_step, p_end,opt)
%% =======================����˵��=========================
% ��;�� ��Ttest2�󣬲�ͬpֵ�����ɸ�sub-feature ���л���ѧϰ��ģ��Ԥ��
% input:
    % train_data/train_label=ѵ��������ѵ��������ǩ,����Ϊ�������һ��
    % p_start:p_step:p_end=��ʼpֵ��ÿ�����ӵ�pֵ������pֵ
    % opt:�������ο���Ӧ���룺FeatureSelection_RFE_SVM
%output�� ���ɸ��������ܣ���size��ǰ������sub-feature��Ӧ
%% ============================����==============================
data_p = train_data(train_label==1,:);
data_hc = train_data(train_label==-1,:);
%% ============================Ttest2����ɸѡ=====================
[~,pvalue]=ttest2( data_p, data_hc);
%% =======================���sub-feature�Ľ�ģ��Ԥ��==============
count=0;
for p_thrd=p_start:p_step:p_end
    count= count+1;
    f_ind=pvalue<=p_thrd;
    model = fitclinear(train_data(:,f_ind),train_label,'Learner',opt.learner);
    [predicted_lable{count,1},decision] = predict( model,test_data(:,f_ind));
    Decision{count,1} = decision(:,1);
    %% =======================��������====================
    if iscell(predicted_lable(count,1));predict_temp=cell2mat(predicted_lable(count,1));end
    [Accuracy(count),Sensitivity(count),Specificity(count),PPV(count),NPV(count)]=Calculate_Performances(predict_temp,test_label);
    [AUC(count)]=AUC_LC(test_label,Decision{count,1});
end
end
