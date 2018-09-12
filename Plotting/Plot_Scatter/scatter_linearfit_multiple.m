function scatter_linearfit_multiple( X,Y,Title,m,n )
%�˺������Ը�ɢ��ͼ�Լ���������߻���һ��ͼ����
%input----XΪ����ÿһ��Ϊһ��������YΪ��X���Ӧ�þ���ÿһ��Ϊһ��������x��y��������ͬ
%R��PΪ��Ӧ�����ϵ����pֵ����������������ֵ����ͨ����ط������
%TitleΪ��ɢ��ͼ�ı��⣬��һ��Ԫ�����󣬼���ɢ��ͼ���м���title
%m,n Ϊ��ɢ��ͼ�ľ����С��mΪ�У�nΪ�У��������ʺ�10����ͼ���ڵ�ɢ��ͼ���ƣ�����10����Ҫ�������룡��
if nargin <=3 %���δ����m��n����������ż�����ֱ�����ͼ��֡�
N_SubFig=size(X,2);
  if N_SubFig==2
      m=1;n=2;
  elseif ~mod(N_SubFig,2)
      m=N_SubFig/2;n=N_SubFig/2;
  else
      m=(N_SubFig+1)/2;n=(N_SubFig+1)/2;
  end
end
if nargin <=2 %���δ����Title,��TitleΪ�ա�
    Title=cell(N_SubFig,1);
end
    for i=1:size(X,2)
        subplot(m,n,i);
        scatter_linearfit(X(:,i),Y(:,i),Title{i});
%         xlabel('Granger causal influence','FontName','Times New Roman','FontSize',30,'Rotation',0)
%         ylabel('ISI','FontName','Times New Roman','FontSize',30,'Rotation',90)
        set(gca,'box','off')
    end

end

