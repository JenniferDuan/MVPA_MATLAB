function  LC_RadarPlot(X,opt)
% input:
%     X: 1D array
%%
% LC_RadarPlot([.82,0.79,0.84,0.85])
if nargin <2
    opt.linewidth=2;
    opt.linestyle='-';
    opt.color=[1 0.5 0];
    opt.TickLabel={'Acc','Sens','Spec','AUC'};
end
%% =========================����׼��===============================
X=reshape(X,[],1);
% theta=linspace(0,360,numel(X));
X=[X;X(1)];
theta=linspace(0,360,numel(X));
NumOfTickLabel = deg2rad(theta);
%% =========================TickLabel===============================
TickLabel=opt.TickLabel;
%% =========================���״�ͼ===============================
% polarplot(NumOfTickLabel,X,...
%     'linewidth',opt.linewidth,'linestyle',opt.linestyle,'color',opt.color);
polarplot(NumOfTickLabel,X,...
    'linewidth',opt.linewidth,'linestyle',opt.linestyle);
%% ==================����ͼƬ��ʾ��ʽ==============================
ax=gca;
% ����
ax.Color =[0.5,0.5,0.5];%�״�ͼ��������ɫ��
% ���귶Χ
ax.ThetaLim = [0 360];%������ķ�Χ��
% ����
ax.FontSize =15;%�����С
ax.ThetaColor = 'b';%�ı������ַ���ɫ
% ����
ax.ThetaGrid = 'off';%�����ֱ��������ʾ���
ax.RGrid = 'on';%���ε�������ʾ���
ax.LineWidth = 1.5;%�״�ͼ���Ĵ�ϸ��
ax.GridLineStyle = '-';%�������ʾ��ʽ��
ax.GridColor = 'white';%�������ɫ��
% TickLabel
ax.ThetaTickLabel = TickLabel;%�ı�������ַ�
ax.ThetaTick = theta;% ��ʾ�������
ax.ThetaZeroLocation = 'right';% 0������λ��
% R
ax.RAxisLocation = 90;% R���λ��
% ax.RTickLabel = {'one','two','three','four'};%R�������
ax.RTickLabelRotation = 0;% R�������ַ���ת
ax.RColor = 'w' ;% �ı�R�������ַ�����ɫ
% legend({'AUC'},'Location',[0.8 0.7 0.15 0.15],'FontSize',10);
% set(hl,'Orientation','horizon');
% title('��ͬ�������㷨�ķ������ܱȽ�','Color','k','FontSize',15,'FontWeight','bold');
end

