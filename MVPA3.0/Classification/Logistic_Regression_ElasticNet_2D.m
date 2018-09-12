function [ AUC, Accuracy, Sensitivity, Specificity,  Real_label,Decision, B] = ...
    Logistic_Regression_ElasticNet_2D(data,label,opt)
% ��;�� ��1ά���ݽ��� elastic net ����ɸѡ���߼��ع�
% [ B,Predict_label,Real_label,Accuracy,Sensitivity,Specificity,PPV,NPV,Decision ] = ...
%     Logistic_Regression_ElasticNet(data,label,opt)
%����elastic net����������ɸѡ�������߼��ع�ģ��
%���룺��ο� FeatureSelection_Logistic_Regression_ElasticNet,ע�⣺data��1ά����
%�����Ԥ���ǩ����ʵ��ǩ�Լ�Ӧ������ԭʼֵ������ROC��
%example
    % data=rand(100,500);r=[1;2;3;4;5;6;7;8;9;8;7;6;5;4;3;2;1;1;2;3;4;5;6;7;8;9;9;8;7;6;5;4;3;21;zeros(500-34,1)];
    %label=data*r;
    %lambda=exp(-6:6);alpha=0.1:0.1:1;
%[ Predict_label{1},Real_label{1}]
%for i=1:K;[accuracy(i),sensitivity(i),specificity(i),PPV(i),NPV(i)]=Calculate_Performances(Predict_label{i},Real_label{i});end
%a=[accuracy;sensitivity;specificity;PPV;NPV]
%mean(a,2)
%% ==============================================================
if nargin<3
opt.lambda=exp(-3:3);opt.alpha=0.5:0.1:1;opt.K=2;
% opt.standard='normalizing';
opt.standard='normalizing';
end
%% preallocate
% B=zeros();
%% ===transform .nii/.img into .mat data, and achive corresponding label=========
% if nargin<2 %������û������򲻶�ͼ����������һ������ṩ
%     [~,path,data_patients ] = Img2Data_LC;
%     [~,~,data_controls ] = Img2Data_LC;
%     data=cat(4,data_patients,data_controls);%data
%     n_patients=size(data_patients,4);
%     n_controls=size(data_controls,4);
%     if opt.permutation;disp(['number of patients and controls are ', num2str([n_patients, n_controls])]);end
% end
% if nargin<3
%     label=[ones(n_patients,1);zeros(n_controls,1)];%label
% end
% [dim1,dim2,dim3,N]=size(data);
%% ==========just opt.Keep data in inmask========================
% data=reshape(data,[dim1*dim2*dim3,N]);%�з���Ϊ��������ÿһ��Ϊһ��������ÿһ��Ϊһ������
% implicitmask = sum(data,2)~=0;%�ڲ�masopt.K,�����ۼ�
% data_inmask=data(implicitmask,:);%�ڲ�masopt.K�ڵ�data
% data_inmask=data_inmask';
data_p=data(label==1,:);
data_c=data(label==0,:);
n_patients=size(data_p,1);
n_controls=size(data_c,1);
%%  Ԥ����ռ�
Predict_label=cell(opt.K,1); Real_label=cell(opt.K,1);Decision=cell(opt.K,1);
Accuracy=zeros(opt.K,1);Sensitivity =zeros(opt.K,1);Specificity=zeros(opt.K,1);
PPV=zeros(opt.K,1);NPV=zeros(opt.K,1);AUC=zeros(opt.K,1);
% B=zeros(opt.K,dim1*dim2*dim3);
%% K fold ready
N=size(data,1);
indices_p = crossvalind('Kfold', n_patients, opt.K);
indices_c = crossvalind('Kfold', n_controls, opt.K);
h=waitbar(0,'��ȴ� Outer Loop>>>>>>>>','Position',[50 50 280 60]);
% set(h, 'Color','c');
for i = 1:opt.K
    %% ���ѭ��
    waitbar(i/opt.K);
    %% �����ݷֳ�ѵ�������Ͳ����������ֱ�ӻ��ߺͶ������г�ȡ��Ŀ����Ϊ������ƽ�⣩
    % patients data
    Test_index_p = (indices_p == i); Train_index_p = ~Test_index_p;
    Test_data_p =data_p(Test_index_p,:);Train_data_p =data_p(Train_index_p,:);
    % controls data
    Test_index_c = (indices_c == i); Train_index_c = ~Test_index_c;
    Test_data_c =data_c(Test_index_c,:);Train_data_c =data_c(Train_index_c,:);
    % all data
    Train_data=[Train_data_p;Train_data_c];
    Test_data=[Test_data_p;Test_data_c];
    % all label
    Test_label = [ones(sum(indices_p==i),1);zeros(sum(indices_c==i),1)];
    Train_label =  [ones(sum(indices_p~=i),1);zeros(sum(indices_c~=i),1)];
    %% ��һ�����׼��
    if strcmp(opt.standard,'normalizing')
        MeanValue = mean(Train_data);
        StandardDeviation = std(Train_data);
        [row_quantity, columns_quantity] = size(Train_data);
        Train_data_temp=zeros(row_quantity, columns_quantity);
        for ii = 1:columns_quantity
            if StandardDeviation(ii)
                Train_data_temp(:, ii) = (Train_data(:, ii) - MeanValue(ii)) / StandardDeviation(ii);
            end
        end
        Test_data_temp = (Test_data - MeanValue) ./ StandardDeviation;
        Train_data=Train_data_temp;Test_data=Test_data_temp;
    end
    
    if strcmp(opt.standard,'scale')
        [Train_data_temp,PS] = mapminmax(Train_data');
        Train_data_temp=Train_data_temp';
        Test_data_temp = mapminmax('apply',Test_data',PS);
        Test_data_temp =Test_data_temp';
        Train_data=Train_data_temp;Test_data=Test_data_temp;
    end
    %% ���뵥��������������
%     [~,P,~,~]=ttest2(Train_data(Train_label==1,:), Train_data(Train_label==0,:),'Tail','both');
%     Index_ttest2=find(P<=opt.P_threshold);%��С�ڵ���ĳ��Pֵ������ѡ�������
%     Train_data= Train_data(:,Index_ttest2);
%     Test_data=Test_data(:,Index_ttest2);
    %% �ڲ�Ƕ��ѭ����ͨ��elastic Net �ҵ��߼��ع�ģ����Ѳ�����
    [ ~,~,~,B_inner, Intercept_final] =...
        FeatureSelection_Logistic_Regression_ElasticNet(Train_data,Train_label,opt.lambda,opt.alpha,opt.K);
    %% ����weight��ͬʱԤ���������
    % ����weight
%     B_temp_inner=zeros(1,sum(implicitmask));
%     B_temp_outer=zeros(1,dim1*dim2*dim3);
%     B_temp_inner(Index_ttest2)=B_inner;
%     B_temp_outer(implicitmask)= B_temp_inner;
    B(i,:)= B_inner;
    % Ԥ��
    B_model=[Intercept_final; B_inner];
    preds = glmval(B_model,Test_data,'logit');
    Decision{i}=preds;
    Predict_label{i}= preds>=0.5; Real_label{i}=Test_label;
    %% ����ģ�͵�����
    [Accuracy(i),Sensitivity(i),Specificity(i),PPV(i),NPV(i)]=Calculate_Performances(preds>=0.5,Test_label);
    [AUC(i)]=AUC_LC(Test_label,preds);
end
%% cell2mat
% Predict_label=cell2mat(Predict_label);Real_label=cell2mat(Real_label);
% Decision=cell2mat(Decision);
close (h)
%% ================���õĴ���==================================
% if opt.weight
%     %% consensus��ƽ���Ŀռ��б�ģʽ
%     binary_mask=B~=0;
%     sum_binary_mask=sum(binary_mask);
%     loc_consensus=sum_binary_mask>=opt.percentage_consensus*opt.K;%location and number of consensus weight
%     B_mean=mean(B);%ȡ����fold�� W_Brain��ƽ��ֵ
%     B_mean(~loc_consensus)=0;%set weights located in the no consensus location to zero
% end
% %% �����������
% Accuracy(isnan(Accuracy))=0; Sensitivity(isnan(Sensitivity))=0; Specificity(isnan(Specificity))=0;
% PPV(isnan(PPV))=0; NPV(isnan(NPV))=0; AUC(isnan(AUC))=0;
% %% ����ģ����K fold�е�ƽ������
% 
% performances=[[mean(Accuracy);mean(Sensitivity);mean(Specificity);mean(PPV);mean(NPV);mean(AUC)],...
%     [std(Accuracy);std(Sensitivity);std(Specificity);std(PPV);std(NPV);std(AUC)]];%�ۺϷ�����֣�ǰһ����Mean ��һ����Std
% 
% %% visualize performance
% 
% %% ������ѵķ���Ȩ��ͼ��������
% Time=datestr(now,30);
% if opt.saveresults
%     %��Ž��·��
%     loc= find(path=='\');
%     outdir=path(1:loc(length(find(path=='\'))-2)-1);%path����һ��Ŀ¼
%     %gray matter masopt.K
%     if opt.weight
%         [file_name,path_source1,~]= uigetfile( ...
%             {'*.img;*.nii;','All Image Files';...
%             '*.*','All Files' },...
%             '��ѡ��mask����ѡ��', ...
%             'MultiSelect', 'off');
%         img_strut_temp=load_nii([path_source1,char(file_name)]);
%         mask_graymatter=img_strut_temp.img~=0;
%         B_M_Brain_3D=reshape(B_mean,dim1,dim2,dim3);% K fold��ƽ��Ȩ��
%         B_M_Brain_3D(~mask_graymatter)=0;
%         % save nii
%         cd (outdir)
%         Data2Img_LC(B_M_Brain_3D,['W_M_Brain_3D_',Time,'.nii']);
%     end
%     %save results
%     save([outdir filesep [Time,'Results_MVPA.mat']],...
%         'Accuracy', 'Sensitivity', 'Specificity','PPV', 'NPV', 'AUC', ...
%         'Decision','Real_label');
% end
end

