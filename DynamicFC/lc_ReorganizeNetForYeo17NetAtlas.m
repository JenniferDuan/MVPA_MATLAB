function reorgNet=lc_ReorganizeNetForYeo17NetAtlas(net)
% 将Yeo17网络模板分离的脑网络的边，整合到相邻的网络内
%   net:一个对称的相关矩阵
%   netIndex:网络中每个节点的网络index，例如Yeo的17网络模板对应由114个脑区，那么每个脑区对应到一个网络
%   那么对应的那个网络的index即为此index
%
%
%% fetch netIndex
% 以后netIndex 时，直接load
netIndex=importdata('D:\myCodes\Github_Related\Github_Code\Template_Yeo2011\netIndex.mat');
% sepIndex=[5,10,17,28,30,44,57,57+[5,10,17,28,30,44 57]];
% indexForNet=[0,sepIndex];
% netIndex=zeros(1,length(net));
% for i=1:length(sepIndex)
%     index=indexForNet(i)+1:indexForNet(i+1);
%     netIndex(index)=i;
% end
% %后面57个脑区跟前面属于同一个个网络
% netIndex(58:end)=netIndex(1:57);
% save('netIndex.mat','netIndex')
%% reorganize net
[~,index]=sort(netIndex);
reorgNet=net(index,index);
end