% ��;��������������ļ��Ƿ�Ϊ�գ�����������ļ���������ļ��Ƿ�Ϊ��
% ע�⣺ֻҪ�ڶ����ļ����������Ĳ�Ϊ�գ����ж�Ϊ�ǿ�
path_folder1=uigetdir({},'select folder');
content_folder1=dir(path_folder1);
name={content_folder1.name}';
name=name(3:end);
count=0;
% ��check�Ľ��д��text����
loc_filesep=find(path_folder1=='\');
loc_end=loc_filesep(end)-1;
path_check_results=path_folder1(1:loc_end);
fid = fopen([path_check_results,filesep, path_folder1(loc_end+2:end),'check_results.txt'],'w+');
% add time
fprintf(fid,[datestr(now,31) ,'\r\n']);
fprintf(fid,'=========================================================\r\n');
fclose(fid);
%
for i=1:length(name)
    path_folder2=[path_folder1,filesep,name{i}];
    content_folder2=dir(path_folder2);
    byte={content_folder2.bytes};
    byte=max(cell2mat(byte));%ֻȡ�����ļ�
    num_content_folder2=length(content_folder2)-2;
    %  ��check�Ľ��д��text����
fid = fopen([path_check_results,filesep, path_folder1(loc_end+2:end),'check_results.txt'],'a');
    fprintf(fid,[char(name{i}),': byte = %d\r\t\tfile number = %d\r\n'],byte, num_content_folder2);
    fprintf(fid,'----------------------------------------------------\r\n');
    fclose(fid);
    %
    if byte==0
        fprintf([name{i},' is empty\n'])
    else
        count=count+1;
    end
end

fprintf('Completed!\n')
if count==numel(name)
    fprintf('No file is empty! \n')
end