function dataOrigin=data2originIndex(indexSet,data,length_dataOrigin)
% usage����indexSetԪ����������index��Ӧ��dataͶ�䵽ԭʼdataOrigin��
% indexSet��ÿһ��cell�е�index������һ��index����ɸѡ��õ���index
% ���磺indexSet��2�㣨2��cell������1��indexΪ[3 4 5 6],��2��indexΪ[1 4]���ҵ�2���dataΪ[12 13],
% ���Ӧ��ԭʼ����dataOrigin��dataOrigin�ĵ�3�͵�6�����ݵ�=data���������ݵ�Ϊ0
% �˴������Ŀ���ǣ��ڽ���MVPAʱ����õ�����ɸѡ��������weight��Ϊ���γ�.niiͼ��
% ��Ҫ�Ѵ�weightͶ�䶼��ԭʼdata��ͬ��size�ռ��С�
% input��
%      indexSet: 1*N cell��ÿ��cell����һ��������index
%      length_dataOrigin:ԭʼ���ݵĳ���1*length_dataOrigin��������Զ�����һ��1��length_dataOrigin��0����
% output:
%     dataOrigin:��ײ�data��Ӧ��ԭʼ���ݺ�����ݣ�ע�⣺û�ж�Ӧ��index��������Ϊ0
%% ===============================================================
ind1=indexSet{end};
for i=numel(indexSet)-1:-1:1
    ind3=ind1;
    ind2=indexSet{i};
    ind1=ind2(ind3);
end
dataOrigin=zeros(1,length_dataOrigin);
dataOrigin(ind1)=data;
end