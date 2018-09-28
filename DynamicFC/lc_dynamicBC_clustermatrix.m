function [save_dir,IDX_subjre]=lc_DynamicBC_clustermatrix(k,outputd,matname,subjdir,CluMet)
% k=8;
% subjdir='D:\WorkStation_2018\WorkStation_2018_08_Doctor_DynamicFC_Psychosis\DynamicFC18_1_screened\Dynamic\HC'
% outputd='D:\WorkStation_2018\WorkStation_2018_08_Doctor_DynamicFC_Psychosis\DynamicFC18_1_screened\Dynamic'
% CluMet='Correlation'
% matname='zDynamicFC'

evalstr = ['mats = ',matname,';'];
SubFold = dir(subjdir);
NumOfSubFold = size(SubFold,1)-2;
matrixall = [];
inums = 1;
for i = 1:30
    if isfile(fullfile(subjdir,SubFold(i+2).name))
        matsnames.name=fullfile(subjdir,SubFold(i+2).name);
        load(matsnames.name)
        eval(evalstr);
        nmats = length(mats);
        for imat = 1:nmats
            matrixs(:,imat) = reshape(mats(:,:,imat),numel(mats(:,:,imat)),1);
        end
        matrixs = full(matrixs);
        matrixall = [matrixall,matrixs];
        matrix_all{inums} = matrixs;
        subjlist{inums} = SubFold(i+2).name;
        inums = inums+1;
    end
end
dims = size(mats(:,:,imat));
%%

%%
matrixall(isinf(matrixall))=1;
fprintf('kmeans clustering for all windows of all subjects...\n');
[IDX,C,sumd,D] = kmeans(matrixall',k,'distance',CluMet);
save_dir = fullfile(outputd,['mat_',CluMet,'_Kmeans_',num2str(k)]);
mkdir(save_dir);
for i = 1:k
    indtemp = find(IDX==i);
    CIND_group{i,1} = indtemp;
    meanmaptemp = mean(matrixall(:,indtemp),2);
    DAT = reshape(meanmaptemp,dims(1),dims(2));
    save(fullfile(save_dir,['Cluster_',num2str(i),'.mat']),'DAT')
    DAT0(:,i) = mean(matrixall(:,indtemp),2);
end

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


% for isubj = 1:inums-1
%     for i = 1:k
%         dat1 = load(fullfile(save_dir,subjlist{isubj},['Cluster',num2str(i),'.mat']));
%         DAT1(:,i) = reshape(dat1.DAT,prod(dims),1);
%     end
%     DATrebuild{isubj,1} = DAT1;
% end
% % save test0001
% for i = 1:inums-1
%     perm_reb = perms(1:k);
%     for iperm = 1:size(perm_reb)
%         DATtemp = DATrebuild{i};
%         
%         [r, p] = corr(DAT0,DATtemp(:,perm_reb(iperm,:)));
%         R = diag(r);
%         Rtemp(iperm) = sum(R);
%     end
%     maxR = find(Rtemp==max(Rtemp));
%     maxperm{i} = perm_reb(maxR,:);
% end
% 
% for i = 1:inums-1
%     mkdir(fullfile(save_dir,['sorted',subjlist{i}]));
%     maxpermtemp = maxperm{i};
%     IDX0 = IDX_subj{i};
%     IDX01 = zeros(size(IDX0));
%     for j = 1:k
%         copyfile(fullfile(save_dir,subjlist{i},['Cluster',num2str(maxpermtemp(j)),'.mat']),...
%             fullfile(save_dir,['sorted',subjlist{i}],['Cluster_new',num2str(j),'_ori',num2str(maxpermtemp(j)),'.mat']));
%         IDX01(IDX0==maxpermtemp(j)) = j;
%     end
%     IDX_subjre{i} = IDX01;
% end
% cd(dirpwd);

