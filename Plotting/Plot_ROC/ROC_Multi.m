LineStyle={'-','--*','-','--*','-','--*','-'};
ColorMap={'r','r','g','g','b','b',[0.2 0.2 0.2]};
for j=1:7
    label=alllabel(j,:);
    Decision=-allde(j,:);
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
    'LineWidth',4)
%     'MarkerSize',8,...
%     'MarkerEdgeColor','r',...
%     'MarkerFaceColor',[0.5,0.5,0.5]);%gΪ��ɫ��-Ϊ���͡�
hold on;
end
set(gca,'Fontsize',30);%���������ߴ�С
axis([-0.1 1 0 1]);%������������ָ��������.
fig=legend('ventral-RAIns-x2y','ventral-RAIns-y2x','dorsal-RAIns-x2y',...
                     'dorsal-RAIns-y2x','ventral-LAIns-x2y','ventral-LAIns-y2x','ALFF','Location','Southeast');
set(fig,'Fontsize',30);%����legend�����С
fig.Location='NorthEastOutside';

