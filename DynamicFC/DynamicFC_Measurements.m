% ����ROI wise dynamic FC ��measurements
%input��
% ZFC_dynamic��ROI wise�Ķ�̬�������Ӿ���,ÿ���������ݵ�size=N*N*W,NΪROI������WΪslide
% window����
% output��
%
%%
tic
%locate each subject's data
[file_name,path_source,~] = uigetfile({'*.mat;','All Image Files';...
    '*.*','All Files'},'MultiSelect','on','��ѡ��̬FC����');
if iscell(file_name)
    n_sub=length(file_name);
    mat_template=importdata([path_source,char(file_name(1))]);
else
    n_sub=1;
    mat_template=importdata([path_source,char(file_name)]);
end
% �������Ŀ¼
path_result='D:\WorkStation_2018\WorkStation_2018_08_Doctor_DynamicFC_Psychosis\Data\zDynamic\DynamicFC17_1_screened\results\std\SZ';
% load data and calculate measurements
h = waitbar(0,'...');
for i=1:n_sub
    % load all MAT files
    if iscell(file_name)
        mat=importdata([path_source,char(file_name(i))]);
    else
        mat=importdata([path_source,char(file_name)]);
    end
    
    % ����dynamic FC ��measurements
    Std=std(mat,0,3);
    Std=squeeze(Std);
    
    % save
    loc_name_star=find(file_name{i}=='_')+1;loc_name_end=find(file_name{i}=='.')-1;%��ȡ���Ե����� 
    measurements_path=[ path_result,filesep,'Std_',file_name{i}( loc_name_star: loc_name_end),'.mat'];%������·��
    save(measurements_path,'Std');
    
    % waitbar
    waitbar(i/n_sub,h,sprintf('%2.0f%%', i/n_sub*100)) ;
end
close (h)
fprintf('==================================\n');
fprintf('Completed!\n');
toc