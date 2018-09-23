function DynamicFC_InterROI_LC(allSubjPath,pathResult,window_step,window_length)
% 计算一组被试的ROI wise的动态功能连接和了静态功能连接
% input：
%   allVolume：一组被试的时间序列矩阵，每一个被试的数据size为：T*N，T为时间点个数，N为ROI的个数
%   window_step,window_length：步长和宽
% output
%   ZFC_dynamic 文件夹下为每个被试的动态功能连接（Fisher R to Z
% 变换过），size=N*N*W，N为ROI个数，W为slide window 个数
%   ZFC_static 文件夹下为每个被试的静态功能连接（Fisher R to Z 变换过）
tic
%%===========================参数======================================================
if nargin<3
    window_step=1;
end
if nargin<4
    window_length=18;
end
%% =========================获得所有被试mat的路径=================================
if nargin<1
    allSubjPath='F:\Data\Results\ROISignals_FumImgARWSFC_mat';
    allSubjPath=dir(allSubjPath);
    folder={allSubjPath.folder};
    name={allSubjPath.name};
    allSubjPath=cell(length(name),1);
    for i =1:length(name)
        allSubjPath{i}=fullfile(folder{i},name{i});
    end
     allSubjPath= allSubjPath(3:end);
end
%% =========================结果目录==============================
if nargin<2
    pathResult='D:\myCodes\MVPA_LIChao\MVPA_MATLAB\DynamicFC';
end
% path_result= uigetdir({},'select result folder');
mkdir(pathResult,'DynamicFC');
pathResult=fullfile(pathResult,'DynamicFC');
mkdir(fullfile(pathResult,'zStaticFC'));
mkdir(fullfile(pathResult,'zDynamicFC'));
pathResult_dynamic=fullfile(pathResult,'zDynamicFC');
pathResult_static=fullfile(pathResult,'zStaticFC');

%% =====calculate both the static and dynamic Inter-ICN FC===========
%计算dynamic FC窗口个数
matPath=allSubjPath{1};
allVolume=importdata(matPath);
volume=size(allVolume,1);% dynamic FC parameters
window_end=window_length;
count=1;
while window_end <volume
    count=count+1;%计算多少个窗，即多少个动态矩阵,用来分配空间给ZFC_dynamic,从而加快速度
    window_end=window_end+window_step;
end

% calc dFC
fprintf('==================================\n');
fprintf(' Calculating dynamic FC\n');
nSubj=length(allSubjPath);
for s=1:nSubj
    fprintf('正在计算第%d/%d个被试...\n',s,nSubj);
    matPath=allSubjPath{s};
    allVolume=importdata(matPath);
    [zDynamicFC,zStaticFC]=DynamicFC_interROI_oneSubj(allVolume,window_step,window_length);
    %% =========================save============================
    [~,name,format]=fileparts(matPath);
    save([pathResult_dynamic,filesep,name,format],'zDynamicFC');
    save([pathResult_static,filesep,name,format],'zStaticFC');
end
fprintf('==================================\n');
fprintf('Dynamic FC calculating completed!\n');
toc
end

function [zDynamicFC,zStaticFC]=...
            DynamicFC_interROI_oneSubj(allVolume,window_step,window_length)
% 计算一个被试ROI wise的动态功能连接和静态功能连接
% input：
%   一个被试的时间序列矩阵allVolume，size为：T*N，T为时间点个数，N为ROI的个数
% output
%   zDynamicFC： 文件夹下为的动态功能连接（Fisher R to Z
%   变换过），size=N*N*W，N为ROI个数，W为slide window 个数
%   zStaticFC： 文件夹下为静态功能连接（Fisher R to Z 变换过）
%   stdOfZDynamicFC: 动态FC的标准差
%%
%计算dynamic FC窗口个数
window_end=window_length;
volume=size(allVolume,1);% dynamic FC parameters
nWindow=1;
while window_end <volume
    window_end=window_end+window_step;
    nWindow=nWindow+1;%计算多少个窗，即多少个动态矩阵,用来分配空间给ZFC_dynamic,从而加快速度
end

% allocate space
nRegion=size(allVolume,2);
% static FC
staticR=corrcoef(allVolume);
zStaticFC=0.5*log((1+staticR)./(1-staticR));%Fisher R-to-Z transformation
% dynamic FC
window_star=1;
window_end=window_length;%重置,初始化
count=1;
zDynamicFC=zeros(nRegion,nRegion,nWindow);
while window_end<=volume
    windowedTimecourse=allVolume(window_star:window_end,:);
    dynamicR=corrcoef(windowedTimecourse);
    zDynamicFC(:,:,count)=0.5*log((1+dynamicR)./(1-dynamicR));%Fisher R-to-Z transformation
    window_star=window_star+window_step;
    window_end=window_end+window_step;
    count=count+1;
end
% stdOfZDynamicFC=std(zDynamicFC,0,3);%求在滑动窗方向的标准差。
end