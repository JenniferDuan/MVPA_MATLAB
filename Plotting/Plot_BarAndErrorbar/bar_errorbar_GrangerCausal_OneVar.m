function  bar_errorbar_GrangerCausal_OneVar( Matrix)
%�˺����������ƴ���������״ͼ��ͬʱ���˫����t�����pֵ,Ŀǰ�Ĵ�ֻ���������鱻�ԡ�
%input:
% Matrix_PatientsΪ���˵ı������󣬱����в����鱻����=N������2��������age��education��
% ��ô�ñ�������Ӧ����һ��N��2�еľ���������һ������ı����ʽ��
%            age     education
% subject1    15         9
% subject2    20         12
% .           .           . 
% .           .           .
% .           .           .
% subjectN    16         15
%��ô����ľ�����ʽΪ[15 20 . . . 16;9  12 . . . 15]
%���Ƶ����������ı�������
x = 1:size(Matrix,2);
Mean=mean(Matrix,1)';
Std=std(Matrix)';
h = bar(x,Mean,0.6,'EdgeColor','k','LineWidth',1);
h.FaceColor=[.5 .5 .5];h.EdgeColor='k';
% h.Visible='off';
set(gca,'YTick',0:0.2:1);
f = @(a)bsxfun(@plus,cat(1,a{:,1}),cat(1,a{:,2})).';%��ȡÿһ����״ͼ���ߵ�x����
hold on
errorbar(f(get(h,{'xoffset','xdata'})),get(h,'ydata').',...
           Std,'s','MarkerSize',0.0001,'linewidth',1,'Color','k');%Std��������
% errorbar(f(get(h,{'xoffset','xdata'})),...
%     cell2mat(get(h,'ydata')).',Std,pos)%Std��������
ax = gca;
box off
ax.XTickLabels ={'Accuracy','Sensitivity', 'Specificity', 'PPV', 'NPV','AUC'};
set(ax,'Fontsize',15);%����ax��ߴ�С
% set(ax,'ytick',-0.1:0.05:0.1);
ax.XTickLabelRotation = 30;
% Yrang_max=max(max(Mean + Std));
% ax.YLim=[-0.1 0.1];%����y�᷶Χ
% ax.XLim=[0.6 size(Matrix_Patients,2)+0.4];%����x�᷶Χ
% xlabel('variables','FontName','Times New Roman','FontSize',20);
% ylabel('Performance','FontName','Times New Roman','FontWeight','normal','FontSize',40);
%%
% h=legend('Mean','Standard deviation');%������Ҫ�޸�
% set(h,'Fontsize',15);%����legend�����С
% set(h,'Box','on');
% h.Location='best';
grid on
% grid minor
end

