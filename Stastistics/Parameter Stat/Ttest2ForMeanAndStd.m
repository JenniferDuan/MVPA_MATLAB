function [t,p] = Ttest2ForMeanAndStd(mean1,std1,n1,mean2,std2,n2)
%���ݾ����ͱ�׼��������������t�����tֵ,�Լ�˫β��pֵ
%   input:����mean,��׼��std�Լ�������n
%   outpu: ����������t�����tֵ��pֵ
df=n1+n2-2;
numerator=mean1-mean2;
denominator=sqrt(((((n1-1)*(std1^2))+((n2-1)*(std2^2)))/df)*(1/n1+1/n2));
t=numerator/denominator;
p = 1-tcdf(abs(t),df);%single tail:right
p=2*p;%two-tail
end

