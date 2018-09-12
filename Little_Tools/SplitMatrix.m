function SplitMatrix(allMatrixPath,resultsPath)
% �����ļ�
if nargin<1
    [file_name,filepath,~] = uigetfile({'*.mat;*.txt;','All Files';...
        '*.*','All Files'},'MultiSelect','on','��ѡ��������');
end
% �������·��
if nargin <2
    resultsPath=uigetdir({},'��ѡ���������ļ���');
end
% if exist('wholeMatrixPath','var')
% end
%%
if ~iscell(file_name)
    matrix=importdata(fullfile(filepath,file_name));
else
    matrix=importdata(fullfile(filepath,file_name{1}));
end
ROISize =length(matrix);%%%change "matrix" acording to your data;
HROISize =ROISize./2;
LHname = [resultsPath '\LH\'];
RHname = [resultsPath '\RH\'];
system(['mkdir ' LHname]);
system(['mkdir ' RHname]);
%
h=waitbar(0,'��ȴ�>>>>>>>>');
if iscell(file_name)
    for i =1:length(file_name)
        waitbar(i/length(file_name),h,sprintf('%2.0f%%', i/length(file_name)*100)) ;
        matrix=importdata(fullfile(filepath,file_name{i}));
        hematrixL=matrix(1:2:ROISize,1:2:ROISize);
        hematrixR=matrix(2:2:ROISize,2:2:ROISize);
        subnameL = [LHname '\', file_name{i}(1:end-4),'.txt'];
        subnameR = [RHname '\', file_name{i}(1:end-4),'.txt'];
        dlmwrite(subnameL,hematrixL);
        dlmwrite(subnameR,hematrixR);
    end
else
    matrix=importdata(fullfile(filepath,file_name));
    hematrixL=matrix(1:2:ROISize,1:2:ROISize);
    hematrixR=matrix(2:2:ROISize,2:2:ROISize);
    subnameL = [LHname '\', file_name(1:end-4),'.txt'];
    subnameR = [RHname '\', file_name(1:end-4),'.txt'];
    dlmwrite(subnameL,hematrixL);
    dlmwrite(subnameR,hematrixR);
end
close(h);
end