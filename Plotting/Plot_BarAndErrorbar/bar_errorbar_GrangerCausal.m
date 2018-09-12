function  bar_errorbar_GrangerCausal( Matrix_Patients, Matrix_Controls )
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
% figure('color','k');
x = 1:size(Matrix_Patients,2);
Mean=[mean(Matrix_Patients,1);mean(Matrix_Controls,1)]';
Std=[std(Matrix_Patients);std(Matrix_Controls)]';
h = bar(x,Mean,0.5,'EdgeColor','k','LineWidth',1);
h(1).FaceColor=[.3 .3 .3];h(2).FaceColor=[.7 .7 .7];
% h(1).Visible='off';h(2).Visible='off';
% set(gca,'YTick',-0.01:0.00001:0.02);
f = @(a)bsxfun(@plus,cat(1,a{:,1}),cat(1,a{:,2})).';%��ȡÿһ����״ͼ���ߵ�x����
hold on
e=errorbar(f(get(h,{'xoffset','xdata'})),...
    cell2mat(get(h,'ydata')).',Std,'.','MarkerSize',0.001,'linewidth',1,'Color','k');%Std��������
ax = gca;
box off
ax.XTick =  1:size(Matrix_Patients,1);
% ax.XTickLabels = ...
%     {'left Cerebelum_Crus1','right Cerebelum_Crus1',...
%      'left cerebelum_6','left precuneus',...
%      'left postcentral gyrus(extending to bilateral precuneus)',...
%      'right orbitofrontal cortex','left orbitofrontal cortex',...
%      'bilatrel precuneus','left postcentral gyrus(extending to left precuneus)'};
ax.XTickLabels = {[]};
set(ax,'Fontsize',15);%����ax��ߴ�С
% set(ax,'ytick',-0.1:0.05:0.1);
ax.XTickLabelRotation = 0;
% Yrang_max=max(max(Mean + Std));
% ax.YLim=[-0.1 0.1];%����y�᷶Χ
% ax.XLim=[0.6 size(Matrix_Patients,2)+0.4];%����x�᷶Χ
% xlabel('variables','FontName','Times New Roman','FontSize',20);
ylabel('Causal influence','FontName','Times New Roman','FontWeight','bold','FontSize',15);
%%
h=legend('patients','controls');%������Ҫ�޸�
set(h,'Fontsize',10);%����legend�����С
h.Location='best';
set(h,'Orientation','horizon');
% grid on
% grid minor
%% save mean performances as .tif figure
% print(gcf,'-dtiff','-r300','figure')
end

