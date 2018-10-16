function lc_kmeans_identifyK(data,kRange)
% ��������ƽ������/���ƽ����������׼��elbow criterion ratio����ȷ��k��С
%   input:
%    data,N subjs * P features
%       kRange:k��ȡֵ��Χ��kRange=2:1:10;
%   output:
%       ratio:��ֵ����
%% =============== input=================
% rng default; % For reproducibility
% data = [randn(300,2)*4;randn(300,2)*1.2;randn(300,2)*8;randn(300,2)*0.1];
% About how to identify K, please refer to "The human cortex possesses a reconfigurable
% dynamic network architecture that is disrupted in psychosis"
if nargin<2
%     kRange=[2,4,5,8];
    kRange=2:1:8;
end
nReplicates=10;%�����ʼ�����Ĵ���
distanceMethod='cityblock'; % L1 distance
%% 
[n,p]=size(data);
%% normalizating data(option)
% for i=1:p
%     minr=min(data(:,i));
%     maxr=max(data(:,i));
%     data(:,i)=(data(:,i)-minr)/(maxr-minr);%��һ��
% end
%% kmeans loop(kmeans++ algorithm)
% elbow criterion ratio
ratio=zeros(numel(kRange)-1,2);
T=0;
parpool(3);
parfor k=kRange
    T=T+1;
    opts = statset('Display','off');
    [Idx,C,sumD,~] = kmeans(data,k,'Distance',distanceMethod,...
        'Replicates',nReplicates,'Options',opts);
    %% -----��ÿ������-----
    sort_num=zeros(k,1);
    for i=1:k
        for j=1:n
            if Idx(j,1)==i
                sort_num(i,1)=sort_num(i,1)+1;
            end
        end
    end
    %% ����ƽ������
    sort_ind=sumD./sort_num;
    sort_ind_ave=mean(sort_ind);
    %% �����ƽ������
    h=nchoosek(k,2);
    A=zeros(h,2);
    t=0;
    sort_outd=zeros(h,1);
    for i=1:k-1
        for j=i+1:k
            t=t+1;
            A(t,1)=i;
            A(t,2)=j;
        end
    end
    for i=1:h
        for j=1:p
            sort_outd(i,1)=sort_outd(i,1)+(C(A(i,1),j)-C(A(i,2),j))^2;
        end
    end
    sort_outd_ave=mean(sort_outd);%���ƽ������
    %% ��ֵ
    ratio(T,1)=k;
    ratio(T,2)=sort_ind_ave/sort_outd_ave;
end
%% plot elbow criterion ratio
figure
plot(ratio(:,1),ratio(:,2))
