function nifti2subjfolder(foldername_subject)
% input:
% foldername_subject=�����ÿ�������ļ������ֵ�ǰ׺
%output��
% ����ĺ���ļ�����FunImg_sorted
% =========================================================================
% ��;����һ���ļ����������е�nii�ļ��ֱ�ŵ�����subject�ļ�����
% =========================================================================
% ʹ�ñ�����
% 1.DICOM�ļ��Ѿ���Dcm2AsiszImg.exe���������--
% 2.ĳ��ģ̬��DICOM�Ѿ���copy_file_for_DPARSF.m���������DPASFA�����ʽ--
% 3.���б����ļ��б�Rename��������������extractID��ȡID�����õ�OldName.mat��ID.mat--
% 4.FunRawĿ¼һ������dcm2niigui.exe��ת����4D.nii/.hdr�ļ���������Щ�ļ�����һ��û������һ�����ļ������ֶ�Ӧ���Ӷ���֪����һ��.nii
% ������һ������--
% =========================================================================
% ������������
% 1. ��ת��������.nii/.hdrһ��ŵ�FunImg��
% 2. ������Oldname�Ƚ�
% 3. ��������i��Oldname��ͬ�������ŵ��ļ���Ϊ'Poki'���ļ�����
% 1. ������Oldname�Ƚ�
% 2. ��������i��Oldname��ͬ�������ŵ��ļ���Ϊ'Poki'���ļ�����
% ��������
% 1. ��ȡFunImg�������ļ������֣�img_name
% 2. �Ѿ����ֵ��»���ɾ����oldname
% 3. ��ȡoldname������ƴ�����֣�oldname_pinyin
% 4. ģ��ƥ��img_name(i) ��oldname_pinyin������oldname_pinyin
% 5. ����λ��img_name������nii��hdr�����Ƶ���һ���ļ��У�'Poki'
%% ===============================================================
% �½��ļ��д洢�����funimg
loc_results=uigetdir({},'results folder');
if ~exist([loc_results,filesep,'FunImg_sorted'], 'file')
    mkdir([loc_results,filesep,'FunImg_sorted']);%�����ļ���ŵĵ�ַ
end
loc_FunImg_sorted=fullfile(loc_results,'FunImg_sorted');%���������FunImg_sorted
% ������ļ�������ǰ׺
if nargin<1
    foldername_subject=input('������sub_folder name ��ǰ׺: ','s');
end
%% 1.��ȡFunImg�������ļ�������
[name_ImgandHdr,path_ImgandHdr,~] = uigetfile({'*.img;*.hdr;*.nii;','All Image Files';...
    '*.*','All Files'},'MultiSelect','on','select files');
%% 2. �Ѿ����ֵ��»���ɾ����oldname
[name_oldname,path_oldname,~] = uigetfile({'*.mat','All Image Files';...
    '*.*','All Files'},'MultiSelect','off','select OldName.mat files');
oldname=importdata([path_oldname,name_oldname]);
oldname=oldname';
for i=1:length(oldname)
    oldname{i}(oldname{i}=='_')=[];%ɾ���»���
end
%% 3. ��ȡoldname������ƴ�����֣�oldname_pinyin
for i=1:length(oldname)
%     loc_ForMorF=oldname{i}=='M'|oldname{i}=='F';
%     loc_end=find(loc_ForMorF==1);
    loc_ForMorF=oldname{i}=='Y';
    loc_end=find(loc_ForMorF==1);
    loc_end=loc_end(end)-1;%���һ��M����F��ĸ��λ�ã���Ϊƴ���Ľ�βλ��
    oldname_pinyin{i}=oldname{i}(1:loc_end);%ƴ�����˴����Ը���ʵ������޸�ʹ��***
end
%% 4. ģ��ƥ��img_name(i) ��oldname_pinyin������oldname_pinyin
% �Ի���������ʽ��oldname��name_ImgandHdr���бȽϣ����ƾ����������Ϊ1�����ģ��ƥ��ɹ���������֤��ʵ�ɹ������strԽ��ȷԽ�ã�
for i=1:length(oldname_pinyin)
    %��ʾ���̣�10��һ��
    if ~rem(i,10)||i==length(oldname_pinyin)
        fprintf([num2str(i),'/',num2str(length(oldname_pinyin)),'\n'])%count
    else
        fprintf([num2str(i),'/',num2str(length(oldname_pinyin)),',']);%count
    end
    window_length=length(oldname_pinyin{i});
    for j=1:length(name_ImgandHdr)
        %�����Ƚ�
        loc_start=1;loc_end=loc_start+window_length-1;
        while loc_end<=length(name_ImgandHdr{j})
            resutl_cmp(j,loc_start)=strcmp(oldname_pinyin{i},name_ImgandHdr{j}(loc_start:loc_end));%����name_ImgandHdr�����i��������ƥ��Ľ����
            loc_start=loc_start+1;loc_end=loc_end+1;%ÿ����󻬶�һ����ĸ
        end
    end
    loc_ImgandHdr_copy=find(sum(resutl_cmp,2)>=1);%��ĳ��name_ImgandHdr����>=1���ھ������ص�������Ϊģ��ƥ��ɹ�***��copy_*Ϊλ��
    if isempty(loc_ImgandHdr_copy)
        fprintf([name_ImgandHdr{i},' ','�ļ�����û����Ҫ���Ƶ��ļ�\n']);
        continue %�Ҳ���ĳ�������֣���ִ�к���ѭ���ڴ��룬������һ��������
    end
    % �½��ļ��д洢Դ����
    if ~exist([loc_FunImg_sorted,filesep,foldername_subject,num2str(i)], 'file')
        mkdir([loc_FunImg_sorted,filesep,foldername_subject,num2str(i)]);%�����ļ���ŵĵ�ַ
    end
    loc_subfolder=[loc_FunImg_sorted,filesep,foldername_subject,num2str(i)];
    %% 5. ����,��Ϊloc_ImgandHdr_copy�����кܶ�������ʹ��ѭ��
    for k=1:numel(loc_ImgandHdr_copy)
        copyfile([path_ImgandHdr,filesep,char(name_ImgandHdr(loc_ImgandHdr_copy(k)))],loc_subfolder);
    end
end
fprintf('===============Completed!===============\n');%count
end