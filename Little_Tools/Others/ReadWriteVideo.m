obj = VideoReader('J:\�Ͼ�\��Ƶ/VID_20180302_144906.mp4');%������Ƶλ��
numFrames = obj.NumberOfFrames;% ֡������
 % ��ȡǰN֡
 for k = round(obj.NumberOfFrames/3) :round(obj.NumberOfFrames/2)
     frame = read(obj,k);%��ȡ�ڼ�֡
    % imshow(frame);%��ʾ֡
      imwrite(frame,strcat('J:\�Ͼ�\��Ƶ\',num2str(k),'.jpg'),'jpg');% ����֡
 end