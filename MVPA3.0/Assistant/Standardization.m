function [S_train_data,S_test_data]=...
    Standardization(dataTrain,dataTest,opt)
% 数据的标准化
% 使用GPU处理，加快速度。2018-04-30 By Li Chao
if nargin<3
    opt.standardizationMethod='normalizing';
    opt.gpu=0;
end
%%
% normalizing
if strcmp(opt.standardizationMethod,'normalizing')
    MeanValue = mean(dataTrain);
    StandardDeviation = std(dataTrain);
    [row_quantity, columns_quantity] = size(dataTrain);
    if opt.gpu==1
        train_data_temp=zeros(row_quantity, columns_quantity,'gpuArray');
    end
    
    for ii = 1:columns_quantity
        if StandardDeviation(ii)
            train_data_temp(:, ii) = (dataTrain(:, ii) - MeanValue(ii)) / StandardDeviation(ii);
        end
    end
    test_data_temp = (dataTest - MeanValue) ./ StandardDeviation;
    S_train_data=train_data_temp;S_test_data=test_data_temp;
end
% scale
if strcmp(opt.standardizationMethod,'scale')
    [train_data_temp,PS] = mapminmax(dataTrain');
    train_data_temp=train_data_temp';
    test_data_temp = mapminmax('apply',dataTest',PS);
    test_data_temp =test_data_temp';
    S_train_data=train_data_temp;
    S_test_data=test_data_temp;
end
end