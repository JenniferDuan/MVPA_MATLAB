function [AUC]=AUC_LC(RealLabel,Pred)  
%����AUCֵ,RealLabelΪԭʼ������ǩ,PredΪ�������õ��ı�ǩ  
RealLabel=reshape(RealLabel,length(RealLabel),1);Pred=reshape(Pred,length(Pred),1);%ת��Ϊ�л�������  
RealLabel=RealLabel==1;%����1��Ϊ0.
[~,I]=sort(Pred);  
M=0;N=0;  
for i=1:length(Pred)  
    if(RealLabel(i)==1)  
        M=M+1;  
    else  
        N=N+1;  
    end  
end  
sigma=0;  
for i=M+N:-1:1  
    if(RealLabel(I(i))==1)  
        sigma=sigma+i;  
    end  
end  
AUC=(sigma-(M+1)*M/2)/(M*N); 
end

