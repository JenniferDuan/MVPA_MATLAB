function performances =SVM_LC_Kfold_PCA_ForPermutationTest(data_inmask, label, N, K)
%�˴�����heart���ݼ��ϲ��Գɹ�
%input��K=K-fold cross validation,K<N
%output����������Լ�K-fold��ƽ������Ȩ��
%% ��ͼ��תΪdata,������label
% [~,~,data_patients ] = Img2Data_LC;
% [~,~,data_controls ] = Img2Data_LC;
% data=cat(4,data_patients,data_controls);%data
% [dim1,dim2,dim3,n_patients]=size(data_patients);
% [~,~,~,n_controls]=size(data_controls);
% label=[ones(n_patients,1);zeros(n_controls,1)];%label
% %% inmask
% N=n_patients+n_controls;
% data=reshape(data,[dim1*dim2*dim3,N]);%�з���Ϊ��������ÿһ��Ϊһ��������ÿһ��Ϊһ������
% implicitmask = sum(data,2)~=0;%�ڲ�mask,�����ۼ�
% data_inmask=data(implicitmask,:);%�ڲ�mask�ڵ�data
% data_inmask=data_inmask';
%% Ԥ����ռ�
Accuracy=zeros(K,1);Sensitivity =zeros(K,1);Specificity=zeros(K,1);
AUC=zeros(K,1);Decision=cell(K,1);PPV=zeros(K,1); NPV=zeros(K,1);
% w_Brain=zeros(K,sum(implicitmask));
label_ForPerformance=NaN(N,1);
% w_M_Brain=zeros(1,dim1*dim2*dim3);
Predict=NaN(N,1);
%%  K fold loop
% h = waitbar(0,'...','Position',[50 50 280 60]);
s=rng(1);%���ظ���һ��
rng(s);%���ظ���һ��
indices = crossvalind('Kfold', N, K);
switch K<N
    case 1
        for i=1:K
%             waitbar(i/K,h,sprintf('%2.0f%%', i/K*100)) ;
            disp(['The inner was ' num2str(i),'/',num2str(K), ' fold!']);
            %K fold
            test_index = (indices == i); train_index = ~test_index;
            train_data =data_inmask(train_index,:);
            train_label = label(train_index,:);
            test_data = data_inmask(test_index,:);
            test_label = label(test_index);
            %% ��ά����һ��
            %���ɷֽ�ά
            [COEFF, train_data] = pca(train_data);%�ֱ��ѵ�����������������������ɷֽ�ά��
            test_data = test_data*COEFF;
            %���з����һ��
            [train_data,PS] = mapminmax(train_data');
            train_data=train_data';
            test_data = mapminmax('apply',test_data',PS);
            test_data =test_data';
            %% ѵ��ģ��
            model= fitclinear(train_data,train_label);
            %%
            [predict_label, dec_values] = predict(model,test_data);
            Decision{i}=dec_values(:,2);
            %% ����ģ��
            [accuracy,sensitivity,specificity,ppv,npv]=Calculate_Performances(predict_label,test_label);
            Accuracy(i) =accuracy;
            Sensitivity(i) =sensitivity;
            Specificity(i) =specificity;
            PPV(i)=ppv;
            NPV(i)=npv;
            [AUC(i)]=AUC_LC(test_label,dec_values(:,2));
            %%  �ռ��б�ģʽ
            %             w_Brain_Component = model.Beta;
            %             w_Brain(i,:) = w_Brain_Component' * COEFF';
        end
%         close (h)
    case 0 %equal to leave one out cross validation, LOOCV
        for i=1:K
%             waitbar(i/K,h,sprintf('%2.0f%%', i/K*100)) ;
            disp(['The inner was ' num2str(i),'/',num2str(K), ' fold!']);
            %K fold
            test_index = (indices == i); train_index = ~test_index;
            train_data =data_inmask(train_index,:);
            train_label = label(train_index,:);
            test_data = data_inmask(test_index,:);
            test_label = label(test_index);
            label_ForPerformance(i)=test_label;
            %% ��ά����һ��
            %���ɷֽ�ά
            [COEFF, train_data] = pca(train_data);%�ֱ��ѵ�����������������������ɷֽ�ά��
            test_data = test_data*COEFF;
            %���з����һ��
            % [train_data,test_data,~] = ...
            %    scaleForSVM(train_data,test_data,0,1);%һ���з����һ�����˴������飬����ʵ�ʽǶ���˵���ǿ��Եġ�
            [train_data,PS] = mapminmax(train_data');
            train_data=train_data';
            test_data = mapminmax('apply',test_data',PS);
            test_data =test_data';
            %% ѵ��ģ��
            model= fitclinear(train_data,train_label);
            %%
            [predict_label, dec_values] = predict(model,test_data);
            Decision{i}=dec_values(:,2);
            Predict(i,1)=predict_label;
            %             %%  �ռ��б�ģʽ
            %             w_Brain_Component = model.Beta;
            %             w_Brain(i,:) = w_Brain_Component' * COEFF';
            %         end
            % end
            % %% ƽ���Ŀռ��б�ģʽ
            % W_mean=mean(w_Brain);%ȡ����LOOVC��w_brain��ƽ��ֵ
            % w_M_Brain(implicitmask)=W_mean;
        end
%         close (h)
end
performances=mean([Accuracy,Sensitivity, Specificity, PPV, NPV,AUC]);
end

