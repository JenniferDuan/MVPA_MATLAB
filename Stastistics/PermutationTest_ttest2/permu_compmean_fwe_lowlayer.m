function permu_compmean_fwe_lowlayer(Nperm,cov,idt_colrow)
% ��;�����û�����ķ�ʽ����������ͳ�����Ĳ�ֵ�Ƿ���ͳ��ѧ���壬���������FWEУ����
% �ر�ע�⣺�˴���ʹ����GRETNA�еĲ��ִ��룬��ȥЭ���������������GRETNA����
% 2018��02��08�� By Lichao lichao19870617@gmail.com
%%
msgbox(['ע��:',char(10),'  1. ÿһ��ӦΪһ��ͳ������ÿһ��Ϊһ������!!!',...
    char(10),'  2. ������GRETNA']);
disp('Running=============================>>>')
tic
%% current path
currentFolder = pwd;
%%
if nargin<2
    Nperm=5000;
    cov='����Э����';
    idt_colrow='ÿһ��һ������';
end
%% ����ָ��Metrics
%load patients' data
[file_name_p,path_source_p,~] = uigetfile({'*.mat;*.txt','All Image Files';...
    '*.*','All Files'},'MultiSelect','off','��һ�������ļ�');
Variable1=importdata([path_source_p,char(file_name_p)]);
% load  controls' data
[file_name_c,path_source_c,~] = uigetfile({'*.mat;*.txt;','All Image Files';...
    '*.*','All Files'},'MultiSelect','off','�ڶ��������ļ�');
Variable2=importdata([path_source_c,char(file_name_c)]);
%
if  strcmp(idt_colrow,'ÿһ��һ������')
    Variable1=Variable1';Variable2=Variable2';
end
%% Э����
% ��һ��Э����
if strcmp(cov,'��Э����')
    [file_name_cov,path_source_cov,~] = uigetfile({'*.txt;*.mat','All Image Files';...
        '*.*','All Files'},'MultiSelect','off','��һ��ͳ������Э����');
    CovariateVariable1=importdata([path_source_cov,char(file_name_cov)]);
    
    % �ڶ���Э����
    [file_name_cov,path_source_cov,~] = uigetfile({'*.txt;*.mat','All Image Files';...
        '*.*','All Files'},'MultiSelect','off','�ڶ���ͳ������Э����');
    CovariateVariable2=importdata([path_source_cov,char(file_name_cov)]);
else
    CovariateVariable1=[];
    CovariateVariable2=[];
end
%% �û����� ������������ʹ��GRETNA�е�gretna_permutation_test

Para=[Variable1;Variable2];
Index_group1=1:size(Variable1,1);
Index_group2=1+size(Variable1,1):size(Variable1,1)+size(Variable2,1);
M=Nperm;
Cov=[CovariateVariable1;CovariateVariable2];
%
% NumOfSub=size(Para,1);
NumOfMetric=size(Para,2);
% Delta=cell(NumOfMetric,1);
pvalue=ones(NumOfMetric,1);
h1=waitbar(0,'��ȴ� Outer Loop>>>>>>>>');
for i=1:NumOfMetric
    waitbar(i/NumOfMetric,h1,sprintf('%2.0f%%', i/NumOfMetric*100)) ;
    if ~isempty(Cov)
        [~, pvalue(i)] = gretna_permutation_test...
            (Para(:,i), Index_group1, Index_group2, M, Cov);
    else
        [~, pvalue(i,1)] = gretna_permutation_test...
            (Para(:,i), Index_group1, Index_group2, M);
    end
end
close (h1)
sig=pvalue<0.05;
%% SAVE
% results path
time_lc=datestr(now,30);
path_outdir_tmp = uigetdir({},'������Ŀ¼');
mkdir([path_outdir_tmp filesep 'PermuFWE_',file_name_p(1:end-4),'VS',file_name_c(1:end-4),'_',time_lc]);
path_outdir=[path_outdir_tmp filesep 'PermuFWE_',file_name_p(1:end-4),'VS',file_name_c(1:end-4),'_',time_lc];
cd (path_outdir)
% save excel
% title
filename_ex = [file_name_p(1:end-4),'VS',file_name_c(1:end-4),'_PermuFWE.xlsx'];
data_ex = {'pvalue','sig'};
sheet = 1;
xlRange = 'A1';
xlswrite(filename_ex,data_ex,sheet,xlRange)
% data
data_ex=[pvalue,sig];
sheet = 1;
xlRange = 'A2';
xlswrite(filename_ex,data_ex,sheet,xlRange)
%save .mat
save([ file_name_p(1:end-4),'VS',file_name_c(1:end-4),'_PermuFWE.mat'],'pvalue','sig');
% Hint information
% msgbox(['��������: ',path_outdir,'results_permutation',time_lc,'.*']);
% back to current path
cd(currentFolder)
% finished
disp('Completed!')
end