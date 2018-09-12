function dcm2nii_LC
%which_mode=fMRI or DTI
tic;
clc
clear
%%
whitch_mode=input('������fMRI����DTI:','s');
if strcmp(whitch_mode,'fMRI')
    param='dcm2nii_fMRI.ini';
else
    param=dcm2nii_DTI.ini;
end
%%
%% ==================parameter input ========================
program_path=spm_select(1,'dir','ѡ��ִ����������ļ���');
addpath(program_path);
datadir=spm_select(1,'dir','ѡ����Ҫת�������������ļ���');
cd(datadir);
loc= find(datadir=='\');
outdir_name=['outdir',num2str(now)];
outdir=datadir(1:loc(length(find(datadir=='\'))-1)); %datadir����һ��Ŀ¼
mkdir(outdir,outdir_name);
path_outputdir=[outdir,outdir_name];
target=dir(datadir);
%%
N=length(dir(datadir));
for s=3:N
    disp(strcat('����ת����',num2str(s-2),'����'));
 data1=dir([datadir,filesep,target(s).name]);
 name1=cell(1,length(data1));
 for i=1:length(data1)
 name1{i}=data1(i).name;
 end     
 eval(['! ',program_path,filesep,'dcm2nii.exe -b ',program_path,filesep,param,target(s).name]); % Windows system
 data2=dir([datadir,filesep,target(s).name]);
 name2=cell(1,length(data2));
 for i=1:length(data2)
 name2{i}=data2(i).name;
 end 
 loc1=ismember(name2,name1);
%  mkdir(path_outputdir,target(s).name);
%  movefile([datadir,filesep,target(s).name,filesep,name2{(loc1==0)}],[path_outputdir,filesep,target(s).name]);%movefile([datadir,filesep,target(s).name,filesep,name2{find(loc1==0)}],[path_outputdir,filesep,target(s).name]);
end 
%%=====================================================================
%%
% %%move x.....gz
% delete_target_dir1=dir([outdir,outdir_name]);
% for i=3:length(delete_target_dir1)
% delete_target_dir2=dir([outdir,filesep,outdir_name,filesep,delete_target_dir1(i).name]);
% for j=1:length(delete_target_dir2)
%     name3=delete_target_dir2(j).name;
%     if name3(1)=='x'&&name3(end)=='z'
%     delete([outdir,filesep,outdir_name,filesep,delete_target_dir1(i).name,filesep,name3]);%%delete
%     end
% end
% end
%%=====================================================================
cd (program_path);
disp(num2str(toc));
end




