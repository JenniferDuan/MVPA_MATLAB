function  [p_static, p_dynamic]=StatisticalAnalysis_InterIC_LC(ZFC,id)
% ��������������Ӿ��󣨾�̬�붯̬�����ͳ�Ʒ�������
%ע�⣺�������ر��ʱ�����ã���Ϊ�ڴ���������ʱ����һ�����룺StatisticalAnalysis_InterROI_LC(
%input��
    % ZFC�������ľ�̬�Ͷ�̬�������Ӿ���
    % id������Ȥ�����id
% output��  
    % h_static/dynamic:��̬����̬��������ͳ�Ʒ������������
    % p_static/dynamic����̬����̬��������ͳ�Ʒ�����pֵ
% id=[9,19,20,22,24,26,28];%����Ȥ����
% idp=[33 34 36 37 38 39 41 43 46  50 57];
%% ��̬��������ͳ��
dp_static=ZFC_static(:,:,1:36);
dc_static=ZFC_static(:,:,37:end);
dp_static(isinf(dp_static))=1;
dc_static(isinf(dc_static))=1;
%
num_fc=size(dp_static,1);
for i=1:num_fc
    for j=1:num_fc
        stat_p=dp_static(i,j,:);stat_c=dc_static(i,j,:);
        [h_static(i,j),p_static(i,j)]=ttest2(stat_p(:),stat_c(:));
    end
end
%�����ǣ��������Խ��ߣ���������ȡ
mask_triu=ones(size(p_static));
mask_triu(tril(mask_triu)==1)=0;
p_static_triu=p_static(mask_triu==1);
%fdr correction
[p_fdr,h_fdr]=BAT_fdr(p_static_triu,0.05);
%let h_fdr back to matrix
h_back=zeros(size(p_static));
h_back(mask_triu==1)=h_fdr;
clear h_fdr;h_fdr=h_back;
% ����Ȥ�����Ľ��
% h_static=h_static(id,id);
% p_static=p_static(id,id);

%% ��̬��������ͳ��
%��׼��
std_dynamic=std(ZFC_dynamic,0,4);
dp_dynamic=std_dynamic(:,:,1:36);
dc_dynamic=std_dynamic(:,:,37:end);
dp_dynamic(isnan(dp_dynamic))=0;
dc_dynamic(isnan(dc_dynamic))=0;
%
num_fc=size(dp_dynamic,1);
for i=1:num_fc
    for j=1:num_fc
        stat_p=dp_dynamic(i,j,:);stat_c=dc_dynamic(i,j,:);
        [h_dynamic(i,j),p_dynamic(i,j)]=ttest2(stat_p(:),stat_c(:));
    end
end
% ����Ȥ�����Ľ��
% h_dynamic=h_dynamic(id,id);
p_dynamic=p_dynamic(id,id);
end