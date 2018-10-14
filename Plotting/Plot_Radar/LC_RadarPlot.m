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
%% =========================数据准备===============================
X=reshape(X,[],1);
% theta=linspace(0,360,numel(X));
X=[X;X(1)];
theta=linspace(0,360,numel(X));
NumOfTickLabel = deg2rad(theta);
%% =========================TickLabel===============================
TickLabel=opt.TickLabel;
%% =========================画雷达图===============================
% polarplot(NumOfTickLabel,X,...
%     'linewidth',opt.linewidth,'linestyle',opt.linestyle,'color',opt.color);
polarplot(NumOfTickLabel,X,...
    'linewidth',opt.linewidth,'linestyle',opt.linestyle);
%% ==================设置图片显示格式==============================
ax=gca;
% 背景
ax.Color =[0.5,0.5,0.5];%雷达图背景的颜色。
% 坐标范围
ax.ThetaLim = [0 360];%坐标轴的范围。
% 字体
ax.FontSize =15;%字体大小
ax.ThetaColor = 'b';%改变坐标字符颜色
% 网格
ax.ThetaGrid = 'off';%向外的直线网格显示与否。
ax.RGrid = 'on';%环形的网格显示与否。
ax.LineWidth = 1.5;%雷达图网的粗细。
ax.GridLineStyle = '-';%网格的显示方式。
ax.GridColor = 'white';%网格的颜色。
% TickLabel
ax.ThetaTickLabel = TickLabel;%改变坐标的字符
ax.ThetaTick = theta;% 显示的坐标点
ax.ThetaZeroLocation = 'right';% 0度所在位置
% R
ax.RAxisLocation = 90;% R轴的位置
% ax.RTickLabel = {'one','two','three','four'};%R轴的坐标
ax.RTickLabelRotation = 0;% R轴坐标字符旋转
ax.RColor = 'w' ;% 改变R轴坐标字符的颜色
% legend({'AUC'},'Location',[0.8 0.7 0.15 0.15],'FontSize',10);
% set(hl,'Orientation','horizon');
% title('不同脑区及算法的分类性能比较','Color','k','FontSize',15,'FontWeight','bold');
end

