for i =1:6
    state=importdata(['Cluster_',num2str(i),'.mat']);
    subplot(1,6,i)
    imagesc(state)
    colormap(jet)
    axis square
    axis off
end