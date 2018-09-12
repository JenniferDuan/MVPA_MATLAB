% ��;����excel�е�����˳����ID��Ӧ
% input��
    % excel����е����ݣ��ٴ����ϡ�����ȣ�
    % ID=���Ե�ID���룬�������κ�һ�����Ժͱ���Ψһƥ���������
% output��
    % Locmember_*=ÿ��������excel�е�λ��
%% ===========================Read Excel==========================
[DataExcel_GAD,DataExcel_GAD_Str,DataExcel_GAD_Raw]=xlsread('GAD���ݲɼ������� .xls',4);
[DataExcel_HC,DataExcel_HC_Str,DataExcel_HC_Raw]=xlsread('GAD���ݲɼ������� .xls',5);
%% =========================Import ID data========================
ID_GADok=importdata('ID_GADok.mat');
ID_GADnotok=importdata('ID_GADnotok.mat');
ID_HC=importdata('ID_HC.mat');
%% =========================Cell to string========================
ID_GADok=cellstr(ID_GADok);
ID_GADnotok=cellstr(ID_GADnotok);
ID_HC=cellstr(ID_HC);
%% ========================String to double=======================
ID_GADok=cellfun(@str2double,ID_GADok,'UniformOutput',1);
ID_GADnotok=cellfun(@str2double,ID_GADnotok,'UniformOutput',1);
ID_HC=cellfun(@str2double,ID_HC,'UniformOutput',1);
%% =======================Locate the id===========================
[IFmember_GADok,Locmember_GADok]=ismember(ID_GADok,DataExcel_GAD(:,1));
[IFmember_GADnotok,Locmember_GADnotok]=ismember(ID_GADnotok,DataExcel_GAD(:,1));
[IFmember_HC,Locmember_HC]=ismember(ID_HC,DataExcel_HC(:,3));

%% ===================Acquir demographic data=====================
Data_GAD_Dem=DataExcel_GAD_Raw(2:end,[7,8,9,13]);
Data_HC_Dem=DataExcel_HC_Raw(2:end,[7,8,11]);
%Age and Edu
MyCell2double=@(x) x(1:end-1);
Data_GAD_AgeEdu=cellfun(MyCell2double,Data_GAD_Dem(:,2:end),'UniformOutput',0);
Data_GAD_AgeEdu(:,3)=cellfun(MyCell2double,Data_GAD_AgeEdu(:,3),'UniformOutput',0);
Data_GAD_AgeEdu=cellfun(@str2double,Data_GAD_AgeEdu(1:46,:), 'UniformOutput',0);
Data_GAD_AgeEdu=cell2mat(Data_GAD_AgeEdu);
Data_HC_AgeEdu=cellfun(MyCell2double,Data_HC_Dem(1:20,2:end),'UniformOutput',0);
Data_HC_AgeEdu=[Data_HC_AgeEdu;Data_HC_Dem(21:end,2:3)];
Data_HC_AgeEdu_low=cellfun(@double,Data_HC_AgeEdu(21:end,:), 'UniformOutput',0);
Data_HC_AgeEdu_up=cellfun(@str2double,Data_HC_AgeEdu(1:20,:), 'UniformOutput',0);
Data_HC_AgeEdu=[Data_HC_AgeEdu_up;Data_HC_AgeEdu_low];
Data_HC_AgeEdu=cell2mat(Data_HC_AgeEdu);
% Gender
MyStrcmp=@(x) strcmp(x,'��');
Data_GAD_Gender=cellfun(MyStrcmp,Data_GAD_Dem(:,1));
Data_HC_Gender=cellfun(MyStrcmp,Data_HC_Dem(:,1));
% All: gender,age,education,duration of illness and the last 6 column
Data_GAD_Dem=[Data_GAD_Gender(1:46),Data_GAD_AgeEdu,cell2mat(DataExcel_GAD_Raw(2:47,14:19))]; %gender,age,education,duration of illness and the last 6 column
Data_HC_Dem=[Data_HC_Gender,Data_HC_AgeEdu,cell2mat(DataExcel_HC_Raw(2:end,19:24))]; %gender,age,education and the last 6 column
% add order ID at the first column
% Data_GAD_Dem=[[1:size(Data_GAD_Dem,1)]',Data_GAD_Dem]; 
% Data_HC_Dem=[[1:size(Data_HC_Dem,1)]',Data_HC_Dem];
% delete data if it has not the corrspond ID
% Data_GAD_Dem=Data_GAD_Dem;
% Data_HC_Dem=Data_HC_Dem;
%% ============Extract excel data according ID order==============
% �����ĳ��ID��excelԭʼ������û�ж�Ӧ����������Ƚ��˴���0��Ϊ1���Ӷ����ѭ�����
Locmember_GADok(Locmember_GADok==0)=1;
Locmember_GADnotok(Locmember_GADnotok==0)=1;
Locmember_HC(Locmember_HC==0)=1;
% ����ID����ѭ���������סHC��ѭ����ܴ������⣬��Ϊ�ܶ�HCû��ԭʼID.Note.�˴��������һ�м���order ID
ScaleSorted_GADnotok=[(1:numel(Locmember_GADnotok))',Data_GAD_Dem(Locmember_GADnotok,:)];
ScaleSorted_GADok=[(1:numel(Locmember_GADok))',Data_GAD_Dem(Locmember_GADok,:)];
ScaleSorted_HC=[(1:numel(Locmember_HC))',Data_HC_Dem];% HC ��û�а���ID��������Ϊ�����HCû��ԭʼID
% ɾ��û��ԭʼID������
ScaleSorted_GADnotok=ScaleSorted_GADnotok(IFmember_GADnotok',:);
ScaleSorted_GADok=ScaleSorted_GADok(IFmember_GADok',:);
% ScaleSorted_HC=ScaleSorted_HC(IFmember_HC',:);