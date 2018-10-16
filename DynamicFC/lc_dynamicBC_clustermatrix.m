function [save_dir,IDX_subjre]=lc_DynamicBC_clustermatrix()
k=4;
subjdir='D:\WorkStation_2018\WorkStation_2018_08_Doctor_DynamicFC_Psychosis\Data\DynamicFC17_1_screened\Dynamic\HC'
outputd='D:\WorkStation_2018\WorkStation_2018_08_Doctor_DynamicFC_Psychosis\Data\DynamicFC17_1_screened\Dynamic\state4_HC'
CluMet='cityblock'
matname='zDynamicFC'
subFold = dir(subjdir);
nSubj = size(subFold,1)-2;
% pre-allocating space
filaName=fullfile(subjdir,subFold(3).name);
dynamicMats=importdata(filaName);
nNode=size(dynamicMats,1);
nWindow = length(dynamicMats);
upMatMask=triu(ones(nNode,nNode),1)==1;%上三角矩阵mask
nFeature=sum(upMatMask(:));
tmpMat=zeros(nFeature,nWindow);
allMatrix = zeros(nFeature,nWindow,nSubj);
for i = 1:nSubj
    fprintf('load %dth dynamic matrix to all matrix\n',i);
    if isfile(fullfile(subjdir,subFold(i+2).name))
        filaName=fullfile(subjdir,subFold(i+2).name);
        dynamicMats=importdata(filaName);
        % 注意：为了节约计算成本，我只提取每一个FC的上三角矩阵
        % 由于对角线没有聚类功能，因此不包括对角线
        for imat = 1:nWindow
            upMat=dynamicMats(:,:,imat);
            upMat=upMat(upMatMask);
            tmpMat(:,imat)=upMat;
        end
%         tmpMat = full(tmpMat);
        allMatrix(:,:,i) = tmpMat;
    end
end
fprintf('======loaded all mat!======\n')
%% kmeans
fprintf('kmeans clustering for all windows of all subjects...\n');
allMatrix(isinf(allMatrix))=1;
allMatrix(isnan(allMatrix))=0;
allMatrix=reshape(allMatrix,nFeature,nWindow*nSubj)';
[IDX,C,sumd,D] = kmeans(allMatrix,k,'distance',CluMet);
% opts = statset('Display','final');
% [Idx,C,sumD,~] = kmeans(allMatrix(1:10000,:),k,'Distance',distanceMethod,...
%     'Replicates',5,'Options',opts);
save_dir = fullfile(outputd,['mat_',CluMet,'_Kmeans_',num2str(k)]);
mkdir(save_dir);
for i = 1:k
    ind = find(IDX==i);
    tmpMat=allMatrix(ind,:);   
    meanMat = mean(tmpMat,1);
    squareMat=eye(nNode);
    squareMat(upMatMask)=meanMat;
    squareMat=squareMat+squareMat';
    squareMat(eye(nNode)==1)=1;
    save(fullfile(save_dir,['Cluster_',num2str(i),'.mat']),'squareMat')
end
% save IDX
save(fullfile(save_dir,'IDX.mat'),'IDX');
fprintf('============Done!============\n');
%%



% for isubj = 1:inums-1
%     DATUSED = matrix_all{isubj};
%
%     [IDX,C,sumd,D] = kmeans(DATUSED',k,'distance',CluMet);
%     mkdir(fullfile(save_dir,subjlist{isubj}));
%     for i = 1:k
%         indtemp = find(IDX==i);
%         meanmaptemp = mean(DATUSED(:,indtemp),2);
%         DAT = reshape(meanmaptemp,dims(1),dims(2));
%         save(fullfile(save_dir,subjlist{isubj},['Cluster',num2str(i),'.mat']),'DAT')
%     end
%     IDX_subj{isubj} = IDX;
% end
end

