function [F,P]=featureSelection_ANOCOVA(data,label, Covariates)
% usage: ����ANOCOVA��������ɸѡ��֧��ȥ��Э������
% input��
%        data��2D matrix��with dimension 1 is number of subjects��dimension 2
%        is number of features
%        label��1D array
%        Covariates��2D matrix��with dimension 1 is number of subjects��dimension 2
%        is number of Covariates
% output��
%        F: F statistics,
%        P: P values;
%        *:���б�Ҫ����������������������beta ��
%% preallocate

%%
uniLabel=unique(label);
DependentFiles=cell(1,numel(uniLabel));
for i=1:numel(uniLabel)
    DependentFiles{1,i}=data(label==uniLabel(i),:);
end
[F, P] = My_gretna_ANCOVA1({rand(100,67541),rand(40,67541),rand(50,67541)},[]);
[F, P] = My_gretna_ANCOVA1(DependentFiles, Covariates);% ʹ��GRETNA�Ĵ��룬ע��Ҫ���á�
end