function IfMatch=NameMatch_Single_SliceWindow(Name,Name_Fragment)
% ��;��ȷ��Name���Ƿ����ֶ�Name_Fragment
% �Ի���������ʽ��Name_Fragment��Name���бȽϣ����ƾ����������Ϊ1�����ģ��ƥ��ɹ���������֤��ʵ�ɹ������Name_FragmentԽ��ȷԽ�ã�
% input��
    % Name��һ���ַ���
    % Name_Fragment��һ���ַ������������Name�ַ����е�һ��Ǳ���ַ���Ƭ��
% output��
    % IfMatch��һ���߼�ֵ��1��ʾ��Name�������ֶ�Name_Fragment��0��ʾName��û��Name_Fragment�ֶΡ�
%% ==============================================================
window_length=length(Name_Fragment);
%�����Ƚ�
loc_start=1;loc_end=loc_start+window_length-1;
result_cmp=0;
while loc_end<=length(Name)
    result_cmp(loc_start)=strcmp(Name_Fragment,Name(loc_start:loc_end));%����file_name2�����i��������ƥ��Ľ����
    loc_start=loc_start+1;loc_end=loc_end+1;%ÿ����󻬶�һ����ĸ
end
IfMatch=any(result_cmp);%��ĳ��Name����>=1���ھ������ص�������Ϊģ��ƥ��ɹ�***��copy_*Ϊλ��
end