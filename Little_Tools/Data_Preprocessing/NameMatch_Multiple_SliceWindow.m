function IfMatch=NameMatch_Multiple_SliceWindow(Name,Name_Fragment_Cell)
% ��;��ȷ��Name���Ƿ�ͬʱ�����˶��Ԥ����ֶ�Name_Fragment_Struct
% �Ի���������ʽ���������һ���ֶ�Name_Fragment_Struct��Name���бȽϣ����ƾ����������Ϊ1�����ģ��ƥ��ɹ���������֤��ʵ�ɹ������Name_Fragment_StructԽ��ȷԽ�ã�
% input��
% Name��һ���ַ���
% Name_Fragment��һ��cell����������ַ������������Name�ַ����еĶ��Ǳ���ַ���Ƭ��
% output��
% IfMatch��һ���߼�ֵ��1��ʾ��Name�������ֶ�Name_Fragment��0��ʾName��û��Name_Fragment�ֶ�
%% ==============================================================
%��û���ֶ���������ʱ��������ʾ����
if nargin<2
    Name_Fragment_Char=input('������һ����ƥ���ֶΣ�����ֶ���*�Ÿ�����','s');
    Name_Fragment_Char=['*',Name_Fragment_Char,'*'];
    loc_star=find(Name_Fragment_Char=='*');
    for i=1:length(loc_star)-1
        Name_Fragment_Cell{i}=Name_Fragment_Char(loc_star(i)+1:loc_star(i+1)-1);
    end
end
%% ==============================================================
fun=@(x) NameMatch_Single_SliceWindow(Name,x);
result_cmp=cellfun(fun,Name_Fragment_Cell);
IfMatch=sum(result_cmp)==length(Name_Fragment_Cell);
end
