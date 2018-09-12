% ��;����txt�ĵ�����������Ŀ��������ȡ������Ȼ����Ͷ����Ϊ��λ���浽excel�����
% txt�ĵ��е���Ŀ�� '|'Ϊ�ָ�������е���
%% ==========================Input==============================
% input:1 txt�ĵ��е���Ŀ�ָ���
ProjSep='|';
% input2: ѡ�������·��
[Path_Results] =uigetdir({},'ѡ��ڽ�����·����ַ���ļ��У�');
% input3: ����ȡ����Ŀ�����Լ�Ҫд�뵽excel����Ŀ����
NameToExtrat={'����','�ʺ�','��������','ժҪ','�����־','���׽��','����'};
NameToWrite={'����','�ʺ�','��������','ժҪ','�����־','���׽��','Ͷ����','�շ�������'};
% input4: ѡ������ȡ���ˣ�Ͷ���ˣ�������
[NameOfPersonFile,PathOfPersonFile,~] = uigetfile({'*.xlsx;','All Image Files';...
    '*.*','All Files'},'MultiSelect','off','��ѡ��Ͷ�������Ƶ�excel�ļ�');
[~,NameOfPerson,~]=xlsread([PathOfPersonFile,'\',NameOfPersonFile]);
% input5: ��ȡ����Դ����
%    number of source folder
NumOfSource=input('������Դ�ļ��еĸ�����Ȼ��س��� ','s');
NumOfSource=str2double(NumOfSource);
%    read source folder path
Path_Source=cell(2,1);
for i=1:NumOfSource
    [Path_Source{i}] =uigetdir({},['ѡ���',num2str(i),'Դ�����ļ���']);
end
%% =======================All Input Completed!========================

%% ===============Read all txt file path in source================
Path_TxtFile={};
for i=1:NumOfSource
    SourceCell=dir(Path_Source{i});
    Name_SourceFile={SourceCell.name};
    Name_SourceFile=Name_SourceFile(1,3:end)';
    Path_SourceFile=strcat(Path_Source{i},'\',Name_SourceFile);
    for j=1:numel(Path_SourceFile)
        TxtFile=dir(Path_SourceFile{j});
        TemName_TxtFile={TxtFile.name}';
        TemName_TxtFile=TemName_TxtFile(3:end);
        TemPath_TxtFile=strcat(Path_SourceFile{j},'\',TemName_TxtFile);
        Path_TxtFile=cat(1,Path_TxtFile,TemPath_TxtFile);
    end
end
%% ===================Read Txt Path Completed!===================

%% ��������������ѭ������һ����Ͷ����ѭ�����ڶ�����txt�ļ���ѭ��
for NumOfPerson=1:numel(NameOfPerson) % ��һ��ѭ����Ͷ����
    fprintf('�� %1d ��Ͷ����\n',NumOfPerson);
    % ��txt�ļ�:�ڶ���ѭ��
    ExtractedData_AllTxt={};%��ĳ��������txt����ȡ�����ݽ�����Ԫ������
    %% =============Begin to extract one person's data============
    for NumOfTxt=1:numel(Path_TxtFile)
        if rem(NumOfTxt,5)==0;fprintf('�� %1d ��txt�ļ�\n', NumOfTxt);end
        fid = fopen( Path_TxtFile{NumOfTxt},'r');
        TxtCell = textscan(fid,'%s');
        TxtCell=TxtCell{1};
        fclose(fid);
        %% ȷ��������Ŀ��ÿһ�еĶ�Ӧλ��
        NameOfTxtPreject=TxtCell(1);
        ContentOfTxt=TxtCell(2:end);
        % txt��Ŀ
        IndexOfProjectSep=strfind(NameOfTxtPreject{1},ProjSep);
        % �ҵ���Ŀ���Ƶ�index
        for i=1:numel(NameToExtrat)
            IndexOfProjectName(i)=strfind(NameOfTxtPreject{1},NameToExtrat{i});%
        end
        % ��Ŀ���ĵ�һ���ַ���ǰһ��indexΪ���ڷָ�����index
        IndexOfProjectName=IndexOfProjectName-1;
        % ���� ��һ��IndexOfProjectName��ȷ����Ӧ�ָ����ڷָ���index���������index
        [IfMember,Ind]=ismember(IndexOfProjectName,IndexOfProjectSep);
        % txt����
        MyStrcmpSep=@(Str) strfind(Str,ProjSep);
        IndexOfContentSep=cellfun(MyStrcmpSep,ContentOfTxt,'UniformOutput', false);
        % ȷ��ĳ��Ͷ���߳�����txt����һ��
        MyStrcmpName=@(Str) strfind(Str,NameOfPerson{NumOfPerson});
        IfMatch=cellfun(MyStrcmpName,ContentOfTxt,'UniformOutput', false);
        % ===============================��ȡ����=================================
              
        try
            NumOfMatch=sum(cell2mat(IfMatch)~=0);
        catch
            NumOfMatch=0;
            for i=1:numel(IfMatch)
                if  ~isempty(IfMatch{i})
                     NumOfMatch= NumOfMatch+1;
%                     fprintf('��%d����Ϊ��\n',i);
                end
            end
        end
        % �ж�ĳ��txt�ĵ����Ƿ���Ͷ������Ϣ��û���������һ��ѭ������ʡʱ��
        if NumOfMatch==0
            continue;
        end
        % ��ʼ��ȡ��Ϣ
        ExtractedData_OneTxt=cell(NumOfMatch,numel(NameToExtrat));
        count=0;
        for i=1:numel(IfMatch)
            if ~isempty(IfMatch{i})
                count=count+1;
                for j=1:numel(NameToExtrat)
                    LocOfStr=IndexOfContentSep{i}(Ind(j):Ind(j)+1);
                    if LocOfStr(2)-LocOfStr(1)==1
                        ExtractedData_OneTxt{count,j}='N/A';% ��Ϊ��ʱ������N/A
                    else
                        ExtractedData_OneTxt{count,j}=ContentOfTxt{i}(LocOfStr(1)+1:LocOfStr(2)-1);
                    end
                end
            end
        end
        ExtractedData_AllTxt=cat(1,ExtractedData_AllTxt,ExtractedData_OneTxt);
    end
    %% =====one person's data have been extract completely!=======
    %% =======================write to excel======================
    if ~isempty(ExtractedData_AllTxt)
        DataOfExcel={};
        DataOfExcel(:,[1:6,8])=ExtractedData_OneTxt;
        DataOfExcel(:,7)={NameOfPerson{NumOfPerson}};
        FileNameOfExcel = [Path_Results,filesep,NameOfPerson{NumOfPerson},'.xlsx'];
        DataOfExcel =cat(1,NameToWrite,DataOfExcel);
                Inves=DataOfExcel(2:end,6);
                Inves=cellfun(@str2num,Inves);
                Inves=sum(Inves);
                InvesCell={'Ͷ�ʺϼ�',Inves};
        sheet = 1;
        xlRange1 = 'A1';
                NumOfDataRaw=size(DataOfExcel,1);
                xlRange2 = strcat('A',num2str(NumOfDataRaw+1));
        xlswrite(FileNameOfExcel,DataOfExcel,sheet,xlRange1);
                xlswrite(FileNameOfExcel,InvesCell,sheet,xlRange2);
    else
        fprintf(['Ͷ����:\t',NameOfPerson{NumOfPerson},'\t','û�п���ȡ����\n']);
    end
    %% =======one peson's data have been written to excel=========
end
%% =============All peson's data have been written to excel================
fprintf('%9.0f��Ͷ���˵������ѱ���ȡ�������浽excel�ĵ�!\n',numel(NameOfPerson));
