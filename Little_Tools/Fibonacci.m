function   Fibonacci
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
initial=input('��ʼ���Ӷ���:','s');
initial=str2double(initial);
month=input('����������:','s');
month=str2double(month);%�ܹ���ֳ���ٸ���=����������
room=ones(1,initial)+1;%��ʼʱ���������������
for i=1:month
   old=find(room>=2); 
   addition=length(old);
   room =[room zeros(1,addition)];%�³�����С����
   room=room+1;%��ĩ�����е����Ӷ�������һ����
end
total=length(room);
disp(['�����������ǣ�', num2str(total)]);
end

