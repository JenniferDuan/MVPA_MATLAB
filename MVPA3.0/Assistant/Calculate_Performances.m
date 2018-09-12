function [accuracy,sensitivity,specificity,PPV,NPV]=Calculate_Performances(Predict_label,Real_label)
%����ģ�͵�Ԥ�����
%����;Ԥ���ǩ����ʵ��ǩ
%���������������;PPV������Ԥ���ʣ�NPV������Ԥ����
%% ��������
% ����׼��
% ����1��Ϊ0.
Predict_label=Predict_label==1;
Real_label=Real_label==1;
% ���������.
Predict_label=reshape(Predict_label,length(Predict_label),1);
Real_label=reshape(Real_label,length(Real_label),1);
% ����
TP=sum(Real_label.*Predict_label);
FN=sum(Real_label)-sum(Real_label.*Predict_label);
TN=sum((Real_label==0).*(Predict_label==0));
FP=sum(Real_label==0)-sum((Real_label==0).*(Predict_label==0));
    accuracy =(TP+TN)/(TP + FN + TN + FP); %����
    sensitivity =TP/(TP + FN);
    specificity =TN/(TN + FP); 
    PPV=TP/(TP+FP);%positive predictive
    NPV=TN/(TN+FN);%negative predictive value
end

