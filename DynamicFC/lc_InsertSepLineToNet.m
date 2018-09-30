function lc_InsertSepLineToNet(net,sepIndex)
% �˴���Ĺ��ܣ���һ����������ֲ�������ָ��ߣ��˷ָ��߽���ͬ��������ֿ�
% input
%   net:һ���������N*N,NΪ�ڵ����������Ϊ�Գƾ���
%   sepIndex:�ָ��ߵ�index��Ϊһ������������[3,9]��ʾ����ָ��߷ֱ�λ��3��9����

%% input
if nargin<1
    net=importdata('D:\WorkStation_2018\WorkStation_2018_08_Doctor_DynamicFC_Psychosis\DynamicFC18_1_screened\Dynamic\mat_Correlation_Kmeans_8\Cluster_8.mat');
%     sepIndex=2*[0,5,10,17,28,30,44,57];% Yeo17 net atals
    sepIndex=importdata('D:\myCodes\Github_Related\Github_Code\Template_Yeo2011\sepIndex.mat');
    if size(net,1)~=size(net,2)
        error('���ǶԳƾ���');
    end
end
%%
% figure
imagesc(net)
% insert separate line
lc_line(sepIndex,length(net))
colormap(jet)
axis off
end

function lc_line(sepIndex,nNode)
% nNode:node����
for i=1:length(sepIndex)
    line([sepIndex(i)+0.5,sepIndex(i)+0.5],[-10,nNode*2],'color','k','LineWidth',1)
    line([0,nNode*2],[sepIndex(i)+0.5,sepIndex(i)+0.5],'color','k','LineWidth',1)
end
end