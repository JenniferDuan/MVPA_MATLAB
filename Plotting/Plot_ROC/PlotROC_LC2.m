function [OptimalPred,AUC_All]=PlotROC_LC2(RealLabel,Pred,opt)
%��;�� ��ROC����
% input:
%    RealLabel=��ʵ��Ӧ����ֵ��
%    Pred=Ԥ���Ӧ����ֵ����ֱ�����Ա�����ֵ;
% output��
 %    OptimalPred=��ѵ�Preds;
 %    AUC_All: Ԥ�������decision������label�õ���AUC
% new:���ж�����Լ��ָ��ʱ���������������Ⱥ����жȵ���С���Բ�ֵ����������2018-04-02 By Lichao
%% �ٻ�ɫ[1 0.5 0]  ����ɫ[0 0.5 0]
if nargin<3
    opt.roc_type='-';
    opt.dot_type='o';
    opt.color=[1 0.5 0];
    opt.LineWidth=3;
    opt.MarkerSize=12;
    opt.MarkerEdgeColor=[1 0.5 0];
    opt.MarkerFaceColor='w';
    opt.plotOptimum=1;
end
%% ��label�в�Ϊ1��������Ϊ0����������ڶ���࣬�˴�����Ҫ�޸ġ�AND reshape
RealLabel=RealLabel==1;
RealLabel=reshape(RealLabel,length(RealLabel),1);
Pred=reshape(Pred,length(Pred),1);
%% ��������decisionʱ��AUC��С��ѡ����AUCʱ��decision
AUC_pos=AUC_LC(RealLabel,Pred);
AUC_neg=AUC_LC(RealLabel,-Pred);
if AUC_pos< AUC_neg
    Pred=-Pred;
    AUC_All=AUC_neg;
else 
    AUC_All=AUC_pos;
end
%%
%%
%���㲻ͬdecisionʱ�����жȺ�����ȡ�
sensitivity=zeros(length(RealLabel),1);specificity=zeros(length(RealLabel),1);%Ԥ���ռ䡣
for i=1:length(RealLabel)
    Decision_tem=Pred;
    Decision_tem=Decision_tem>=Pred(i);%��Decion_tempת��Ϊ0��1��
    sensitivity(i)=sum(RealLabel.*Decision_tem)/sum(RealLabel);
    specificity(i)=sum((RealLabel==0).*(Decision_tem==0))/sum(RealLabel==0);
end
Order_original=[1-specificity,sensitivity];
Order_sorted=sort(Order_original);
% ����Լ��ָ��ѡ��
YuedengIndex=specificity+sensitivity-1;
locOfOptimalPred=find(YuedengIndex==max(YuedengIndex));
% �����ڶ�����Լ��ָ��ʱ���Լ�ѡ��ڼ���
if numel(locOfOptimalPred)>1
fprintf(['���ڶ���������ֵ,���£�',char(10),'ÿһ�ж�������Ⱥ����ж���ɣ�'...
    ,char(10),'��ѡ��ڼ������\n']);
[specificity(locOfOptimalPred),sensitivity(locOfOptimalPred)]
rowOfFeComb=input('������ѡ�������������ڵ��У�','s');
rowOfFeComb=str2num( rowOfFeComb);
locOfOptimalPred=locOfOptimalPred(rowOfFeComb);
% ��ѵ���ϵ�
OptimalPred=Pred(locOfOptimalPred);
end
%plot optimum dot
if opt.plotOptimum
plot(Order_original(locOfOptimalPred,1),Order_original(locOfOptimalPred,2),opt.dot_type,...
    'LineWidth',opt.LineWidth,...
    'MarkerSize',opt.MarkerSize+1,...
    'MarkerEdgeColor',opt.MarkerEdgeColor,...
    'MarkerFaceColor',opt.MarkerFaceColor);%gΪ��ɫ��-Ϊ���͡�);
text(Order_original(locOfOptimalPred,1)+0.02,Order_original(locOfOptimalPred,2)-0.1,...
    ['specificity = ',num2str(1-Order_original(locOfOptimalPred,1),'%.2f'),char(10),...
    'sensitivity = ',num2str(Order_original(locOfOptimalPred,2),'%.2f')],...
    'FontSize',12)
% text(Order_original(locOfOptimalPred,1)+0.02,Order_original(locOfOptimalPred,2)-0.1,...
%     ['specificity = ',num2str(1-Order_original(locOfOptimalPred,1),'%.2f'),char(10),...
%     'sensitivity = ',num2str(Order_original(locOfOptimalPred,2),'%.2f'),char(10),...
%      'AUC = ',num2str(AUC,'%.2f')],...
%     'FontSize',12)
hold on;
end
% plot ROC curve
plot(Order_sorted(:,1),Order_sorted(:,2),opt.roc_type,'color',opt.color,...
    'LineWidth',opt.LineWidth,...
    'MarkerSize',opt.MarkerSize,...
    'MarkerEdgeColor',opt.MarkerEdgeColor,...
    'MarkerFaceColor',opt.MarkerFaceColor);%gΪ��ɫ��-Ϊ���͡�);
xlabel('1-specificity');
ylabel('sensitivity');
set(gca,'Fontsize',14);%���������ߴ�С
box off
axis([-0.1 1 0 1]);%������������ָ��������.
% xlabel('1-specificity','FontName','Times New Roman','FontWeight','bold''FontSize',25);
% ylabel('sensitivity','FontName','Times New Roman','FontWeight','bold','FontSize',25);
hold off;
end

