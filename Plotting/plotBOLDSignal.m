subplot(2,1,1);
plot(mean(a),'LineWidth',2,'color',[1 0.5 0]);
xlabel('Time Point');
ylabel('BOLD Signal');
box off
% title('ventral rAI');
set(gca,'FontSize',15);%�����������С
set(gca,'linewidth',2);%�������ϸ
set(gca,'XLim',[0,230]);%x�᷶Χ
% set(gca,'YLim',[0,15]);%y�᷶Χ
%%
subplot(2,1,2);
plot(mean(b),'LineWidth',2,'color',[0 0.5 0]);
xlabel('Time Point');
ylabel('BOLD Signal');
box off
% title('dorsal rAI');
set(gca,'FontSize',15);%�����������С
set(gca,'linewidth',2);%�������ϸ
set(gca,'XLim',[0,230]);%x�᷶Χ
% set(gca,'YLim',[0,15]);%y�᷶Χ
% �ܱ���
title=suptitle('Temporal-Domain BOLD Signals');
set(title,'FontSize',20);%�����������С