function [ AUC_All, Accuracy_All, Sensitivity_All, Specificity_All,p_AUC,p_Accuracy, p_Sensitivity, p_Specificity,...
    MAE_All,R_All,CombinedPerformance_All,p_MAE, p_R, p_CombinedPerformance]....
    = Permutation_MVPA(AUC, Accuracy, Sensitivity, Specificity, MAE, R, CombinedPerformance,opt)
%opt.nperm=�û�����,opt.parworkers=�߳���
%% options
if nargin<8
    % permutation options
    opt.MVPA='Regression_RFE';opt.nperm=2;opt.parworkers=2;opt.permutation=1;
    % MVPA options
    opt.K=5;opt.Initial_FeatureQuantity=50;opt.Max_FeatureQuantity=5000;opt.Step_FeatureQuantity=50;%uter K fold.
    opt.P_threshold=0.05;% univariate feature filter.
    opt.learner='svm';opt.stepmethod='percentage';opt.step=10;% RFE.
    opt.percentage_consensus=0.7;%The most frequent voxels/features;range=(0,1];
    opt.weight=0;opt.viewperformance=0;opt.saveresults=0;
    opt.standard='scale';opt.min_scale=0;opt.max_scale=1;
end
%% ��ͼ������data
if strcmp(opt.MVPA,'Regression_RFE')
    [~,~,data ] = Img2Data_LC;
    %% label
    anafig = figure('Name','Input Dependent variables',...
        'MenuBar','none', ...
        'Toolbar','none', ...
        'NumberTitle','off', ...
        'Resize', 'off', ...
        'Position',[500,500,420,50]); %X,Y then Width, Height
    set(anafig, 'Color', ([50,200,50] ./255));
    label_panel=uicontrol('Style','edit','HorizontalAlignment','left','String','','Position',[10 10 400 30]);
    pause;
    label=str2num(get(label_panel,'String'));
    label=reshape(label,numel(label),1);
    %%
else
    [~,~,data_patients ] = Img2Data_LC;
    [~,~,data_controls ] = Img2Data_LC;
    data=cat(4,data_patients,data_controls);%data
    n_patients=size(data_patients,4);
    n_controls=size(data_controls,4);
    label=[ones(n_patients,1);zeros(n_controls,1)];%label
end

%% Ԥ����ռ�
AUC_All=zeros(1,opt.nperm); Accuracy_All=zeros(1,opt.nperm);
Sensitivity_All=zeros(1,opt.nperm); Specificity_All=zeros(1,opt.nperm);
MAE_All=Inf(1,opt.nperm);R_All=zeros(1,opt.nperm);CombinedPerformance_All=zeros(1,opt.nperm);
exceedances_AUC=0;
exceedances_Accuracy=0;
exceedances_Sensitivity=0;
exceedances_Specificity=0;
%% which MVPA
if strcmp(opt.MVPA,'Classification_RFE')
    MVPA=@SVM_LC_Kfold_RFEandUnivariate_beta;
end
if strcmp(opt.MVPA,'Regression_RFE')
    MVPA=@SVMRegression_Kfold_RFE_beta;
end
if strcmp(opt.MVPA,'Logistic_ElasticNet')
    MVPA=@Logistic_Regression_ElasticNet;
end
%% �����label���ظ�ִ����Ӧ��MVPA�� �����ֲ�����
% parfor_progress(opt.nperm);
for i =1:opt.nperm
    rowrank = randperm(length(label))';%����������֣��������label
    label_temp =label(rowrank,:);%�����label
    %%
    if strcmp(opt.MVPA,'Regression_RFE')
        [ MAE_best,R_best,CombinedPerformance_best] =MVPA(opt,label_temp,data);
        MAE_All(i)=MAE_best;R_All(i)=R_best;CombinedPerformance_All(i)=CombinedPerformance_best;
        % how many in Null distribution greater than real statistics
        curexceeds_MAE =MAE_best<=MAE;
        exceedances_MAE = exceedances_MAE + curexceeds_MAE;
        curexceeds_R =R_best>=R;
        exceedances_R = exceedances_R + curexceeds_R;
        curexceeds_CombinedPerformance =CombinedPerformance_best>=CombinedPerformance;
        exceedances_CombinedPerformance = exceedances_CombinedPerformance + curexceeds_CombinedPerformance;
    else
        [AUC_per, Accuracy_per,Sensitivity_per,Specificity_per] =MVPA(opt,data,label_temp);
        AUC_All(i)=AUC_per; Accuracy_All(i)= Accuracy_per;
        Sensitivity_All(i)=Sensitivity_per; Specificity_All(i)=Specificity_per;
        % how many in Null distribution greater than real statistics
        curexceeds_AUC =AUC_per>=AUC;
        exceedances_AUC = exceedances_AUC + curexceeds_AUC;
        curexceeds_Accuracy =Accuracy_per>=Accuracy;
        exceedances_Accuracy = exceedances_Accuracy + curexceeds_Accuracy;
        curexceeds_Sensitivity =Sensitivity_per>=Sensitivity;
        exceedances_Sensitivity = exceedances_Sensitivity + curexceeds_Sensitivity;
        curexceeds_Specificity =Specificity_per>=Specificity;
        exceedances_Specificity = exceedances_Specificity + curexceeds_Specificity;
    end
    % w_M_Brain_All(i,:)=w_M_Brain_temp;
    %    end
    %    save(['w_M_Brain_All',int2str(j)], 'w_M_Brain_All');
    %     parfor_progress;
end
%% calculate p values
if strcmp(opt.MVPA,'Regression_RFE')
    p_MAE=(exceedances_MAE+1)/(opt.nperm+1);
    p_R=(exceedances_R+1)/(opt.nperm+1);
    p_CombinedPerformance=(exceedances_CombinedPerformance+1)/(opt.nperm+1);
else
    p_AUC=(exceedances_AUC+1)/(opt.nperm+1);
    p_Accuracy=(exceedances_Accuracy+1)/(opt.nperm+1);
    p_Sensitivity=(exceedances_Sensitivity+1)/(opt.nperm+1);
    p_Specificity=(exceedances_Specificity+1)/(opt.nperm+1);
    p_MAE=NaN;p_R=NaN;p_CombinedPerformance=NaN;
end
end

