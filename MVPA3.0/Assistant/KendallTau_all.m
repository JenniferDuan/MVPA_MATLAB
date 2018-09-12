function kendall_tau_all = KendallTau_all( data,label )
% �˺�����������Kendall tau,7000��������Ҫ2�����ң�6*10^4�����������Ҫ16��
%���룺data��2D������label��������
%�����ÿһ��������Kendall tau
%% ����׼��
f=@Compare2_KendallTau;
subtract_up_label= f( label );
data=data';%ת�ã����ں��潫һ�������ŵ�cell��һ��С����
[m,n]=size(data);
data=mat2cell(data,ones(1,m),n);%��dataתΪcell
%% ��������������Kendall tau
kendall_tau_all=arrayfun(@KendallTau,data);
%% �Ǻ���
function kendall_tau = KendallTau( data1)
%�˺���������������kendall tau���㡣
%���룺dataΪԪ�����飬subtract_up_labelΪ���󣨽���Compare2_KendallTau�������㣩
%% ��������Ĳ�ֵ
%  subtract_up_label= Compare2_KendallTau( label );
data1=cell2mat(data1);
 subtract_up_data= f( data1 );
 %% ����һ�ºͲ�һ�¶�����
 % �˻�
 multi_all=subtract_up_label.*subtract_up_data;
 %��������
 Nc_nozero=sum(multi_all(:)>0);%��Ϊ���һ�¶�
%  Nd_nozero=sum(multi_all(:)<0);%��Ϊ��Ĳ�һ�¶�
 %�������
  loc_zero_label=subtract_up_label==0;
  loc_zero_data=subtract_up_data==0;
  multi_zero=loc_zero_label.*loc_zero_data;
   %����һ��mask��������ȡ�����Ǿ��󣬲������Խ���
  mask=ones(size(multi_zero));
  mask=triu(mask,1);
  mask=mask==1;
 Nc_zero=sum(multi_zero(mask));%Ϊ���һ�¶�����
%  Nd_zero=sum(multi_zero(mask));%Ϊ��Ĳ�һ�¶�����
  total=sum(mask(:));
  Nd=total-Nc_nozero-Nc_zero;%��һ����
  %% ����Kendall Tau
  kendall_tau=(Nc_nozero+Nc_zero-Nd)/total;
end
%%
function  subtract_up= Compare2_KendallTau( data )
% �˺�����Ϊ�˼���kendall tau ��׼�����˺����Ƚ�һ��1ά�����������������ݵĴ�С�������ز�ֵ�����������󣬲������Խ��ߣ���
%���룺1ά����
%�������ֵ�����������󣬲������Խ��ߣ���
%���ߣ��賬 email��lichao198706172gmail.com
%% ����׼����ת�û�
data1=reshape(data,length(data),1);%תΪ������
data2=reshape(data,1,length(data));%תΪ������
%% �������Ӽ�Ĳ�
subtract=data1-data2;
subtract_up=triu(subtract,1);
end
end


