function Rename_NotAddNumber(object)
%��;���޸��ļ������ļ���������Rename��ͬ���ǣ������벻��ԭ������������ֱ�š�
%object='folder' or 'file'
% current·��
currentFolder = pwd;
OldName={};
%% ִ��
if nargin<1
    object='folder';
end
if strcmp(object,'folder')
    path_source1 = uigetdir({},'��ѡ���ļ���');%ѡ�ļ���
    strut_path_source1=dir(path_source1);
    file_name1={strut_path_source1.name};
    star=3;
else
    [file_name1,path_source1,~] =uigetfile({'*';'*.nii';'*.img'},'MultiSelect','on','��ѡ��ͼ����ļ�');%ѡ�ļ�
    star=1;
end
cd (path_source1)
len = length(file_name1);
if len>=1000
    disp('�����ļ���Ŀ����1000������ϵlichao19870617@163.com����ֱ���޸�ԭ����');
    return;
end
filename = input('������Ϊ:','s');
Saveoldname = input('�Ƿ������ļ�����Y/N��:','s');
switch Saveoldname
    case 'Y'
        tic;
        for k=star:len
            oldname=char(file_name1{k});
            if star==1
                OldName{k}=oldname;
            else
                OldName{k-2}=oldname;
            end
            if strcmp(object,'folder')
                newname=strcat(filename,'_',oldname);
            else
                newname=strcat(filename,'_',oldname(1:find(oldname=='.')-1),oldname(find(oldname=='.'):end));
            end
            cmd=sprintf('rename %s %s',oldname,newname);
            system(cmd);
        end;
        disp(['��������������ļ����ɹ�������ʱ��=',num2str(toc),'��']);
    case 'N'
        tic;
        for k=star:len
            oldname=char(file_name1{k});
            if star==1
                OldName{k}=oldname;
            else
                OldName{k-2}=oldname;
            end
            if strcmp(object,'folder')
                newname=strcat(filename ,int2str(k-2),'.nii');
            else
                newname=strcat(filename ,int2str(k),oldname(find(oldname=='.'):end));
            end
            cmd=sprintf('rename %s %s',oldname,newname);
                system(cmd);
        end;
        disp(['����������������ļ����ɹ�������ʱ��=',num2str(toc),'��']);
end
%  ����·��
cd (currentFolder);
%���������
save('OldName.mat','OldName');
end

