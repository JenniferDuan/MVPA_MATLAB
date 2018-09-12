% ���������Ե�ƫ�໯ϵ��coef=(L-R)/(L+R)
%% input
% Left
[file_name_L,filepath,~] = uigetfile({'*.mat;*.txt;','All Files';...
    '*.*','All Files'},'MultiSelect','off','ѡ���������');
matrix_L=importdata(fullfile(filepath,file_name_L));
% Right
[file_name_R,filepath,~] = uigetfile({'*.mat;*.txt;','All Files';...
    '*.*','All Files'},'MultiSelect','off','ѡ���Ҳ�����');
matrix_R=importdata(fullfile(filepath,file_name_R));
% result folder
resultsPath=uigetdir({},'��ѡ�����ļ���');
% cacl
coef=(matrix_L-matrix_R)./(matrix_L+matrix_R);

% save to excel
sheet = 1;
xlRange = 'A1';
xlswrite([resultsPath,'\',file_name_L(1:end-4),'_VS',file_name_R(1:end-4),'.xlsx'],coef,sheet,xlRange)
