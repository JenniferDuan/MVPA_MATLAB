function [file_name,path_source,data ] = Img2Data_LC(ifMultiple,Reminder)
% �˺��������.img����.nii�ļ���Ϊ.mat�ļ�������ļ�С�ڻ�ĵ���1����������ɽ�'MultiSelect'��Ϊ'off'����
% input:
%      N=������ͼ��
%      ifMultiple='on' OR 'off',�Ƿ�Ϊ����ļ�
% output: 
%      dataΪ4D.mat�ļ���ǰ������ά����ͼ��ά�ȣ����ĸ�ά������������
%% ��ȡ����ͼ��
if nargin<2
    Reminder='��ѡ����Ҫת�������ݵ�ͼ��';
end
if nargin<1
    ifMultiple='on';
end
%
[file_name,path_source,~] = uigetfile({'*.nii;*.img;','All Image Files';...
    '*.*','All Files'},'MultiSelect',ifMultiple,Reminder);
img_strut_temp1=load_nii([path_source,char(file_name(1))]);
data_temp=img_strut_temp1.img;
[x ,y ,z]=size(data_temp);n_sub1=length(file_name);
data=zeros(x, y, z, n_sub1);
for i=1:n_sub1
   img_strut1=load_nii([path_source,char(file_name(i))]);
   data(:,:,:,i)=img_strut1.img;
end
file_name=file_name';
end

