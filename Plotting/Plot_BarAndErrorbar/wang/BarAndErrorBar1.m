Mean=Mean';
Std=Std';
h = bar(1:2,Mean,0.7);
f = @(a)bsxfun(@plus,cat(1,a{:,1}),cat(1,a{:,2})).';%��ȡÿһ����״ͼ���ߵ�x����
x_kedu=f(get(h,{'xoffset','xdata'}));%��ȡÿһ����״ͼ���ߵ�x���ꡣ
hold on
errorbar(f(get(h,{'xoffset','xdata'})),...
    cell2mat(get(h,'ydata')).',Std,'.','linewidth',1)%Std��������
ax = gca;
ax.XTickLabels = {'Occipital-Mid-L',...
    'Postcentral-L'};%��Ϊ����Ҫ�ĺ��������ƣ�����age/education�ȵ�
set(ax,'Fontsize',10);%����ax��ߴ�С
ax.XTickLabelRotation = 0;
% Yrang_max=max(max(Mean + Std));
% ax.YLim=[0 Yrang_max+Yrang_max/3];%����y�᷶Χ
% ax.XLim=[0.6 size(Matrix_Patients,2)+0.4];%����x�᷶Χ
% xlabel('variables','FontName','Times New Roman','FontSize',20);
ylabel('','FontName',' ','FontSize',10);
h=legend('HC','MDD','BD','SZ','Location','NorthOutside');
set(h,'Orientation','horizon')
title('Nodal Degree');
% axis off
box off


