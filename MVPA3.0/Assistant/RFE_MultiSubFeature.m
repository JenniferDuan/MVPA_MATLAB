function  [Accuracy, Sensitivity, Specificity, PPV, NPV, AUC]=...
    RFE_MultiSubFeature(train_data,train_label, test_data, test_label,opt)
%% =======================����˵��=========================
% ��;�� ��RFE��������ǰ�����ɸ�sub-feature ���л���ѧϰ��ģ��Ԥ��
% input:
% train_data/train_label=ѵ��������ѵ��������ǩ,����Ϊ�������һ��
% N_start:N_step:N_end=��ʼ������Ŀ��ÿ�����ӵ�������Ŀ������������Ŀ
% opt:�������ο���Ӧ���룺FeatureSelection_RFE_SVM
%output�� ���ɸ��������ܣ���size��ǰ������sub-feature��Ӧ
%% =======================RFE����ɸѡ=====================
[ f_ind ] = FeatureSelection_RFE_SVM( train_data,train_label,opt);
%% =======================���sub-feature�Ľ�ģ��Ԥ��==============
count=0;
for N_X=opt.Initial_FeatureQuantity:opt.Step_FeatureQuantity:opt.Max_FeatureQuantity
    count= count+1;
    model = fitclinear(train_data(:,f_ind(1:N_X)),train_label,'Learner',opt.learner);
    [predicted_lable{count,1},decision] = predict( model,test_data(:,f_ind(1:N_X)));
    Decision{count,1} = decision(:,1);
    %% =======================��������====================
    if iscell(predicted_lable(count,1));predict_temp=cell2mat(predicted_lable(count,1));end
    [Accuracy(count),Sensitivity(count),Specificity(count),PPV(count),NPV(count)]=Calculate_Performances(predict_temp,test_label);
    [AUC(count)]=AUC_LC(test_label,Decision{count,1});
end
end
