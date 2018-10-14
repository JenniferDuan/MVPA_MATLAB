function lc_InsertSepLineToNet(reorgNet)
% �˴���Ĺ��ܣ���һ����������ֲ�������ָ��ߣ��˷ָ��߽���ͬ��������ֿ�
% input
%   net:һ���������N*N,NΪ�ڵ����������Ϊ�Գƾ���
%   sepIndex:�ָ��ߵ�index��Ϊһ������������[3,9]��ʾ����ָ��߷ֱ�λ��3��9����

%% input
%     sepIndex=2*[0,5,10,17,28,30,44,57];% Yeo17 net atals
sepIndex=importdata('D:\myCodes\Github_Related\Github_Code\Template_Yeo2011\sepIndex.mat');
if size(reorgNet,1)~=size(reorgNet,2)
    error('���ǶԳƾ���');
end
%%
% figure
imagesc(reorgNet)
% insert separate line
lc_line(sepIndex,length(reorgNet))
colormap(jet)
axis off
end

function lc_line(sepIndex,nNode)
% nNode:node����
for i=1:length(sepIndex)
    line([sepIndex(i)+0.5,sepIndex(i)+0.5],[-10,nNode*2],'color','w','LineWidth',1)
    line([0,nNode*2],[sepIndex(i)+0.5,sepIndex(i)+0.5],'color','w','LineWidth',1)
end
end