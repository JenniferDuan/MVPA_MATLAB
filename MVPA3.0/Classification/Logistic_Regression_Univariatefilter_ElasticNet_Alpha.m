function [Accuracy, Sensitivity, Specificity, PPV, NPV] =...
    Logistic_Regression_Univariatefilter_ElasticNet_Alpha(opt)
%=========SVM classification using RFE========================
%ע�⣺�˴��뱣���Ȩ��ͼΪN-fold��consensus��ƽ��Ȩ��ͼ��refer to��Multivariate classification of social anxiety disorder
% using whole brain functional connectivity����
%�ڿ�ʼRFE֮ǰ���Լ��뵥�������������ˣ���F-score ��opt.Kendall Tau��Two-sample t-test��
%refer to PMID:18672070opt.Initial_FeatureQuantity
%input��opt.K=opt.K-fold cross validation,opt.K<=N;
%[opt.Initial_FeatureQuantity,opt.Max_FeatureQuantity,opt.Step_FeatureQuantity]=��ʼ��������,���������,ÿ�����ӵ���������
%opt.P_threshold Ϊ�����������������ǵ�P��ֵ;opt.percentage_consensusΪ��
% opt.K fold��ĳ��Ȩ�ز�Ϊ������س��ֵĸ��ʣ���opt.percentage_consensus=0.8��opt.K=5�������5*0.8=4�����ϵ����ز���Ϊ��consensus���ء�
%output����������Լ�opt.K-fold��ƽ������Ȩ��
%performances(:,1:size(performances,2)/2)=���ܣ����µ�Ϊ��׼�
%indices= ������� Ϊ����С��Χ�ڲ���
% path=pwd;
% addpath(path);
%% set options
if nargin<1
    opt.K=5;opt.Initial_FeatureQuantity=50;opt.Max_FeatureQuantity=5000;opt.Step_FeatureQuantity=50;%uter opt.K fold.
    opt.P_threshold=0.0001;% univariate feature filter.
    opt.learner='svm';opt.stepmethod='percentage';opt.step=10;% RFE.
    opt.percentage_consensus=0.7;%The most frequent voxels/features;range=(0,1];
    opt.weight=0;opt.viewperformance=0;opt.saveresults=0;
    opt.standard='scale';opt.min_scale=0;opt.max_scale=1;
    opt.permutation=0;
    opt.lambda=exp(-6:6);opt.alpha=0.1:0.1:1;
end
%% ===transform .nii/.img into .mat data, and achive corresponding label=========
% if nargin<2 %������û������򲻶�ͼ����������һ������ṩ
    [~,path,data_patients ] = Img2Data_LC;
    [~,~,data_controls ] = Img2Data_LC;
    data=cat(4,data_patients,data_controls);%data
    n_patients=size(data_patients,4);
    n_controls=size(data_controls,4);
% end
% if nargin<3
    label=[ones(n_patients,1);zeros(n_controls,1)];%label
% end
[dim1,dim2,dim3,N]=size(data);
%% ==========just opt.Keep data in inmasopt.K========================
data=reshape(data,[dim1*dim2*dim3,N]);%�з���Ϊ��������ÿһ��Ϊһ��������ÿһ��Ϊһ������
implicitmask = sum(data,2)~=0;%�ڲ�masopt.K,�����ۼ�
data_inmask=data(implicitmask,:);%�ڲ�masopt.K�ڵ�data
data_inmask=data_inmask';
%%
[ B0,Predict_label,Real_label,Decision ] = ...
    Logistic_Regression_ElasticNet(data_inmask,label,opt);
%% �������
[Accuracy, Sensitivity, Specificity, PPV, NPV]=Calculate_Performances(cell2mat(Predict_label),cell2mat(Real_label));
AUC=AUC_LC(cell2mat(Real_label),cell2mat(Decision));












%% ==================ȷ��t�������ܳ��ֵ���С��������===============


%% ==============�����С����С��Ԥ����������,�����������Ϊt�����г��ֵ���С����������Ӧ�Ĳ�������ʵҲ�ı�========

%% =======================Ԥ����ռ�===============================

%%  ====================opt.K fold loop===============================
%
% %% ================���õĴ���==================================
% if opt.weight
%     %% consensus��ƽ���Ŀռ��б�ģʽ
%     binary_mask=W_Brain~=0;
%     sum_binary_mask=sum(binary_mask,3);
%     loc_consensus=sum_binary_mask>=opt.percentage_consensus*opt.K; num_consensus=sum(loc_consensus,2)';%location and number of consensus weight
%     if ~opt.permutation
%         disp(['consensus voxel = ' num2str(num_consensus)]);
%     end
%     W_mean=mean(W_Brain,3);%ȡ����fold�� W_Brain��ƽ��ֵ
%     W_mean(~loc_consensus)=0;%set weights located in the no consensus location to zero.
%     W_M_Brain(:,implicitmask)=W_mean;%��ͬfeature ��Ŀʱ��ȫ������Ȩ��
% end
%% �����������
% Accuracy(isnan(Accuracy))=0; Sensitivity(isnan(Sensitivity))=0; Specificity(isnan(Specificity))=0;
% PPV(isnan(PPV))=0; NPV(isnan(NPV))=0; AUC(isnan(AUC))=0;
% %% ����ģ����opt.K fold�е�ƽ�����ܣ�����LOOCV������
% if opt.K<N
%     performances=[[mean(Accuracy);mean(Sensitivity);mean(Specificity);mean(PPV);mean(NPV);mean(AUC)],...
%         [std(Accuracy);std(Sensitivity);std(Specificity);std(PPV);std(NPV);std(AUC)]];%�ۺϷ�����֣�ǰһ����Mean ��һ����Std
% elseif opt.K==N
%     [Accuracy, Sensitivity, Specificity, PPV, NPV]=Calculate_Performances(Predict,label_ForPerformance);
%     AUC=AUC_LC(label_ForPerformance,cell2mat(Decision));
%     performances=[Accuracy, Sensitivity, Specificity, PPV, NPV,AUC]';%�ۺϷ������
% end
% %% identify the best performance���Լ�����Ӧ��������������consensus������������ȷ����Ӧ��weight��num_consensus
% %��AUCΪ��׼�ҵ���õ�AUC����λ�ã����ҵ���õķ�������Լ����AUC��Ӧ��weight
% N_plot=length(opt.Initial_FeatureQuantity:opt.Step_FeatureQuantity:opt.Max_FeatureQuantity);
% meanAUC=performances(6,(1:1:N_plot)); meanaccuracy=performances(1,(1:1:N_plot));
% meansensitivity=performances(2,(1:1:N_plot));meanspecificity=performances(3,(1:1:N_plot));
% loc_best_meanAUC=find(meanAUC==max(meanAUC));
% loc_best_meanAUC=loc_best_meanAUC(1);
% AUC_best=meanAUC(loc_best_meanAUC);Accuracy_best=meanaccuracy(loc_best_meanAUC);
% Sensitivity_best=meansensitivity(loc_best_meanAUC); Specificity_best=meanspecificity(loc_best_meanAUC);%for permutation test
% if ~opt.permutation
%     disp(['best AUC,Accuracy,Sensitivity and Specificity = '...
%         ,num2str([AUC_best,Accuracy_best,Sensitivity_best,Specificity_best])]);
% end
% %��Ӧ������������consensus������
% if opt.weight
%     NumBestConsensusFeature=num_consensus(loc_best_meanAUC);
%     AllFeatureSubset=(opt.Initial_FeatureQuantity:opt.Step_FeatureQuantity:opt.Max_FeatureQuantity);
%     NumBestFeature=AllFeatureSubset(loc_best_meanAUC);
%     W_M_Brain_best=W_M_Brain(loc_best_meanAUC,:);
%     W_M_Brain_3D=reshape(W_M_Brain_best,dim1,dim2,dim3);%best W_M_Brain_3D
%     if ~opt.permutation
%         disp(['NumBestConsensusFeature and NumBestFeature = ' num2str(NumBestConsensusFeature),' and ', num2str(NumBestFeature),' respectively']);
%     end
% end
% %% visualize performance
% if opt.viewperformance
%     % Name_plot={'accuracy','sensitivity', 'specificity', 'PPV', 'NPV','AUC'};
%     N_plot=length(opt.Initial_FeatureQuantity:opt.Step_FeatureQuantity:opt.Max_FeatureQuantity);
%     figure;
%     plot((opt.Initial_FeatureQuantity:opt.Step_FeatureQuantity:opt.Max_FeatureQuantity),performances(1,(1:1:N_plot)),...
%         '--o','markersize',5,'LineWidth',2);title('Mean accuracy');
%     figure;
%     plot((opt.Initial_FeatureQuantity:opt.Step_FeatureQuantity:opt.Max_FeatureQuantity),performances(2,(1:1:N_plot)),...
%         '--o','markersize',5,'LineWidth',2);title('Mean sensitivity');
%     figure;
%     plot((opt.Initial_FeatureQuantity:opt.Step_FeatureQuantity:opt.Max_FeatureQuantity),performances(3,(1:1:N_plot)),...
%         '--o','markersize',5,'LineWidth',2);title('Mean specificity');
%     figure;
%     plot((opt.Initial_FeatureQuantity:opt.Step_FeatureQuantity:opt.Max_FeatureQuantity),performances(6,(1:1:N_plot)),...
%         '--o','markersize',5,'LineWidth',2); title('Mean AUC');
% end
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
%             '��ѡ��masopt.K����ѡ��', ...
%             'MultiSelect', 'off');
%         img_strut_temp=load_nii([path_source1,char(file_name)]);
%         mask_graymatter=img_strut_temp.img~=0;
%         W_M_Brain_3D(~mask_graymatter)=0;
%         % save nii
%         cd (outdir)
%         Data2Img_LC(W_M_Brain_3D,['W_M_Brain_3D_',Time,'.nii']);
%     end
%     %save results
%     save([outdir filesep [Time,'Results_MVPA.mat']],...
%         'Accuracy', 'Sensitivity', 'Specificity','PPV', 'NPV', 'Decision', 'AUC',...
%         'label_ForPerformance',...
%         'AUC_best','Accuracy_best','Sensitivity_best','Specificity_best');
% end
end

