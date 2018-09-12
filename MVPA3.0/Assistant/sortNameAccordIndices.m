function nameSorted=sortNameAccordIndices(nameFirstModality,indiceCell,label,opt)
% ���ݽ�����֤��indices������������
% input:
%      nameFirstModality: ��һ��ģ̬�����б�������
%      indiceCell: ��������indices
%      opt:structure with follow fild:
%                   .permutation: 1 or 0
%                    .K:K-fold CV
%%
if nargin<4
    opt.permutation=1;
end
% reshape

%%
numOfGroup=numel(indiceCell);
labelUni=unique(label);
if ~opt.permutation
    %     nameSorted=cell(numel(label),1);
    nameSorted={};
    for i=1:numOfGroup
        ind=indiceCell{i};
        name={nameFirstModality{label==labelUni(i),:}}';
        for j=1:opt.K
            order=ind==j;
            nameSorted=vertcat(nameSorted,name(order));
        end
    end
else
    % �����û�����ʱ���������յ� name_all_sorted
    nameSorted=cell(numel(label),1);
end
end