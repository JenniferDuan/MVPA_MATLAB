function  bar_chenyan_script
%UNTITLED �˴���ʾ�йش˺�����ժҪ
%   �˴���ʾ��ϸ˵��
x=1:8;%changed item������������
Mean=[mean(data_c,1);mean(data_p_f,1);mean(data_p_s,1)]';%��ֵ��
h = bar(x,Mean,0.6);%��bar
f = @(a)bsxfun(@plus,cat(1,a{:,1}),cat(1,a{:,2})).';
x_kedu=f(get(h,{'xoffset','xdata'}));%��ȡÿһ����״ͼ���ߵ�x���ꡣ
%%
%������+���Ǻţ��˲���Ϊ�о���һ�ģ��Ժ�İ汾���Ϊͨ�ð�
%������1
line([x_kedu(3,1),x_kedu(3,1)],[Mean(3,1),...
    Mean(3,2)+(Mean(3,2)-Mean(3,1))/5]);%�������ߡ�
line([x_kedu(3,2),x_kedu(3,2)],[Mean(3,2),...
    Mean(3,2)+(Mean(3,2)-Mean(3,1))/5]);%�������ߡ�
line([x_kedu(3,1),x_kedu(3,2)],[Mean(3,2)+(Mean(3,2)-Mean(3,1))/5,...
    Mean(3,2)+(Mean(3,2)-Mean(3,1))/5]);%��������
text(x_kedu(3,1)+(x_kedu(3,2)-x_kedu(3,1))/4,Mean(3,2)+(Mean(3,2)-Mean(3,1))/2.5,'*',...
    'Fontsize',30,'color','k');%��ͳ��ѧ���죬�����Ǻ�,����MATLABλ����bar��������Ӱ���ĸ�Ĵ�С��2.5����
%������2
  line([x_kedu(3,2),x_kedu(3,2)],[Mean(3,2),...
    Mean(3,2)+(Mean(3,2)-Mean(3,1))/3]);%�������ߡ�
line([x_kedu(3,3),x_kedu(3,3)],[Mean(3,3),...
    Mean(3,2)+(Mean(3,2)-Mean(3,1))/3]);%�������ߡ�
line([x_kedu(3,2),x_kedu(3,3)],[Mean(3,2)+(Mean(3,2)-Mean(3,1))/3,...
    Mean(3,2)+(Mean(3,2)-Mean(3,1))/3]);%��������  
text(x_kedu(3,2)+(x_kedu(3,3)-x_kedu(3,2))/4,Mean(3,2)+(Mean(3,2)-Mean(3,1))/1.8,'*',...
    'Fontsize',30,'color','r');%��ͳ��ѧ���죬�����Ǻš�
%������3
  line([x_kedu(4,1),x_kedu(4,1)],[Mean(4,1),...
    Mean(4,2)+(Mean(4,2)-Mean(4,1))/5]);%�������ߡ�
line([x_kedu(4,2),x_kedu(4,2)],[Mean(4,2),...
    Mean(4,2)+(Mean(4,2)-Mean(4,1))/5]);%�������ߡ�
line([x_kedu(4,1),x_kedu(4,2)],[Mean(4,2)+(Mean(4,2)-Mean(4,1))/5,...
    Mean(4,2)+(Mean(4,2)-Mean(4,1))/5]);%��������  
text(x_kedu(4,1)+(x_kedu(4,2)-x_kedu(4,1))/4,Mean(4,2)+(Mean(4,2)-Mean(4,1))/4.5,'*',...
    'Fontsize',30,'color','k');%��ͳ��ѧ���죬�����Ǻš�
% %������4
%   line([x_kedu(6,1),x_kedu(6,1)],[Mean(6,1),...
%     Mean(6,2)+(Mean(6,2)-Mean(6,1))/5]);%�������ߡ�
% line([x_kedu(6,2),x_kedu(6,2)],[Mean(6,2),...
%     Mean(6,2)+(Mean(6,2)-Mean(6,1))/5]);%�������ߡ�
% line([x_kedu(6,1),x_kedu(6,2)],[Mean(6,2)+(Mean(6,2)-Mean(6,1))/5,...
%     Mean(6,2)+(Mean(6,2)-Mean(6,1))/5]);%��������  
% text(x_kedu(6,1)+(x_kedu(6,2)-x_kedu(6,1))/4,Mean(6,2)+(Mean(6,2)-Mean(6,1))/4,'*',...
%     'Fontsize',30,'color','k');%��ͳ��ѧ���죬�����Ǻš�
%������5
  line([x_kedu(7,1),x_kedu(7,1)],[Mean(7,1),...
    Mean(7,2)+(Mean(7,2)-Mean(7,1))/5]);%�������ߡ�
line([x_kedu(7,2),x_kedu(7,2)],[Mean(7,2),...
    Mean(7,2)+(Mean(7,2)-Mean(7,1))/5]);%�������ߡ�
line([x_kedu(7,1),x_kedu(7,2)],[Mean(7,2)+(Mean(7,2)-Mean(7,1))/5,...
    Mean(7,2)+(Mean(7,2)-Mean(7,1))/5]);%��������
text(x_kedu(7,1)+(x_kedu(7,2)-x_kedu(7,1))/4,Mean(7,2)+(Mean(7,2)-Mean(7,1))/2.5,'*',...
    'Fontsize',30,'color','k');%��ͳ��ѧ���죬�����Ǻš�
%������6
  line([x_kedu(8,1),x_kedu(8,1)],[Mean(8,1),...
    Mean(8,2)+(Mean(8,2)-Mean(8,1))/5]);%�������ߡ�
line([x_kedu(8,2),x_kedu(8,2)],[Mean(8,2),...
    Mean(8,2)+(Mean(8,2)-Mean(8,1))/5]);%�������ߡ�
line([x_kedu(8,1),x_kedu(8,2)],[Mean(8,2)+(Mean(8,2)-Mean(8,1))/5,...
    Mean(8,2)+(Mean(8,2)-Mean(8,1))/5]);%��������  
text(x_kedu(8,1)+(x_kedu(8,2)-x_kedu(8,1))/4,Mean(8,2)+(Mean(8,2)-Mean(8,1))/4.5,'*',...
    'Fontsize',30,'color','k');%��ͳ��ѧ���죬�����Ǻ�,����MATLABλ����bar��������Ӱ���ĸ�Ĵ�С��4.5����
%%
%�����Լ��������ֵ�
ax = gca;
ax.XTickLabels = {'��ǰ�۴���','���Ե�','��������','������',...
    '��ǰ�۴���','���Ե�','��������','������'};
set(ax,'XColor','k');%x�������ɫ
set(ax,'Fontsize',25);%����ax��ߴ�С
ax.XTickLabelRotation = 45;
% ax.YLim=[-0.8 2];%����y�᷶Χ
title('���;�׵�������������ʹ������������Է��񾭻��ALFF��',...
                     'Fontsize',25,'FontWeight','bold');
xlabel('����','Fontsize',25,'FontWeight','bold','color','k');
ylabel('����','Fontsize',25,'FontWeight','bold');
h=legend('������','���;�׵������(����ǰ)','���;�׵������(���ƺ�)');%������Ҫ�޸�
h.Location='northwest';
% gtext('*','Fontsize',30);%�ڶ���ͳ��ѧ�������״ͼ���滭���Ǻš�
% gtext('*','Fontsize',30);%������ǰ�Ա�����ͳ��ѧ�������״ͼ���滭���Ǻš�
% gtext('*','Fontsize',30);%������ǰ�Ա�����ͳ��ѧ�������״ͼ���滭���Ǻš�
% gtext('*','Fontsize',30);%������ǰ�Ա�����ͳ��ѧ�������״ͼ���滭���Ǻš�
% gtext('*','Fontsize',30);%������ǰ�Ա�����ͳ��ѧ�������״ͼ���滭���Ǻš�
% gtext('*','Fontsize',30);%������ǰ�Ա�����ͳ��ѧ�������״ͼ���滭���Ǻš�
%%
%����ͼ�����Ǳ���ͼ�����ˣ���Ϊ���ڰٷ�֮�٣�������
mc=mean(data_c(:,3));
mpf=mean(data_p_f(:,3));
mps=mean(data_p_s(:,3));
perc1=(mpf-mc)/mc;%����ǰ�������������񾭻�ľ���ֵ�϶��������ӵİٷֱ�
perc2=(mps-mc)/mc;%���ƺ󣬲����������񾭻�ľ���ֵ�϶��������ӵİٷֱ�
ax1 = subplot(1,2,1);
i=perc1*100;i=round(i);%����2λС��
label1 = {'',['����ǰ(',num2str(i),'%)']};
p1=pie(ax1,[1-perc1,perc1],label1);
t = p1(2);
t.FontSize = 30;%����label��С
% colormap([0,0,1]);%��ɫ
ax2 = subplot(1,2,2);
i=perc2*100;i=round(i);%����2λС��
label2 = {'',['���ƺ�(',num2str(i),'%)']};
p2=pie(ax2,[1-perc2,perc2],label2);
t = p2(2);
t.FontSize = 30;%����label��С
% colormap([0,0,1])%��ɫ
fig=suptitle('����ǰ���������쳣�Է��Ի�ı�ֵ�仯');
set(fig,'Fontsize',40,'FontWeight','bold');
end

