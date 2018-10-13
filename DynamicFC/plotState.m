sepIndex=importdata('D:\myCodes\Github_Related\Github_Code\Template_Yeo2011\sepIndex.mat');
for i =1:5
    state=importdata(['Cluster_',num2str(i),'.mat']);
%     subplot(1,5,i)
    reorgNet=lc_ReorganizeNetForYeo17NetAtlas(state);
    figure
    lc_InsertSepLineToNet(reorgNet,sepIndex)
    axis square
    axis off
end