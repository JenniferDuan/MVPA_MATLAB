function  copy_file_for_DPARSF(name_source)
%Email: lichao19870617@gmail.com
%���ܣ� ���������ļ����ļ��и��Ʋ���������·����
%���幦���磺��Dcm2AsiszImg������DICOM�������ļ����Ƶ���Ӧ�ļ���(ע�⣺��DICOM�������ļ�������Ŀ¼�£���Controls-Subject1-RSBOLDFMRI-'DICOM')���Ա�DPARSF��DPABI���������
%input:
%name_source:��Ҫ���Ƶ��ļ��п������ļ����ľ�ȷȫ�ƣ��磺'501_T1W_3D_TFE_ref2'��Ҳ�����ǿ���ȷ���ļ�����ģ���ֶΣ��磺'T1W'��,ע�⣺�����Ƕ��ƥ���ֶΡ�
%�粻����,��ֻ���룺copy_file2DPARSF('T1W'),������ֶ�ƥ�䡣
%ʹ�÷�����������õ�DICOM�ļ�ȫ������һ���ļ������档Ȼ�����д˴��룬���磺copy_file2DPARSF(��T1W��, 'fuzzy')
%%
fprintf('Copying==============================>>>\n')
if nargin<1
    Name_Fragment_Char=input('������һ����ƥ���ֶΣ�����ֶ���*�Ÿ�����','s');
    Name_Fragment_Char=['*',Name_Fragment_Char,'*'];
    loc_star=find(Name_Fragment_Char=='*');
    for i=1:length(loc_star)-1
        name_source{i}=Name_Fragment_Char(loc_star(i)+1:loc_star(i+1)-1);
    end
end
%% Դ�ļ���Ŀ��·��
%Դ
path_source1 = spm_select(1,'dir','ѡ����Ҫ���Ƶ��ļ���');
up1 = dir(path_source1);
file_name_source={up1.name}';
%Ŀ��
path_target = spm_select(1,'dir','Ŀ��·��');
%% ��Ŀ��·���½���������ݵ��ļ��в�����Դ�ļ�����
% loc_sepration=find(path_source1=='\');
% try
%     %�Լ�����
%     name_raw=path_source1(loc_sepration(end)+1:end);
% catch
%     %���ҵ���
%     name_raw=path_source1(loc_sepration(end-1)+1:end-1);
% end
% name_raw=['Copy','_',name_raw];
name_raw=input('�������ļ�������','s');
if ~exist([path_target,filesep,name_raw], 'file')
    mkdir(fullfile(path_target,name_raw));%�����ļ���ŵĵ�ַ
end
loc_subject=[path_target,filesep,name_raw];%��Ÿ���subject��Ŀ¼
%%
for i=3:length(file_name_source)
    %��ʾ���̣�10��һ��
    if ~rem(i-2,10)||i==length(file_name_source)
        fprintf([num2str(i-2),'/',num2str(length(file_name_source)-2),'\n'])%count
    else
        fprintf([num2str(i-2),'/',num2str(length(file_name_source)-2),',']);%count
    end
    up2=dir(fullfile(path_source1,up1(i).name));
    file_name2={up2.name}';
    %ģ��ƥ��
    % 4. ģ��ƥ��img_name(i) ��oldname_pinyin������oldname_pinyin
    % �Ի���������ʽ��oldname��file_name2���бȽϣ����ƾ����������Ϊ1�����ģ��ƥ��ɹ���������֤��ʵ�ɹ������strԽ��ȷԽ�ã�
    IfMatch=0;%�˴�һ��Ҫ����ʼֵ0
    for j=1:length(file_name2)
        IfMatch(j)=NameMatch_Multiple_SliceWindow(file_name2{j},name_source);
    end
    loc_target=find(IfMatch==1);%��ĳ��file_name2����>=1���ھ������ص�������Ϊģ��ƥ��ɹ�***��copy_*Ϊλ��
    %
    if isempty(loc_target)
        disp([file_name_source{i},' ','�ļ�����û����Ҫ���Ƶ��ļ�']);
    else
        if ~exist([loc_subject,filesep,char(file_name_source(i))], 'file')
            mkdir([loc_subject,filesep,char(file_name_source(i))]);%�����ļ���ŵĵ�ַ
        end
        % ����
        copyfile([path_source1,filesep, char(file_name_source(i)),filesep,char(file_name2(loc_target))], ...
            [loc_subject,filesep,char(file_name_source(i))]);
    end
end
fprintf('Copy completed!\n')
end