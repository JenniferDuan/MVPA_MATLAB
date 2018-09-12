function [loc_best,predict_label_best,performances,Accuracy_best,Sensitivity_best,Specificity_best,...
    PPV_best,NPV_best,AUC_best]=...
    IdentifyBestPerformance(predict_label,Accuracy,Sensitivity,Specificity,PPV,NPV,AUC,refrence)
% ����K-fold CV����ѵķ������
% input��
%      �������֣�2D ����. Dimension 1 is equal to K��K-fold����dimension 2 is equal
%      to the number of feature combination derived from RFE or others
%      refrence�����ĸ�����Ϊ�ο���׼
%      predict_label: 2D cell,K*N_featureSubsets
% output��
%      ...
%%
if nargin < 8
    refrence='accuracy';
end
% �����������
Accuracy(isnan(Accuracy))=0;
Sensitivity(isnan(Sensitivity))=0;
Specificity(isnan(Specificity))=0;
PPV(isnan(PPV))=0;
NPV(isnan(NPV))=0;
AUC(isnan(AUC))=0;
%% ����ģ����opt.K fold�е�ƽ������
% �ۺϷ�����֣�ǰһ����Mean ��һ����Std
performances=[[mean(Accuracy);...
    mean(Sensitivity);...
    mean(Specificity);...
    mean(PPV);...
    mean(NPV);...
    mean(AUC)],...
    [std(Accuracy);...
    std(Sensitivity);...
    std(Specificity);...
    std(PPV);...
    std(NPV);...
    std(AUC)]];
%% identify the best performance���Լ�����Ӧ��������������consensus������������ȷ����Ӧ��weight��num_consensus
%��AUCΪ��׼�ҵ���õ�AUC����λ�ã����ҵ���õķ�������Լ����AUC��Ӧ��weight
% N_plot=length(refrence.Initial_FeatureQuantity:refrence.Step_FeatureQuantity:...
%     refrence.Max_FeatureQuantity);
N_plot=size(Accuracy,2);
meanaccuracy=performances(1,(1:1:N_plot));
meansensitivity=performances(2,(1:1:N_plot));
meanspecificity=performances(3,(1:1:N_plot));
meanppv=performances(4,(1:1:N_plot));
meannpv=performances(5,(1:1:N_plot));
meanAUC=performances(6,(1:1:N_plot));
% �ο���������:Accuracy
if strcmp(refrence,'accuracy')
    loc_best=find(meanaccuracy==max(meanaccuracy));
elseif strcmp(refrence,'sensitivity')
    loc_best=find(meansensitivity==max(meansensitivity));
elseif strcmp(refrence,'specificity')
    loc_best=find(meanspecificity==max(meanspecificity));
else
    loc_best=find(meanAUC==max(meanAUC));
end
loc_best=loc_best(1);
% identify best performances
Accuracy_best=meanaccuracy(loc_best);
Sensitivity_best=meansensitivity(loc_best);
Specificity_best=meanspecificity(loc_best);
PPV_best=meanppv(loc_best);
NPV_best=meannpv(loc_best);
AUC_best=meanAUC(loc_best);
predict_label_best=predict_label(:,loc_best);
predict_label_best=cell2mat(predict_label_best);
end