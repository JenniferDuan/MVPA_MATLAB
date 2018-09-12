function [label_net] = template2Network(brain_parcellation,network)
% ��ĳ���Է���ģ��ĸ�������ӳ�䵽��Ӧ��������ģ���ϣ����������ص���������
% ���巽����ο�{Chronnectome fingerprinting: Identifying individuals and
% predicting higher cognitive functions using dynamic brain connectivity patterns}
%   input:
%       brain_parcellation:�Է�������
%       network_parcellation:�����������
%   output:
%       network_label:����������Ӧ������label
%%
uni_region=unique(brain_parcellation);
%     sparse(brain_parcellation)
n_region=numel(uni_region);
prop=cell(n_region,1);
uni_net=cell(n_region,1);
label_net=zeros(n_region,1);
for i =1:n_region
    fprintf('%d/%d\n',i,n_region)
    oneBrain_parcellation=brain_parcellation==uni_region(i);
    [prop{i,1},uni_net{i,1}]=oneTemp2Net(oneBrain_parcellation,network);
    loc_max_prop=find(prop{i,1}==max(prop{i,1}));
    if ~isempty(loc_max_prop)
        loc_max_prop=loc_max_prop(1);
        label_net(i)=uni_net{i,1}(loc_max_prop);
    else
        label_net(i)=0;
    end
end
end





