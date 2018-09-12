function CopyFile_One2More_NameMatch(NameForMatch)
% =========================================================================
% ��;����һ���ļ����������е�nii�ļ��ֱ�ŵ�����subject�ļ�����
% =========================================================================
% input:
%       NameForMatch=�ַ���Ƭ�Σ�>=1�����������ڴ��ַ���Ƭ�Σ�>=1�������ļ����Ƶ���
%% ===============================================================
fprintf('Copying==============================>>>\n')
if nargin<1
    Name_Fragment_Char=input('������һ����ƥ���ֶΣ�����ֶ���*�Ÿ�����','s');
    Name_Fragment_Char=['*',Name_Fragment_Char,'*'];
    loc_star=find(Name_Fragment_Char=='*');
    for i=1:length(loc_star)-1
       NameForMatch{i}=Name_Fragment_Char(loc_star(i)+1:loc_star(i+1)-1);
    end
end
%% ===============================================================
% �½��ļ��д洢�����Ƶ��ļ�
TIME=datestr(now,30);
loc_results=uigetdir({},'results folder');
if ~exist([loc_results,filesep,'FileCopy',TIME], 'file')
    mkdir([loc_results,filesep,'FileCopy',TIME]);%�����ļ���ŵĵ�ַ
end
loc_copy=[loc_results,filesep,'FileCopy',TIME];%���������FunImg_sorted
%% 1.��ȡFunImg�������ļ�������
[name,path,~] = uigetfile({'*.img;*.hdr;*.nii;','All Image Files';...
    '*.*','All Files'},'MultiSelect','on','select files');
%% 2. �Ѿ����ֵ��»���ɾ����oldname

%% 3. ��ȡoldname������ƴ�����֣�name

%% 4. ģ��ƥ��
IfMatch=0;%�˴�һ��Ҫ����ʼֵ0
for i=1:length(name)
    %��ʾ���̣�10��һ��
    if ~rem(i,10)||i==length(name)
        fprintf([num2str(i),'/',num2str(length(name)),'\n'])%count
    else
        fprintf([num2str(i),'/',num2str(length(name)),',']);%count
    end
    
    IfMatch(i)=NameMatch_Multiple_SliceWindow(name{i},NameForMatch);
    
    if IfMatch(i)==0
        continue;
    else
        copyfile([path,filesep,char(name(i))],loc_copy);
    end
end
%% ���汻���Ƶ��ļ���¼
fid = fopen([loc_copy,filesep,'IfMatch.txt'],'a');
fprintf(fid,[datestr(now,31) ,'\r\n']);
fprintf(fid,'�����Ƶ��ļ������=======================================\r\n');
fprintf(fid,'��%d�ļ�\r����%d���ļ�������\r\n',numel(IfMatch),sum(IfMatch));
fprintf(fid,'%d\r\n',IfMatch);
fprintf(fid,'=======================================================\r\n');
fclose(fid);
fprintf('===============Completed!===============\n');%count
end