function  subtract_up= Compare2_KendallTau( data )
% �˺�����Ϊ�˼���kendall tau ��׼�����˺����Ƚ�һ��1ά�����������������ݵĴ�С�������ز�ֵ�����������󣬲������Խ��ߣ���
%���룺1ά����
%�������ֵ�����������󣬲������Խ��ߣ���
%���ߣ��賬 email��lichao19870617@gmail.com
%% ����׼����ת�û�
data1=reshape(data,length(data),1);%תΪ������
data2=reshape(data,1,length(data));%תΪ������
%% �������Ӽ�Ĳ�
subtract=data1-data2;
subtract_up=triu(subtract,1);
end

