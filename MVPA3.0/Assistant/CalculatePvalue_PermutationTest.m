function [ P_value] = CalculatePvalue_PermutationTest( statistic, Null_hypothesis )
%�����û�����õ�����������ͳ�����ĵ�βPֵ
%   input��statistic =ͳ������
%   input��Null_hypothesis =����衣
P_value=(sum(Null_hypothesis>=statistic)+1)/(numel(Null_hypothesis)+1);
end

