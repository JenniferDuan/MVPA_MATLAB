for i =1:4
    file=['Cluster_',num2str(i),'.mat'];
    load(file);
    reorgNet=lc_ReorganizeNetForYeo17NetAtlas(squareMat);
    reorgNet(eye(114)==1)=1;
    subplot(2,2,i)
    lc_InsertSepLineToNet(reorgNet);
    colorbar
    axis off;
    axis square;
end
% set(gcf,'outerposition',get(0,'screensize'));
% set(gcf,'outerposition',get(0,'screensize'));
set(gcf,'Position',get(0,'ScreenSize'))
name=['BD_state'];
print(gcf,'-dtiff','-r300',name)