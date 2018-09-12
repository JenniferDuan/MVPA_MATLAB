function  [p, h_fdr]=StatisticalAnalysis_InterROI_LC(ID_Mask)
% 对ROI wise的static/dynamic FC 进行统计分析
%input：
% ZFC_*：ROI wise的静态和动态功能连接矩阵,size=N*N,N为ROI个数
% ID_Mask：感兴趣ROI的id,缺省则对所有的连接进行统计
% output：
% h:静态及动态功能连接统计分析的显著情况
% p：静态及动态功能连接统计分析的p值
%% ===========load all MAT files==========================
%第一组
[file_name,path_source,~] = uigetfile({'*.mat;','All Image Files';...
    '*.*','All Files'},'MultiSelect','on','第一组变量');
if iscell(file_name)
    n_sub=length(file_name);
    mat_template=importdata([path_source,char(file_name(1))]);
else
    n_sub=1;
    mat_template=importdata([path_source,char(file_name)]);
end
mat_p=zeros(size(mat_template,1), size(mat_template,2),n_sub);
for i=1:n_sub
    if iscell(file_name)
        mat_p(:,:,i)=importdata([path_source,char(file_name(i))]);
    else
        mat_p(:,:,i)=importdata([path_source,char(file_name)]);
    end
end
%第二组
[file_name,path_source,~] = uigetfile({'*.mat;','All Image Files';...
    '*.*','All Files'},'MultiSelect','on','第二组变量');
if iscell(file_name)
    n_sub=length(file_name);
    mat_template=importdata([path_source,char(file_name(1))]);
else
    n_sub=1;
    mat_template=importdata([path_source,char(file_name)]);
end
mat_c=zeros(size(mat_template,1), size(mat_template,2),n_sub);
for i=1:n_sub
    if iscell(file_name)
        mat_c(:,:,i)=importdata([path_source,char(file_name(i))]);
    else
        mat_c(:,:,i)=importdata([path_source,char(file_name)]);
    end
end
fprintf('==================================\n');
fprintf('Load MAT files\n');
%%
% 默认的ID_Mask
if nargin<1
    ID_Mask=1:size(mat_c,1);
end
%% ttest2 and fdr correction
% 提取ID_Mask内的连接
mat_p=mat_p(ID_Mask,ID_Mask,:);
mat_c=mat_c(ID_Mask,ID_Mask,:);
% Inf/NaN to 1 and 0
mat_p(isinf(mat_p))=1;
mat_c(isinf(mat_c))=1;
mat_p(isnan(mat_p))=0;
mat_c(isnan(mat_c))=0;
% 逐个edge比较
num_fc=size(mat_p,1);
for i=1:num_fc
    for j=1:num_fc
        stat_p=mat_p(i,j,:);stat_c=mat_c(i,j,:);
        [h_static(i,j),p(i,j)]=ttest2(stat_p(:),stat_c(:));
    end
end
% 上三角（不包括对角线）的数据提取
mask_triu=ones(size(p));
mask_triu(tril(mask_triu)==1)=0;
p_static_triu=p(mask_triu==1);
% fdr correction
[p_fdr,h_fdr]=BAT_fdr(p_static_triu,0.05);
% let h_fdr back to matrix
h_back=zeros(size(p));
h_back(mask_triu==1)=h_fdr;
clear h_fdr 
h_fdr=h_back;
clear h_back;
fprintf('==================================\n');
fprintf('Completed\n');
end