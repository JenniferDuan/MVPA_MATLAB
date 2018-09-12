function BarAndErrorBar( data_c,data_p_f,data_p_s)
%UNTITLED2 �˴���ʾ�йش˺�����ժҪ
%   �˴���ʾ��ϸ˵��
%�˺����������ƴ���������״ͼ��
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
%��ô����ľ�����ʽΪ[15; 20; . . . 16, 9;  12; . . . 15]
%���Ƶ����������ı�������
x = 1:size(data_c,2);
Mean=[mean(data_c,1);mean(data_p_f,1);mean(data_p_s,1)]';%��ֵ��
Std=[std(data_c,1);std(data_p_f,1);std(data_p_s,1)]';
h = bar(x,Mean,0.4);
f = @(a)bsxfun(@plus,cat(1,a{:,1}),cat(1,a{:,2})).';%��ȡÿһ����״ͼ���ߵ�x����
x_kedu=f(get(h,{'xoffset','xdata'}));%��ȡÿһ����״ͼ���ߵ�x���ꡣ
hold on
errorbar(f(get(h,{'xoffset','xdata'})),...
    cell2mat(get(h,'ydata')).',Std,'.','linewidth',1)%Std��������
ax = gca;
ax.XTickLabels = {'Accuracy','Sensitivity','Specificity','AUC'};%��Ϊ����Ҫ�ĺ��������ƣ�����age/education�ȵ�
set(ax,'Fontsize',10);%����ax��ߴ�С
ax.XTickLabelRotation = 0;
% Yrang_max=max(max(Mean + Std));
% ax.YLim=[0 Yrang_max+Yrang_max/3];%����y�᷶Χ
% ax.XLim=[0.6 size(Matrix_Patients,2)+0.4];%����x�᷶Χ
% xlabel('variables','FontName','Times New Roman','FontSize',20);
ylabel('','FontName',' ','FontSize',10);
%% ������+���Ǻţ��˲���Ϊ�о���һ�ģ��Ժ�İ汾���Ϊͨ�ð�
% %������1
% line([x_kedu(3,1),x_kedu(3,2)],[Mean(3,2)+(Mean(3,2)-Mean(3,1))/3,...
%     Mean(3,2)+(Mean(3,2)-Mean(3,1))/3],'color','k','LineWidth',2);%��������
% text(x_kedu(3,1)+(x_kedu(3,2)-x_kedu(3,1))/4,Mean(3,2)+(Mean(3,2)-Mean(3,1))/1.5,'*',...
%     'Fontsize',30,'color','k');%��ͳ��ѧ���죬�����Ǻ�,����MATLABλ����bar��������Ӱ���ĸ�Ĵ�С��2����
% %������2
% line([x_kedu(3,2),x_kedu(3,3)],[Mean(3,2)+(Mean(3,2)-Mean(3,1))/3,...
%     Mean(3,2)+(Mean(3,2)-Mean(3,1))/3],'color','k','LineWidth',2);%��������  
% text(x_kedu(3,2)+(x_kedu(3,3)-x_kedu(3,2))/4,Mean(3,2)+(Mean(3,2)-Mean(3,1))/1.5,'*',...
%     'Fontsize',30,'color','r');%��ͳ��ѧ���죬�����Ǻš�
% %������3
% line([x_kedu(4,1),x_kedu(4,2)],[Mean(4,2)+(Mean(4,2)-Mean(4,1))/2,...
%     Mean(4,2)+(Mean(4,2)-Mean(4,1))/2],'color','k','LineWidth',2);%��������  
% text(x_kedu(4,1)+(x_kedu(4,2)-x_kedu(4,1))/4,Mean(4,2)+(Mean(4,2)-Mean(4,1))/1.8,'*',...
%     'Fontsize',30,'color','k');%��ͳ��ѧ���죬�����Ǻš�
% %������4
% line([x_kedu(7,1),x_kedu(7,2)],[Mean(7,2)+(Mean(7,2)-Mean(7,1))/3,...
%     Mean(7,2)+(Mean(7,2)-Mean(7,1))/3],'color','k','LineWidth',2);%��������
% text(x_kedu(7,1)+(x_kedu(7,2)-x_kedu(7,1))/4,Mean(7,2)+(Mean(7,2)-Mean(7,1))/1.5,'*',...
%     'Fontsize',30,'color','k');%��ͳ��ѧ���죬�����Ǻš�
% %������5
% line([x_kedu(8,1),x_kedu(8,2)],[Mean(8,2)+(Mean(8,2)-Mean(8,1))/2.5,...
%     Mean(8,2)+(Mean(8,2)-Mean(8,1))/2.5],'color','k','LineWidth',2);%��������  
% text(x_kedu(8,1)+(x_kedu(8,2)-x_kedu(8,1))/4,Mean(8,2)+(Mean(8,2)-Mean(8,1))/2.3,'*',...
%     'Fontsize',30,'color','k');%��ͳ��ѧ���죬�����Ǻ�,����MATLABλ����bar��������Ӱ���ĸ�Ĵ�С��4.5����
%% set
% h=legend('������','���;�׵�����ߣ�����ǰ��','���;�׵�����ߣ����ƺ�');%������Ҫ�޸�
% set(h,'Fontsize',10);%����legend�����С
% h.Location='northeast';
% h.Orientation='horizon';
% grid on

end

