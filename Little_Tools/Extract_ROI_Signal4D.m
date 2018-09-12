function [ Signal] = Extract_ROI_Signal4D(numOfVolume)
% usage: extract multiple signals from 3D or 4D data. If 4D data, the dimension 4 is the volume/time point
% input:
%     data:5D data, dimension 4 is volume/time point,dimension 5 is the number of subjects;
%     mask:3D logic matrix, equal to a volume.
%     numOfVolume= number of volume
% output:
%     signals: N*M, N=number of subjects, M=number of volume/time points.
%% path to save results
pathOfResult=uigetdir({},'ѡ��������·��');
mkdir(pathOfResult,'Signals');
pathOfSignal=fullfile(pathOfResult,'Signals');
%% mask
[nameOfMask,pathOfMaks,~] = uigetfile({'*.nii;*.img;','All Image Files';...
    '*.*','All Files'},'MultiSelect','off','ѡ��mask');
fullNameOfMask=fullfile(pathOfMaks,nameOfMask);
mask=load_nii(fullNameOfMask);
mask=mask.img;
mask=mask~=0;
%% extract signal
dirContainAllSubj=uigetdir({},'ѡ�����б��Ե�4D .img/.nii �ļ������ļ���');
dirOfAllSubj=dir(dirContainAllSubj);
nameOfAllSubj={dirOfAllSubj.name};
nameOfAllSubj=nameOfAllSubj(3:end)';
pathOfAllSubj=fullfile(dirContainAllSubj,nameOfAllSubj);
numOfSubj=length(pathOfAllSubj);
% preallocate
Signal=zeros(numOfSubj,numOfVolume);
% extract signal according subject's order
for i=1:numOfSubj
    if mod(i,10)==0
        fprintf('%.0f%%\n',i*100/numOfSubj);
    else
        fprintf('%.0f%%\t',i*100/numOfSubj);
    end
    imgName=dir(pathOfAllSubj{i});
    imgName={imgName.name};
    imgName=imgName(3:end)';
    pathOfImgName=fullfile(pathOfAllSubj{i},imgName);
    dataStrut=load_nii(char(pathOfImgName));
    data=dataStrut.img;
    signal=extractROISignal(data,mask,'mean');
    Signal(i,:) = signal;
    % save
    save([pathOfSignal,filesep,nameOfAllSubj{i},'.mat'],'signal');
end
%% save all signal
save([pathOfSignal,filesep,'signalAllSubj_From_',nameOfMask,'.mat'],'Signal');
fprintf('\n===============Completed!===================\n');
end

