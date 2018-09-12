%�������Ĺ�������ͳ��(��λ��û��������Ҫ�޸�)
%% load
[file_name,path_source,~] = uigetfile({'*.mat;','All Image Files';...
    '*.*','All Files'},'MultiSelect','on','��һ�����');
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
%�ڶ���
[file_name,path_source,~] = uigetfile({'*.mat;','All Image Files';...
    '*.*','All Files'},'MultiSelect','on','�ڶ������');
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

% for ii=1:8
% ��ROI wise��static/dynamic FC ����ͳ�Ʒ���
%input��
% ZFC_*��ROI wise�ľ�̬�Ͷ�̬�������Ӿ���,size=N*N,NΪROI����
% ID_Mask������ȤROI��id,ȱʡ������е����ӽ���ͳ��
% output��
% h:��̬����̬��������ͳ�Ʒ������������
% p����̬����̬��������ͳ�Ʒ�����pֵ
%% ===========load all MAT files==========================
%��һ��
% ID_Mask=idd(idd(:,2)==ii);
ID_Mask=1:116;
%% ttest2 and fdr correction
% ��ȡID_Mask�ڵ�����
mat_p1=mat_p(ID_Mask,ID_Mask,:);
mat_c1=mat_c(ID_Mask,ID_Mask,:);
% Inf/NaN to 1 and 0
mat_p1(isinf(mat_p1))=1;
mat_c1(isinf(mat_c1))=1;
mat_p1(isnan(mat_p1))=0;
mat_c1(isnan(mat_c1))=0;
% ���edge�Ƚ�
num_fc=size(mat_p1,1);
for i=1:num_fc
    for j=1:num_fc
        stat_p=mat_p1(i,j,:);stat_c=mat_c1(i,j,:);
        [~,p(i,j)]=ttest2(stat_p(:),stat_c(:));
    end
end
% �����ǣ��������Խ��ߣ���������ȡ
mask_triu=ones(size(p));
mask_triu(tril(mask_triu)==1)=0;
p_static_triu=p(mask_triu==1);
P_mask=p;
P_mask(mask_triu==0)=1;
% fdr correction
% [p_fdr,h_fdr]=BAT_fdr(p_static_triu,0.05);
[Results] = multcomp_holm_bonferroni(p_static_triu, 'alpha', 0.05); 
h_fdr=Results.corrected_h;
p_fdr=Results.critical_alpha;
% let h_fdr back to matrix
h_back=zeros(size(p));
h_back(mask_triu==1)=h_fdr;
clear h_fdr 
h_fdr=h_back;
clear h_back;
%��λ����Ӧ������
path_label_network=['J:\lichao\MATLAB_Code\Github_Code\connectome-based predictive modeling\Atlas\shen_268_parcellation_networklabels.csv'];
label_network=xlsread(path_label_network);
[I,J]=find(P_mask<=p_fdr);%I��JΪ��ͳ��ѧ�����������λ��
area_row=ismember(label_network(:,1),I);
area_colum=ismember(label_network(:,1),J);
label_network_2=label_network(:,2);
network_row=label_network_2(area_row);%��Ӧ�����磨�У�
network_colum=label_network_2(area_colum);%��Ӧ�����磨�У�

fprintf('==================================\n');
fprintf('Completed\n');
%%
% minp=min(p(:));
% cout=numel(ID_Mask);
% fwe=Results.critical_alpha;
% fprintf('=======\nmin p = %6.5f\nfwe p = %6.5f\n',minp,fwe)
% find(h_fdr==1)
% % end
%%
