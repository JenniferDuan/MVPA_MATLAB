function [indiceCell]=LoadIndices()
% �������еĽ�����֤��ʽ
[file_name_indices,path_source_indices,~] = uigetfile({'*.mat;','All Image Files';...
    '*.*','All Files'},'MultiSelect','off','��ѡ�� *MVPA.mat');
indices_structure=load([path_source_indices,char(file_name_indices)]);
indiceCell=indices_structure.indiceCell;
end