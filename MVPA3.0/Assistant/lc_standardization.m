function [standardizedTrainData,standardizedTestData]=...
                             lc_standardization(trainingData,testData,standardizationMethod)
% ���ݵı�׼��
% ʹ��GPU�����ӿ��ٶȡ�2018-04-30 By Li Chao
if nargin<3
    standardizationMethod='scale';
end
%%
% normalizing
if strcmp(standardizationMethod,'normalizing')
    MeanValue = mean(trainingData);
    StandardDeviation = std(trainingData);
    [row_quantity, columns_quantity] = size(trainingData);
    train_data_temp=zeros(row_quantity, columns_quantity);
    
    for ii = 1:columns_quantity
        if StandardDeviation(ii)
            train_data_temp(:, ii) = (trainingData(:, ii) - MeanValue(ii)) / StandardDeviation(ii);
        end
    end
    test_data_temp = (testData - MeanValue) ./ StandardDeviation;
    standardizedTrainData=train_data_temp;standardizedTestData=test_data_temp;
end
% scale: ���з����һ��
if strcmp(standardizationMethod,'scale')
    [train_data_temp,PS] = mapminmax(trainingData',-1,1);
    train_data_temp=train_data_temp';
    test_data_temp = mapminmax('apply',testData',PS);
    test_data_temp =test_data_temp';
    standardizedTrainData=train_data_temp;
    standardizedTestData=test_data_temp;
end
end