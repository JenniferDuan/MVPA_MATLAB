function meanBrainWeight=AverageWeightMap(brainWeight,percentage_consensus)
% ������K-fold CV�������weight����ƽ��������K-fold CV�е���ĳ������Ƶ�ʵ�weight��Ϊ0��
% input:
%    brainWeight: 3D matrix. Dimension 1 is equal to the number of feature subsets
%    Dimension 2 is equal to the number of voxels
%    Dimension 3 is equal to the number of K(K-fold)
%    percentage_consensus��K-fold CV�г��ֵ�Ƶ����ֵ��<percentage_consensus�Ļ���Ϊ0
% output
%    meanBrainWeight������Ƶ��ɸѡ��ƽ��weight��2D matrix with dimension 1is equal to
%    the number of feature subsets�� dimension 2 is equal to the number of voxels
%% 
[~,~,dim3]=size(brainWeight);
    binary_mask=brainWeight~=0;
    sum_binary_mask=sum(binary_mask,3);
    loc_consensus=sum_binary_mask>=percentage_consensus*dim3; 
%     num_consensus=sum(loc_consensus,2)';%location and number of consensus weight
    meanBrainWeight=mean(brainWeight,3);%ȡ����fold�� W_Brain��ƽ��ֵ
    meanBrainWeight(~loc_consensus)=0;%set weights located in the no consensus location to zero.
end