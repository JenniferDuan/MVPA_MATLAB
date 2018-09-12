function AUC=AUC_LC(Real_label,preds)  
%����AUCֵ(area under roc curve),
%input:Real_labelΪԭʼ������ǩ,predsΪ�������õ��ı�ǩ  
Real_label=reshape(Real_label,length(Real_label),1);
preds=reshape(preds,length(preds),1);%ת��������  
Real_label=Real_label==1;%����1��Ϊ0.
%%
[~,I]=sort(preds);  
M=0;N=0;  
for i=1:length(preds)  
    if(Real_label(i)==1)  
        M=M+1;  
    else  
        N=N+1;  
    end  
end  
sigma=0;  
for i=M+N:-1:1  
    if(Real_label(I(i))==1)  
        sigma=sigma+i;  
    end  
end  
AUC=(sigma-(M+1)*M/2)/(M*N); 
end

