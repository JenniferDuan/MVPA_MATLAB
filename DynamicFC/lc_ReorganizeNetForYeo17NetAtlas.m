function reorgNet=lc_ReorganizeNetForYeo17NetAtlas(net)
% ��Yeo17����ģ������������ıߣ����ϵ����ڵ�������
%   net:һ���ԳƵ���ؾ���
%   netIndex:������ÿ���ڵ������index������Yeo��17����ģ���Ӧ��114����������ôÿ��������Ӧ��һ������
%   ��ô��Ӧ���Ǹ������index��Ϊ��index
%
%
%% fetch netIndex
% �Ժ�netIndex ʱ��ֱ��load
netIndex=importdata('D:\myCodes\Github_Related\Github_Code\Template_Yeo2011\netIndex.mat');
% sepIndex=[5,10,17,28,30,44,57,57+[5,10,17,28,30,44 57]];
% indexForNet=[0,sepIndex];
% netIndex=zeros(1,length(net));
% for i=1:length(sepIndex)
%     index=indexForNet(i)+1:indexForNet(i+1);
%     netIndex(index)=i;
% end
% %����57��������ǰ������ͬһ��������
% netIndex(58:end)=netIndex(1:57);
% save('netIndex.mat','netIndex')
%% reorganize net
[~,index]=sort(netIndex);
reorgNet=net(index,index);
end