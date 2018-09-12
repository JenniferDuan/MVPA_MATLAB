function DynamicFC_InterROI_LC(window_step,window_length)
% 计算ROI wise的动态功能连接，也顺便计算了静态功能连接
% input：
% 一组被试的时间序列矩阵，每一个被试的数据size为：T*N，T为时间点个数，N为ROI的个数
% output
% ZFC_dynamic 文件夹下为每个被试的动态功能连接（Fisher R to Z
% 变换过），size=N*N*W，N为ROI个数，W为slide window 个数
% ZFC_static 文件夹下为每个被试的静态功能连接（Fisher R to Z 变换过）
tic
%% =========================参数=================================
if nargin<2
    window_step=1;
    window_length=50;
end
%% =========================结果目录==============================
path_result= uigetdir({},'select result folder');
mkdir(path_result,'ZFC_dynamic_InterROI');%在结果路径，新建文件夹，用来存放所有结果
path_result=fullfile(path_result,filesep,'ZFC_dynamic_InterROI');%结果存放的文件夹
mkdir(path_result,'ZFC_static');%在结果路径，新建文件夹，用来存放不同的结果
mkdir(path_result,'ZFC_dynamic');%在结果路径，新建文件夹，用来存放不同的结果
mkdir(path_result,'Std_ZFC_dynamic');%在结果路径，新建文件夹，用来存放不同的结果
path_result_static=fullfile(path_result,'ZFC_static');
path_result_dynamic=fullfile(path_result,'ZFC_dynamic');
path_result_Std_dynamic=fullfile(path_result,'Std_ZFC_dynamic');
%% ===========load all MAT files==========================
[file_name,path_source,~] = uigetfile({'*.mat;','All Image Files';...
    '*.*','All Files'},'MultiSelect','on','select ROI timeseriers');
if iscell(file_name)
    n_sub=length(file_name);
    mat_template=importdata([path_source,char(file_name(1))]);
else
    n_sub=1;
    mat_template=importdata([path_source,char(file_name)]);
end
mat=zeros(size(mat_template,1), size(mat_template,2),n_sub);
for i=1:n_sub
    if iscell(file_name)
        mat(:,:,i)=importdata([path_source,char(file_name(i))]);
    else
        mat(:,:,i)=importdata([path_source,char(file_name)]);
    end
end

fprintf('==================================\n');
fprintf('Load MAT files completed!\n');

%% =====calculate both the static and dynamic Inter-ICN FC===========
%计算dynamic FC窗口个数
window_star=1;volum=size(mat,1);% dynamic FC parameters
count=0;
while (window_star+window_length)<=volum
    count=count+1;%计算多少个窗，即多少个动态矩阵,用来分配空间给ZFC_dynamic,从而加快速度
    window_star=window_star+window_step;
end

% allocate space
FC_dynamic=zeros(268,268,count);
% timecourse_IC_dynamic=zeros(30,230,size(mat_all,3),200);
fprintf('==================================\n');
fprintf(' Calculating dynamic FC\n');
h = waitbar(0,'...');
for s=1:size(mat,3)
    timecourse_FC= mat(:,:,s);
    % static FC
    R_static=corrcoef( timecourse_FC);
    ZFC_static=0.5*log((1+R_static)./(1-R_static));%Fisher R-to-Z transformation
    %     ZFC_static(:,:,s)=Z_static(:,:);%Static zFC
    % dynamic FC
    window_star=1;window_end=window_length;%重置,初始化
    while window_end<=volum
        timecourse_IC_dynamic=timecourse_FC( window_star:window_end,:);
        R_dynamic=corrcoef(timecourse_IC_dynamic);
        FC_dynamic(:,:,window_star)=R_dynamic;%Static zFC
        window_star=window_star+window_step;
        window_end=window_end+window_step;
    end
    ZFC_dynamic=0.5*log((1+FC_dynamic)./(1-FC_dynamic));%Fisher R-to-Z transformation
    Std_ZFC_dynamic=std(ZFC_dynamic,0,3);%求在滑动窗方向的标准差。
    %% =========================save============================
    loc_name_star=find(file_name{s}=='_')+1;loc_name_end=find(file_name{s}=='.')-1;%定位名字对应的位置，相应修改***
    FC_path_static=[ path_result_static,filesep,filesep,file_name{s}( loc_name_star: loc_name_end),'.mat'];%结果存放路径
    FC_path_dynamic=[ path_result_dynamic,filesep,file_name{s}( loc_name_star: loc_name_end),'.mat'];%结果存放路径
    FC_path_Std_dynamic=[ path_result_Std_dynamic,filesep,file_name{s}( loc_name_star: loc_name_end),'.mat'];%结果存放路径
    save(FC_path_static,'ZFC_static');
    save(FC_path_dynamic,'ZFC_dynamic');
    save(FC_path_Std_dynamic,'Std_ZFC_dynamic');
    waitbar(s/size(mat,3),h,sprintf('%2.0f%%', s/size(mat,3)*100)) ;
end
close (h)
%
fprintf('==================================\n');
fprintf('dynamic FC calculating completed!\n');
toc
end