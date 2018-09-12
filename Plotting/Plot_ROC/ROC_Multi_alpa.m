function  ROC_Multi_alpa( Label_All,Decision_All )
%�˴������������ROC����
%���룺Label_All=���е�����label�����粡��Ϊ1������������Ϊ0��Decision_All=���е������÷֡�
%����Label_All,Decision_All�ľ����ʽ��M��N�У�����MΪ����������NΪ��������
%for example��Label_All=[1 0 0 1;1 1 0 0],��ʾLabel_All��2��4�У���2��������4��������
%�����Ϊ���ROC����
%���������֧��10��������������Ҫ�������޸ġ�
%%
Num_ROC=size(Label_All,1);
LineStyle={'-','--o','-','--o','-','--o','-','-','--o','-'};
ColorMap={'r','r','g','g','b','b','c','c','m','m'};
Name_legend={'legend1','legend2','legend3','legend4','legend5','legend6','legend7','legend8','legend9','legend10'};
for j=1:Num_ROC
    label=Label_All(j,:);
    Decision=-Decision_All(j,:);
    label(label~=1)=0;%��label�в�Ϊ1��������Ϊ0����������ڶ���࣬�˴�����Ҫ�޸ġ�
    label=reshape(label,length(label),1);Decision=reshape(Decision,length(Decision),1);%reshape
    %%
    %���㲻ͬdecisionʱ�����жȺ�����ȡ�
    sensitivity=zeros(length(label),1);specificity=zeros(length(label),1);%Ԥ���ռ䡣
    for i=1:length(label)
       Decision_tem=Decision;
       Decision_tem(Decision_tem>=Decision(i))=1;Decision_tem(Decision_tem<Decision(i))=0;%��Decion_tempת��Ϊ0��1��
       sensitivity(i)=sum(label.*Decision_tem)/sum(label);
       specificity(i)=sum((label==0).*(Decision_tem==0))/sum(label==0);
    end
    Order=[1-specificity,sensitivity];
    Order=sort(Order);
    plot(Order(:,1),Order(:,2),char(LineStyle(j)),'color',ColorMap{j},...
    'LineWidth',2)
%     'MarkerSize',8,...
%     'MarkerEdgeColor','r',...
%     'MarkerFaceColor',[0.5,0.5,0.5]);%gΪ��ɫ��-Ϊ���͡�
hold on;
end
set(gca,'Fontsize',30);%���������ߴ�С
axis([-0.1 1 0 1]);%������������ָ��������.
fig=legend(Name_legend,'Location','NorthEastOutside');
set(fig,'Fontsize',30);%����legend�����С
end

