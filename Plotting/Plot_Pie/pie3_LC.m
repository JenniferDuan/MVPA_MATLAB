function pie3_LC
%UNTITLED2 �˴���ʾ�йش˺�����ժҪ
%% ���ñ�ͼ��ɫ��
figure('color',[0.2 0.6 0.4]);%������ɫ
cm = [0 0.8 0.6; 0.5 0.5 0.5];%��ͼ��������ɫ
colormap(cm)
%% ����ͼ
label={'Sleep',''};
h=pie3([0.1,0.9],[1,0]);
%% ����text�Ĵ�С
t = h(4);
t.FontSize = 60;%����label��С
t.Color='white';%text����ɫ
set(gcf, 'InvertHardCopy', 'off');%���ú󱳾�����һͬ�����������
end

