function ZFC_dynamic=DynamicFC(ts_seed,data_nii,window_step,window_length)
% ��;�� ����Voxel Wise��dynamicFC����
%input
% ts_seed=���ӵ��ʱ������
%data_nii=ĳ�����Ե��������ص�ʱ�����У�size=[ndim1,ndim2,ndim3,nts],nts=ʱ�����еĳ���
%output��
%ZFC_dynamic=ĳ�����ԵĶ�̬���ӣ�size=[ndim1,ndim2,ndim3,nw],nw=window�ĸ���
%% =====================================
if nargin <3
  window_step=1; %Ĭ��ÿ�λ���1��TR
  window_length=50;  %Ĭ��50��TR
end
%% =====================================
%����dynamic FC���ڸ���,Ϊ��Ԥ����ռ�
window_star=1;window_end=window_length;
volum=size(data_nii,1);% dynamic FC parameters
count=0;
while window_end<=volum
    count=count+1;%������ٸ����������ٸ���̬����,��������ռ��ZFC_dynamic,�Ӷ��ӿ��ٶ�
    window_star=window_star+window_step;%����
    window_end=window_end+window_step;%����
end
% allocate space
ndim1=size(ts_seed,2); ndim2=size(data_nii,2);
FC_dynamic=zeros(ndim1,ndim2,count);
%�����Ķ�̬���Ӽ��㣬ע�⣺��ʼ��window_star��window_end
window_star=1;window_end=window_length;
while window_end<=volum
    data_nii_w=data_nii(window_star:window_end,:);
    ts_seed_w=ts_seed(window_star:window_end,:);
    R_dynamic=corr(ts_seed_w,data_nii_w);
    FC_dynamic(:,:,window_star)=R_dynamic;%Static zFC
    window_star=window_star+window_step;%����
    window_end=window_end+window_step;%����
end
ZFC_dynamic=0.5*log((1+FC_dynamic)./(1-FC_dynamic));%Fisher R-to-Z transformation
%2�����ӵ㣬70000������Լ11��
end
