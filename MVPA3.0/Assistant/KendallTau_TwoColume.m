function kendall_tau = KendallTau_TwoColume( data,subtract_up_label )
%�˺���������������kendall tau���㡣
%���룺dataΪԪ�����飬subtract_up_labelΪ���󣨽���Compare2_KendallTau�������㣩
%% ��������Ĳ�ֵ
%  subtract_up_label= Compare2_KendallTau( label );
data=cell2mat(data);
 subtract_up_data= Compare2_KendallTau( data );
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

