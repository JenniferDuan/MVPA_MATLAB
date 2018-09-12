function indiceCell=generateIndiceForKfoldCV(label,K)
% Ϊ������֤����indices
% input:
%      label:���б��Եı�ǩ
%      K��number of K in K-fold cross-validation
% output:
%      indiceCell��1*numOfGroup cell matrix with each cell is a indices array of
%      each group. numOfGroup= the number of group
% Note that crossvalind�˴�����������ӵ���ƣ����ÿ�ν�����ǲ�һ����
%%
numOfGroup=numel(unique(label));
indiceCell=cell(1,numOfGroup);
uniLabel=unique(label);

for ith_group=1:numOfGroup
    LogicIndexOfTempLabel=label==uniLabel(ith_group);
    numOfSubjInOneGroup=sum(LogicIndexOfTempLabel);
    indices = crossvalind('Kfold', numOfSubjInOneGroup, K);
    indiceCell{1,ith_group}=indices ;
end

end