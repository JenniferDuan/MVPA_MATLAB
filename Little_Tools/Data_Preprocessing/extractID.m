%extract scan ID of oldname
% ID λ���������'_'֮�䣬������������޸�
name=OldName';
    for i=1:length(name)
        loc_=find(name{i}=='_');%�����»���λ��
        loc_star=loc_(end-1)+1;%ID
        loc_end=loc_(end)-1;
        ID{i}=name{i}(loc_star: loc_end);
    end
    %save
path_ID=uigetdir({},'ID���λ��');
path_ID=[path_ID,filesep,'ID.mat'];
save(path_ID,'ID')