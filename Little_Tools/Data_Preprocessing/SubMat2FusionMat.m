% ��;�� ����subjectΪ��λ��.mat���ݺϲ�Ϊһ���ļ����Ӷ����Խ��к�����ͳ�Ʒ���
[name,path,~] = uigetfile({'*.mat;*.txt;','All Image Files';...
    '*.*','All Files'},'MultiSelect','on','select files');
data_temp=importdata([path,name{1}]);
data=zeros(length(name),2);
for i=1:length(name)
    d=importdata([path,name{i}]);
    data(i,:)=[d(1,2),d(1,3)];
end
