function bar_graduation
AUC=[0.9700    0.9200    0.6500    0.6400    0.6200    0.6100    0.5500];
Specificity=[0.90   0.92   0.53  0.43   0.60   0.53   0.45];
Sensitivity=[ 0.9000    0.8400    0.7200    0.7400    0.6200    0.5600    0.6000];
Accuracy=[0.9000    0.8780    0.6300    0.6000    0.6110    0.5440    0.5330];
%%
x=1:4;%changed item������������
Mean=[AUC;Specificity;Sensitivity;Accuracy];
h = bar(x,Mean,0.6);%��bar
f = @(a)bsxfun(@plus,cat(1,a{:,1}),cat(1,a{:,2})).';
x_kedu=f(get(h,{'xoffset','xdata'}));%��ȡÿһ����״ͼ���ߵ�x���ꡣ
%%
%�����Լ��������ֵ�
ax = gca;
ax.XTickLabels = {'AUC','Specificity','Sensitivity','Accuracy'};
set(ax,'XColor','k');%x�������ɫ
set(ax,'Fontsize',15);%����ax��ߴ�С
ax.XTickLabelRotation = 0;
% ax.YLim=[-0.8 2];%����y�᷶Χ
% title('The classifier performance using different seed region or ALFF algorithm',...
%                      'Fontsize',20,'FontWeight','bold');
xlabel('','Fontsize',15,'FontWeight','bold','color','k');
ylabel('Performances','Fontsize',15,'FontWeight','bold');
h1=legend('ventral-RAIns-x2y','ventral-RAIns-y2x','dorsal-RAIns-x2y',...
         'dorsal-RAIns-y2x','ventral-LAIns-x2y','ventral-LAIns-y2x','ALFF');%������Ҫ�޸�
h1.Location='northeast';
line([0,5],[0.5,0.5],'linewidth',3,'color',[0.5,0.5,0.5]);
line([0,5],[0.8,0.8],'linewidth',3,'color',[0.8,0.2,0.2]);
% line([0,5],[0.9,0.9],'linewidth',3,'color',[0.8,0.2,0.2]);
%%
% %����ͼ�����Ǳ���ͼ�����ˣ���Ϊ���ڰٷ�֮�٣�������
% mc=mean(data_c(:,3));
% mpf=mean(data_p_f(:,3));
% mps=mean(data_p_s(:,3));
% perc1=(mpf-mc)/mc;%����ǰ�������������񾭻�ľ���ֵ�϶��������ӵİٷֱ�
% perc2=(mps-mc)/mc;%���ƺ󣬲����������񾭻�ľ���ֵ�϶��������ӵİٷֱ�
% ax1 = subplot(1,2,1);
% i=perc1*100;i=round(i);%����2λС��
% label1 = {'',['����ǰ(',num2str(i),'%)']};
% p1=pie(ax1,[1-perc1,perc1],label1);
% t = p1(2);
% t.FontSize = 30;%����label��С
% % colormap([0,0,1]);%��ɫ
% ax2 = subplot(1,2,2);
% i=perc2*100;i=round(i);%����2λС��
% label2 = {'',['���ƺ�(',num2str(i),'%)']};
% p2=pie(ax2,[1-perc2,perc2],label2);
% t = p2(2);
% t.FontSize = 30;%����label��С
% % colormap([0,0,1])%��ɫ
% fig=suptitle('����ǰ���������쳣�Է��Ի�ı�ֵ�仯');
% set(fig,'Fontsize',40,'FontWeight','bold');

end

