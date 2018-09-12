function  bar_errorbar( Matrix_Patients, Matrix_Controls )
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
x = 1:size(Matrix_Patients,2);
Mean=[mean(Matrix_Patients,1);mean(Matrix_Controls,1)]';
Std=[std(Matrix_Patients);std(Matrix_Controls)]';
h = bar(x,Mean,0.4);
f = @(a)bsxfun(@plus,cat(1,a{:,1}),cat(1,a{:,2})).';%��ȡÿһ����״ͼ���ߵ�x����
hold on
errorbar(f(get(h,{'xoffset','xdata'})),...
    cell2mat(get(h,'ydata')).',Std,'.','linewidth',1)%Std��������
ax = gca;
% ax.XTick =  1:size(Matrix_Patients,1);
ax.XTickLabels = {'age','education'};%��Ϊ����Ҫ�ĺ��������ƣ�����age/education�ȵ�
set(ax,'Fontsize',18);%����ax��ߴ�С
ax.XTickLabelRotation = 45;
Yrang_max=max(max(Mean + Std));
ax.YLim=[0 Yrang_max+Yrang_max/3];%����y�᷶Χ
ax.XLim=[0.6 size(Matrix_Patients,2)+0.4];%����x�᷶Χ
xlabel('variables','FontName','Times New Roman','FontSize',20);
ylabel('mean �� std','FontName','Times New Roman','FontSize',20);
%%
% %����
% loc=f(get(h,{'xoffset','xdata'}));%ÿ�����ӵ��е�x����
% plot([loc(1,1),loc(1,2)],....
%     [max([Mean(1,1)+Std(1,1),Mean(1,2)+Std(1,2)]),max([Mean(1,1)+Std(1,1),Mean(1,2)+Std(1,2)])]);
% plot([loc(2,1),loc(2,2)],....
%     [max([Mean(2,1)+Std(2,1),Mean(2,2)+Std(2,2)]),max([Mean(2,1)+Std(2,1),Mean(2,2)+Std(2,2)])]);
%%
[~,p]=ttest2(Matrix_Patients, Matrix_Controls);%˫����t���顣
txt1 = text(0.90, max([Mean(1,1)+Std(1,1),Mean(1,2)+Std(1,2)])+Std(1,1)/4, strcat('p=',num2str(p(1))), 'rotation', 0);  %����״ͼ������ʾpֵ
txt2 = text(1.90, max([Mean(2,1)+Std(2,1),Mean(2,2)+Std(2,2)])+Std(2,2)/4, strcat('p=',num2str(p(2))), 'rotation', 0);  
% txt3 = text(2.90, max([Mean(3,1)+Std(3,1),Mean(3,2)+Std(3,2)])+Std(3,2)/4, strcat('p=',num2str(p(3))), 'rotation', 0);  
% txt4 = text(3.90, max([Mean(4,1)+Std(4,1),Mean(4,2)+Std(4,2)])+Std(4,2)/4, strcat('p=',num2str(p(4))), 'rotation', 0);  
% txt5 = text(4.90, max([Mean(2,1)+Std(2,1),Mean(2,2)+Std(2,2)])+Std(2,2)/4, 'P=b', 'rotation', 0);   
set(txt1, 'fontsize', 15);  
set(txt2, 'fontsize', 15);  
% set(txt3, 'fontsize', 15);  
% set(txt4, 'fontsize', 15); 
% set(txt5, 'fontsize', 15); 
h=legend('patients','controls');%������Ҫ�޸�
set(h,'Fontsize',20);%����legend�����С
grid on
end

