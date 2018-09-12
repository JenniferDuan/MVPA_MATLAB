function [ location_up_greater,location_up_equal,location_up_less, numb_greater,numb_equal,numb_less]...
          = Compare_KendallTau( data )
% �˺�����Ϊ�˼���kendall tau ��׼�����˺����Ƚ�һ��1ά�����������������ݵĴ�С��������λ���߼��������Ŀ��
%���룺1ά����
%������������ݵĴ�С�ȽϵĽ��������λ�ú���Ŀ��
%���ߣ��賬 email��lichao198706172gmail.com
%% ����׼����ת�û�
data1=reshape(data,length(data),1);%תΪ������
data2=reshape(data,1,length(data));%תΪ������
%% ��λ���ڵĶ���λ�ã�������Ŀ
location_all_greater=data1>data2;
location_up_greater=triu(location_all_greater,1);
numb_greater=sum(location_up_greater(:));
% %% ����һ��mask��������ȡ�����Ǿ��󣬲������Խ���
% mask=ones(size(Matrix_all_greater));
% mask=triu(mask,1);
% mask=mask==1;
% %% ��ȡmask�ڵ�Matrix_all
% Matrix_up_greater = Matrix_all_greater(mask);%�����Ǿ��󣬲������Խ���,ע���ǰ����д������µ�ѭ��
%% ��λ���ڵĶ���λ�ã�������Ŀ
location_all_equal=data1==data2;
location_up_equal=triu(location_all_equal,1);
numb_equal=sum(location_up_equal(:));
%% ��λС�ڵĶ���λ�ã�������Ŀ
location_up_less= location_up_equal+location_up_greater;
location_up_less=location_up_less==0;
location_up_less=triu(location_up_less,1);
numb_less=sum(location_up_less(:));
end

