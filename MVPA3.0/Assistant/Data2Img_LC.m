function Data2Img_LC(data_to_transfer,img_name)
%�˺��������.img����.nii�ļ���Ϊ.mat�ļ�������ļ�С�ڻ�ĵ���1����������ɽ�'MultiSelect'��Ϊ'off'����
[file_name,path_source1,~] = uigetfile({'*.nii;*.img;','All Image Files';...
    '*.*','All Files'},'MultiSelect','off','��ѡ��ģ��ͼ��');
img_strut_temp=load_nii([path_source1,char(file_name)]);
img_strut_temp.img=data_to_transfer;
save_nii(img_strut_temp,img_name)
end


