X=rand(10000,'single'); %������CPU�ϵ�һ��10x10�������ʼ������
   GX=gpuArray(X);      %��GPU��ʼ����GX�����ҽ�X��ֵ����GX
tic;GX2=GX.*GX;toc

tic;X.*X;toc


    [data_inmask]=gpuArray(data_inmask);
    [dataTest]=gpuArray(dataTest);