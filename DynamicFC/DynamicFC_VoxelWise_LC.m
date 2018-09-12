function DynamicFC_VoxelWise_LC(window_step,window_length,opt)
%% =========================����˵��==============================
% ����Voxel wise�Ķ�̬�������ӵı�׼�standard deviation,std����ע�⣺���ӵ��ƽ��ʱ�����������ӵ㱾��Ҳ������أ�
% input��
% һ�鱻�Ե�ʱ������.nii/.img�ļ���4D�ļ���size=ndim1*ndim2*ndim3*nts
% ǰ����Ϊ�Ե�ά�ȣ���61*73*61��ntsΪʱ�����г��ȡ�
% output
% ZFC_dynamic �ļ�����Ϊÿ�����ԵĶ�̬�������ӣ�Fisher R to Z
% �任������sizeΪ��N_seed*T*N_voxel��
% N_seed=���ӵ������T=ʱ��������N_voxel=���صĸ�����
%% =========================����=================================
if nargin<3
    opt.mask=1;%�Ƿ��mask
    opt.static=0;%�Ƿ���㾲̬FC
    opt.dynamicFC=0;%�Ƿ񱣴����л������Ĺ�������,���ѡ�������ʱ
end
if nargin<2
    window_step=1;window_length=50;
end
%% =========================���Ŀ¼==============================
path_result= uigetdir({},'select result folder');
mkdir(path_result,'ZFC_dynamic_voxelwise');%�ڽ��·�����½��ļ��У�������Ž��
path_result=fullfile(path_result,filesep,'ZFC_dynamic_voxelwise');%�����ŵ��ļ���
mkdir(path_result,'ZFC_static');%�ڽ��·�����½��ļ��У�������Ų�ͬ�Ľ��
mkdir(path_result,'ZFC_dynamic');%�ڽ��·�����½��ļ��У�������Ų�ͬ�Ľ��
mkdir(path_result,'Std_ZFC_dynamic');%�ڽ��·�����½��ļ��У�������Ų�ͬ�Ľ��
path_result_static=fullfile(path_result,'ZFC_static');
path_result_dynamic=fullfile(path_result,'ZFC_dynamic');
path_result_Std_dynamic=fullfile(path_result,'Std_ZFC_dynamic');
%% =========================����Ŀ¼==============================
[path_source] = uigetdir({},'select data folder');
%% =========================load seed============================
% ts_seed=rand(230,1);
[seed_name,seed_source,~] = uigetfile({'*.img;*.nii;*.mat;','All Image Files';...
    '*.*','All Files'},'MultiSelect','on','select seed');
if iscell(seed_name)
    N_seed=length(seed_name);
    for no_seed=1:N_seed
        seed_strut=load_nii([seed_source,char(seed_name(no_seed))]);
        %     if no_mask==1;mask_temp=mask_strut.img;end;mask_size=size(mask_temp);%����mask��size
        seed(:,:,:,no_seed)=seed_strut.img;
    end
else
    N_seed=1;
    seed_strut=load_nii([seed_source,char(seed_name)]);
    seed=seed_strut.img;
end
seed=seed~=0;%����Ǹ������ӵ㣬��ô���������Ӧ�޸�
seed_1d=reshape(seed,size(seed,1)*size(seed,2)*size(seed,3),N_seed)';
%% =======================load mask==============================
%��������mask�����ڵõ�ģ�������һ��ȫmask
if opt.mask
    [mask_name,mask_source,~] = uigetfile({'*.img;*.nii;*.mat;','All Image Files';...
        '*.*','All Files'},'MultiSelect','off','select mask');
    mask_strut=load_nii([mask_source,char(mask_name)]);
    mask=mask_strut.img;
    mask=mask~=0;% תΪ�߼�����
    mask_1d=reshape(mask,1,size(mask,1)*size(mask,2)*size(mask,3));
end
%% =========================��������=============================
fid = fopen([path_result,filesep,'Parameters and settings.txt'],'a');
% add ===
fprintf(fid,'=========================================================\r\n');
% add time
fprintf(fid,[datestr(now,31) ,'\r\n']);
fprintf(fid,'window_step=%d\r\nwindow_length=%d\r\n',window_step,window_length);
fprintf(fid,'------------------\r\n');
% mask
if opt.mask
    fprintf(fid,'mask=%s\r\n',[mask_source char(mask_name)]);
else
    fprintf(fid,'not apply mask\r\n');
end
fprintf(fid,'------------------\r\n');
% seed
for ii=1:length(seed_name)
    fprintf(fid,['Seed',num2str(ii), ' is/are: %s\r\n'],char(seed_name(ii)));
end
fclose(fid);
%% =========================load nifti===========================
file_name=dir(path_source);
file_name={file_name.name};
file_name=file_name(3:end)';
%�ж�Fun*�����м����ļ����ֱ���
if iscell(file_name)
    n_sub=length(file_name);
    name_nii=dir([path_source,filesep,char(file_name(1))]);
    name_nii={name_nii.name};
    name_nii=name_nii(3:end);
    temp_nii=load_nii([path_source,filesep,char(file_name(1)),filesep,char(name_nii)]);
else
    n_sub=1;
    name_nii=dir([path_source,filesep,char(file_name)]);
    name_nii={name_nii.name};
    name_nii=name_nii(3:end);
    temp_nii=load_nii([path_source,filesep,char(file_name),filesep,char(name_nii)]);
end
[ndim1,ndim2,ndim3,nts]=size(temp_nii.img);%size
%Ĭ��mask
if ~opt.mask
    mask_1d=ones(1,ndim1*ndim2*ndim3);
end
%% =������load nii����ȡseed��ƽ��ʱ�����С���ROI��ʱ����������ز�����=
for i=1:n_sub
    if i<=5;tic;end;%����ǰ������ԵĴ���ʱ��
    fprintf(['The ',num2str(i),'th subject\n']);
    if iscell(file_name)
        % load nii
        strut_nii=load_nii([path_source,filesep,char(file_name(i)),filesep,char(name_nii)]);
        data_nii=strut_nii.img;
        % reshape data_nii
        data_nii=reshape(data_nii,ndim1*ndim2*ndim3,nts)';
        % extract seed region's mean timeseriers
        for no_ts_seed=1:N_seed
            ts_seed=data_nii(:,seed_1d(no_ts_seed,:));
            ts_seed_m(:,no_ts_seed)=mean(ts_seed,2);%ƽ��ʱ������
        end
        % apply mask, include seed
        data_nii=data_nii(:,mask_1d);
        % dynamic FC and static FC
        R_static=corr(ts_seed_m,data_nii);
        ZFC_static=0.5*log((1+R_static)./(1-R_static));%Fisher R-to-Z transformation
        ZFC_dynamic=DynamicFC(ts_seed_m,data_nii,window_step,window_length);%1�����ԣ�70000�����أ���2��maskԼ11��
        Std_ZFC_dynamic=std(ZFC_dynamic,0,3);%��ʱ�䴰��ά�����׼��
    else
        strut_nii=load_nii([path_source,filesep,char(file_name),filesep,char(name_nii)]);
        data_nii=strut_nii.img;
        data_nii=reshape(data_nii,ndim1*ndim2*ndim3,nts)';
        % extract seed region's mean timeseriers
        for no_ts_seed=1:N_seed
            ts_seed=data_nii(:,seed_1d(no_ts_seed,:));
            ts_seed_m(:,no_ts_seed)=mean(ts_seed,2);%ƽ��ʱ������
        end
        % apply mask, include seed
        data_nii=data_nii(:,mask_1d);
        % dynamic FC
        ZFC_dynamic=DynamicFC(ts_seed_m,data_nii,window_step,window_length);%1�����ԣ�70000�����أ���2��maskԼ11��
        Std_ZFC_dynamic=std(ZFC_dynamic,0,3);%��ʱ�䴰��ά�����׼��
    end
    fprintf(['The ',num2str(i),'th subject completed! and saving... \n']);
    %% save
    % �����ļ���
    if opt.dynamicFC; result_cmd_ZFC_dynamic=[ path_result_dynamic,filesep,file_name{i},'_ZFC_dynamic_voxelwise','.mat'];end
    result_cmd_Std_ZFC_dynamic=[ path_result_Std_dynamic,filesep,file_name{i},'_Std_ZFC_dynamic_voxelwise','.mat'];
    if opt.static; result_cmd_ZFC_static=[ path_result_static,filesep,filesep,file_name{i},'_ZFC_static_voxelwise','.mat']; end
    % ת��Ϊ3d����
    empt_std=zeros(N_seed,numel(mask_1d));
    if opt.dynamicFC; empt_dynamic=zeros(N_seed,numel(mask_1d),size(ZFC_dynamic,3)); end
    if opt.static; empt_static=zeros(N_seed,numel(mask_1d));end
    empt_std(:,mask_1d)=Std_ZFC_dynamic;
    if opt.dynamicFC; empt_dynamic(:,mask_1d,:)=ZFC_dynamic;end
    if opt.static; empt_static(:,mask_1d)=ZFC_static;end
    Std_ZFC_dynamic_3d=reshape(empt_std',ndim1,ndim2,ndim3,N_seed);%ע��˴���empt��Ҫת�ã���ΪMATLAB��Ĭ��˳���ǰ���һ��ά�ȡ�
    if opt.dynamicFC;ZFC_dynamic_3d = permute(empt_dynamic,[2 1 3]);end%3ά����ǰ2άת��
    if opt.dynamicFC;ZFC_dynamic_3d=reshape(empt_dynamic,ndim1,ndim2,ndim3,N_seed,size(empt_dynamic,3));end
    if opt.static; ZFC_static_3d=reshape(empt_static',ndim1,ndim2,ndim3,N_seed);end
    % save
    if opt.dynamicFC; save(result_cmd_ZFC_dynamic,'ZFC_dynamic_3d');end
    save( result_cmd_Std_ZFC_dynamic,'Std_ZFC_dynamic_3d');
    if opt.static; save(result_cmd_ZFC_static,'ZFC_static_3d'); end
    if i<=5;fprintf([ '��',num2str(i),'�����ԵĴ���ʱ��Ϊ�� ',num2str(toc),' ��\n']);end;%����ǰ������ԵĴ���ʱ��
end
fprintf(['All completed!\n']);
end