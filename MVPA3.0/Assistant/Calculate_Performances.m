function [accuracy,sensitivity,specificity,PPV,NPV]=Calculate_Performances(Predict_label,Real_label)
%计算模型的预测表现
%输入;预测标签和真实标签
%输出：各分类性能;PPV：阳性预测率；NPV：阴性预测率
%% 计算性能
% 数据准备
% 将非1设为0.
Predict_label=Predict_label==1;
Real_label=Real_label==1;
% 变成行向量.
Predict_label=reshape(Predict_label,length(Predict_label),1);
Real_label=reshape(Real_label,length(Real_label),1);
% 计算
TP=sum(Real_label.*Predict_label);
FN=sum(Real_label)-sum(Real_label.*Predict_label);
TN=sum((Real_label==0).*(Predict_label==0));
FP=sum(Real_label==0)-sum((Real_label==0).*(Predict_label==0));
    accuracy =(TP+TN)/(TP + FN + TN + FP); %定义
    sensitivity =TP/(TP + FN);
    specificity =TN/(TN + FP); 
    PPV=TP/(TP+FP);%positive predictive
    NPV=TN/(TN+FN);%negative predictive value
end

