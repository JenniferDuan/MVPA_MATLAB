function scatter_linearfit(x,y,title1)
%ɢ��ͼ����С�������ֱ��
%input���������У���Ҫʱ�����������
if nargin ==2
    title1='scatter figure and fitting linear';
end
sz = 120;%marker��С
%figure;
h=scatter(x,y,sz,'Marker','o',...
        'MarkerEdgeColor',[.3 .3 .3],'MarkerFaceColor','w','LineWidth',3);

% scatter(x,y,sz,'Marker','o',...
%         'MarkerEdgeColor',[0.2 0.8 0.7],'MarkerFaceColor','w','LineWidth',2);
h1=lsline;
set(h1,'LineWidth',2,'LineStyle','-','Color',[.5 .5 .5])
set(gca,'FontSize',30);%�����������С
set(gca,'linewidth',2);%�������ϸ
set(gca,'XColor','black');set(gca,'YColor','black');%���������ɫ
set(gca,'XLim',[-1,1]);%x�᷶Χ
set(gca,'YLim',[0,15]);%y�᷶Χ
% axis square %���������
axis normal %�Զ����������
title(title1,'fontname','Times New Roman','Color','k','FontSize',20);%����
% grid on;
% saveas(gcf,['title1','.tif'])
end
