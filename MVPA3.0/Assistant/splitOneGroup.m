function [Train_data,Test_data,Train_label,Test_label]=splitOneGroup(data,label,indices,i)
% 根据indices，将一个组的data和label分成训练集和测试集
Test_index = (indices == i); 
Train_index = ~Test_index;
Test_data =data(Test_index,:);
Train_data =data(Train_index,:);
Test_label=label(Test_index,:);
Train_label=label(Train_index,:);
end