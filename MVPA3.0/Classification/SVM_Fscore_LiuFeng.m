%% ʹ��F score�������������ҷ��� 

clc,clear,close all
%% ѡ���������� ��mat����
path1 = spm_select(1,'dir','please select patients dir');
file1 = dir([path1 '*.mat']);

%% ѡ�������������� ��mat����
path2 = spm_select(1,'dir','please select hc dir');
file2 = dir([path2 '*.mat']);

%% �������Ǿ�������һ��(��һ��)
feature = [];DATA_sad = [];significance = [];
for i = 1:length(file1)
    load([path1 file1(i).name])
    for j = 1:115
        A = [];A = corROI4(j,j+1:end);
       
        feature = [feature A];
       
    end
    DATA_sad(i,:) = feature;feature = [];
    
clear i j A
%% �ڶ���
feature = [];DATA_hc = [];significance = [];
for i = 1:length(file2)
    load([path2 file2(i).name])
    for j = 1:115
        A = [];A = corROI4(j,j+1:end);
        
        feature = [feature A];
       
    end
    DATA_hc(i,:) = feature;feature = [];
    
end

%% ���������ϲ�
DATA = [DATA_sad;DATA_hc];
SIG = [sig_SAD;sig_hc];
label = [ones(size(DATA_sad,1),1); -1*ones(size(DATA_hc,1),1)];

h = waitbar(0,'please wait..');
for i = 1:size(DATA,1)
    waitbar(i/size(DATA,1))
    new_DATA = DATA; new_label = label;
    test_data = DATA(i,:);new_DATA(i,:) = []; train_data = new_DATA;
    test_label = label(i,:);new_label(i,:) = [];train_label = new_label;
    %% training data in the sad group
    data_sad = train_data(find(train_label==1),:);
    %% training data in the hc group
    data_hc = train_data(find(train_label==-1),:);
    %% �ֱ����ѵ���������������ľ�ֵ
    x_sad = mean(data_sad);x_hc = mean(data_hc);x_data = mean(train_data);
    %% F_score feature selection
    for k = 1:size(train_data,2)
        for j = 1:size(train_data,1)
            if j<=size(data_sad,1)
                AA_sad(j) = (train_data(j,k)-x_sad(k))^2;
                sum_sad(k) = sum(AA_sad);
            else
                BB_hc(j-size(data_sad,1)) = (train_data(j,k)-x_hc(k))^2;
                sum_hc(k) = sum(BB_hc);
            end
        end
        F(i,k) = ((x_sad(k)-x_data(k))^2+(x_hc(k)-x_data(k))^2)/((sum_sad(k)/(size(data_sad,1)-1))+(sum_hc(k)/(size(data_hc,1)-1)));
    end
    [B,IX] = sort(F(i,:),'descend');
    order(i,:) = IX;
    strength(i,:) = B;
    model = svmtrain(train_label,train_data(:,order(i,1:200)),'-t 0');
    w(i,:) = model.SVs'*model.sv_coef;
    [predicted_label accuracy] = svmpredict(test_label,test_data(:,order(i,1:200)),model);
    acc(i,1) = accuracy(1);
end
close(h)
acc_final = mean(acc);

%% Ѱ�� find consensus feature
order_new = order(:,1:200);
unique_200 = unique(order_new);
%% ͳ��ÿ�����ӳ��ֵĴ���
for y = 1:length(unique_200)
    index(y) = length(find(order_new == unique_200(y)));
end
 % Ѱ��һ��������λ��
index_consensus = find(index==40);
 % �����һ������
consensus_feature = unique_200(index_consensus);

for z = 1:size(order_new,1)
    for zz = 1:length(consensus_feature)
        xuhao(z,zz) = find(order_new(z,:) == consensus_feature(zz));
    end
end
% �����һ�����ӣ���һ�γ�������97λ�ã��ڶ��γ�������116λ�ã������γ�������74λ��
%% ��������˳���ŵ�w��ÿһ��loocv
for zzz = 1:size(xuhao,1)
    W_consensus(zzz,:) = w(zzz,xuhao(zzz,:));%˳��Ϊconsensus_feature���ţ���һ��consensus_connectionΪ22
end
%% ���ÿ��һ�����ӵ�ƽ��Ȩֵ
mean_w = mean(abs(W_consensus));
%% ����һ�����ӵ�ƽ��Ȩֵ
mean_mean_w = mean(mean_w);
%% scale
scale_connection_w = (mean_w/mean_mean_w)';%% ���������ӵ�Ȩֵ��׼��

%% �ҵ�һ��������������
load TDdatabase
AAL = DB{6}.anatomy;
for xx = 1:length(consensus_feature)
    [row column] = index2matrix(consensus_feature(xx));
    origin_site(xx,1) = row;origin_site(xx,2) = column;
    connection_name{xx,1} = AAL{row};connection_name{xx,2} = AAL{column};
    connection_name{xx,3} = scale_connection_w(xx);
end
xlswrite('connection_name.xls',connection_name)
%% �����ҵ���Щ����������Щ����
region_unique = unique(origin_site);

for ii = 1:length(region_unique)
    column1_AA = find(origin_site(:,1)==region_unique(ii));
    column2_AA = find(origin_site(:,2)==region_unique(ii));
    region_number{ii} = [column1_AA;column2_AA];
    region_w(ii) = sum(0.5*(mean_w(region_number{ii})));
    clear column1_AA column2_AA
end
scale_region_w = region_w/mean(region_w);
[B1,IX1] = sort(scale_region_w,'descend');
%% ���һ������������������Ȩֵ
for xxx = 1:length(IX1)
    region_name{xxx,1} = AAL{region_unique(IX1(xxx))};
    region_name{xxx,2} = B1(xxx);
end

xlswrite('region_name.xls',region_name)













        
        
        
        
        
