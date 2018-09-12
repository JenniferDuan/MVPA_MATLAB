function  bar_errorbar_GrangerCausal_beta( Matrix_Patients, Matrix_Controls )
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
% x = 1:size(Matrix_Patients,2);
Mean=[mean(Matrix_Patients,1);mean(Matrix_Controls,1)]';
Std=[std(Matrix_Patients);std(Matrix_Controls)]';
if size(Mean,1)<=1
    Mean=[Mean;Mean];
    Std=[Std;Std];
    h = bar(Mean,0.6,'EdgeColor','k','LineWidth',1.5);
else
    h = bar(Mean,0.6,'EdgeColor','k','LineWidth',1.5);
end
h(1).FaceColor=[0.2,0.2,0.2];h(2).FaceColor='w';
% h(1).Visible='off';h(2).Visible='off';
% set(gca,'YTick',-0.01:0.00001:0.02);
f = @(a)bsxfun(@plus,cat(1,a{:,1}),cat(1,a{:,2})).';%��ȡÿһ����״ͼ���ߵ�x����
coordinate_x=f(get(h,{'xoffset','xdata'}));
hold on
% errorbar(coordinate_x,cell2mat(get(h,'ydata')).',...
%            Std,'s','MarkerSize',0.0001,'linewidth',1.5,'Color','k');%Std��������,����2��Ϊ��ֻ��ʾһ��
%�������
for i=1:numel(Mean)
    if Mean(i)>=0
        line([coordinate_x(i),coordinate_x(i)],[Mean(i),Mean(i)+Std(i)],'linewidth',2);
    else
        line([coordinate_x(i),coordinate_x(i)],[Mean(i),Mean(i)-Std(i)],'linewidth',2);
    end
end
ax = gca;
box off
ax.XTick =  1:size(Matrix_Patients,1);
% ax.XTickLabels = ...
%     {'left Cerebelum_Crus1','right Cerebelum_Crus1',...
%      'left cerebelum_6','left precuneus',...
%      'left postcentral gyrus(extending to bilateral precuneus)',...
%      'right orbitofrontal cortex','left orbitofrontal cortex',...
%      'bilatrel precuneus','left postcentral gyrus(extending to left precuneus)'};
% ax.XTickLabels = ...
%     {'a','b','c','d','e','f','g','h','i'};
ax.XTickLabels = ...
    {'f','g'};
set(ax,'Fontsize',20);%����ax��ߴ�С
% set(ax,'ytick',-0.1:0.05:0.1);
ax.XTickLabelRotation = 45;
% Yrang_max=max(max(Mean + Std));
% ax.YLim=[-0.1 0.1];%����y�᷶Χ
%����x�᷶Χ
% if size(Mean,1)<=2
%     num_real=size(coordinate_x,1)/2;
%     ax.XLim=[0.5 max(max(coordinate_x(1:num_real,:)))];%����x�᷶Χ
% end

% xlabel('variables','FontName','Times New Roman','FontSize',20);
ylabel('Causal influence','FontName','Times New Roman','FontWeight','bold','FontSize',20);
h=legend('patients','controls','Orientation','horizontal');%������Ҫ�޸�
set(h,'Fontsize',15);%����legend�����С
set(h,'Box','off');
% h.Location='best';
box off
% grid on
% grid minor
end

