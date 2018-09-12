function scatter_line_gui()
%����ʽ����ɢ��ͼ
%email:lichao19870617@gmail.com
%please feel free to contact me
close all
fig = figure('Name','�������Ա�����Ӧ����',...
    'MenuBar','none', ...
    'Toolbar','none', ...
    'NumberTitle','off', ...
    'Resize', 'off', ...
    'Position',[500,500,420,130]); %X,Y then Width, Height
set(fig, 'Color', ([50,200,50] ./255));
% ��ʶ���
xp=-90;yp=5;
%input
uipanel('Title','�Ա���x:','BackgroundColor','white','Units','Pixels','Position',[100+xp 85+yp 350 20]);
uipanel('Title','Ӧ����y:','BackgroundColor','white','Units','Pixels','Position',[100+xp 45+yp 350 20]);
% load
uipanel('Title','load','BackgroundColor','white','Units','Pixels','Position',[470+xp 80+yp 30 30]);
% �������
%input
x=uicontrol('Style','edit','HorizontalAlignment','left','String','','Position',[150+xp 80+yp 300 30]);
y=uicontrol('Style','edit','HorizontalAlignment','left','String','','Position',[150+xp 40+yp 300 30]);
% load
uicontrol('Style','PushButton','HorizontalAlignment','left','String','','Position',[470+xp 80+yp 30 15],...
    'Callback',@load_data);
% �������
uicontrol('Style','PushButton','BackgroundColor','[ 1 .3 .3]','HorizontalAlignment','center','String','Run',...
    'Position',[300+xp yp 30 30],...
    'Callback',{@scatter_linearfit,[x,y]});

    function load_data(~,~)
        [file_name1,path_source1,~] = uigetfile({'*.xlsx;*.xls;*.txt','All Image Files';...
            '*.*','All Files'},'MultiSelect','on','��Ҫ���ص�����');
        try
        data=xlsread(fullfile(path_source1,file_name1));
        catch
         data=load((fullfile(path_source1,file_name1)));
        end
        x=double(data(:,1));
        y=double(data(:,2));
        % �������
        uicontrol('Style','PushButton','BackgroundColor','[ 1 .3 .3]','HorizontalAlignment','center','String','Run',...
            'Position',[300+xp yp 30 30],...
            'Callback',{@scatter_linearfit,[x,y]});
    end

%% ===================ɢ��ͼ����С�������ֱ��======================
    function scatter_linearfit(~,~,uis)
        % ��ȡx��y��ֵ
        try
            x1=str2num(get(uis(1),'String'));
            y1=str2num(get(uis(2),'String'));
        catch
            x1=uis(:,1);
            y1=uis(:,2);
        end
        x1=reshape(x1,numel(x1),1);
        y1=reshape(y1,numel(y1),1);
        % ɢ��ͼ�����ֱ��
        fig=figure;
        global  scatter_plot
        scatter_plot=scatter(x1,y1,50,'Marker','o',...
            'MarkerEdgeColor','k','MarkerFaceColor','w','LineWidth',2);
%         set(gca,'xtick',(min(x1):(max(x1)-min(x1))/10:max(x1)));
%         set(gca,'ytick',(min(y1):(max(y1)-min(y1))/10:max(y1)));
        global line
        line=lsline;
        set(line,'LineWidth',2,'LineStyle','-','Color','k');
        set(gca,'FontSize',30);
        % �ߺ͵�Ŀ�����
        fig_scatter = figure('Name','�����ߺ͵�',...
            'MenuBar','none', ...
            'Toolbar','none', ...
            'NumberTitle','off', ...
            'Resize', 'off', ...
            'Position',[10,400,250,300]); %X,Y then Width, Height
        set(fig_scatter, 'Color', ([50,200,50] ./255));
        % �ߺ͵�����ñ�ʶ���
        xp=0;yp=80;
        %column 1
        uipanel('Title','����','BackgroundColor','white','Units','Pixels','Position',[10+xp,150+yp,100,40]);
        uipanel('Title','�߿�','BackgroundColor','white','Units','Pixels','Position',[10+xp 80+yp 100 40]);
        uipanel('Title','����ɫ','BackgroundColor','white','Units','Pixels','Position',[10+xp 10+yp 100 40]);
        uipanel('Title','����ɢ��ͼ','BackgroundColor','white','Units','Pixels','Position',[10+xp -60+yp 100 40]);
        %column 2
        uipanel('Title','����','BackgroundColor','white','Units','Pixels','Position',[120+xp,150+yp,100,40]);
        uipanel('Title','���С','BackgroundColor','white','Units','Pixels','Position',[120+xp 80+yp 100 40]);
        uipanel('Title','�����ɫ','BackgroundColor','white','Units','Pixels','Position',[120+xp 10+yp 100 40]);
        uipanel('Title','������ɫ','BackgroundColor','white','Units','Pixels','Position',[120+xp -60+yp 100 40]);
        % �ߺ͵�Ŀ������
        % column1
        uicontrol('Style', 'popup','String', {'-','--',':','-.'},'Position', [10+xp,155+yp,80,20],...
            'Callback',@ControlFigure_line);
        uicontrol('Style', 'slider','Min',1,'Max',20,'Value',2,'Position', [10+xp,80+yp,80,20],...
            'Callback',@ControlFigure_line);
        uicontrol('Style', 'popup','String', {'r','g','b','y','m','c','w','k','free_color'},'Position', [10+xp,15+yp,80,20],...
            'Callback',@ControlFigure_line);
        uicontrol('Style','PushButton','BackgroundColor','white','HorizontalAlignment','center','String','',...
            'Position',[10+xp,-60+yp,100,25],...
            'Callback',{@save_figure,fig});%����ɢ��ͼ
        % column2
        uicontrol('Style', 'popup','String', {'o','*','.','+','x','s','d','h','>','<'},'Position', [120+xp,155+yp,80,20],...
            'Callback',@ControlFigure_dot);
        uicontrol('Style', 'slider','Min',10,'Max',5000,'Value',30,'Position', [120+xp,80+yp,80,20],...
            'Callback',@ControlFigure_dot);
        uicontrol('Style', 'popup','String',{'r','g','b','y','m','c','k','free_color'},'Position',[120+xp,15+yp,80,20],...
            'Callback',@ControlFigure_dot);
        uicontrol('Style', 'popup','String',{'r','g','b','y','m','c','k','w','free_color'},'Position',[120+xp -55+yp 80 20],...
            'Callback',@ControlFigure_dot);
    end
%% ====================������=====================================
    function ControlFigure_line(setting,~)
        strings = arrayfun(@(x) get(x,'String'),setting,'UniformOutput',false);
        global line
        if numel(strings{1})==4
            line.LineStyle=setting.String{setting.Value};
        elseif numel(strings{1})>4
            if strcmp(setting.String{setting.Value},'free_color')
                free_color('lineColor');
            else
                line.Color=setting.String{setting.Value};
            end
        else
            line.LineWidth=setting.Value;
        end
    end
%% ====================������=====================================
    function ControlFigure_dot(setting,~)
        strings = arrayfun(@(x) get(x,'String'),setting,'UniformOutput',false);
        global scatter_plot
        if numel(strings{1})==10
            scatter_plot.Marker=setting.String{setting.Value};
        elseif numel(strings{1})==9
            if strcmp(setting.String{setting.Value},'free_color')
                free_color('MarkerFaceColor');
            else
                scatter_plot.MarkerFaceColor=setting.String{setting.Value};
            end
        elseif numel(strings{1})==8
            if strcmp(setting.String{setting.Value},'free_color')
                free_color('MarkerEdgeColor');
            else
                scatter_plot.MarkerEdgeColor=setting.String{setting.Value};
            end
        else
            scatter_plot.SizeData =setting.Value;
        end
    end

%% =====================�����趨��ɫ===============================
    function free_color(which)
        char=which;
        fig_freecolor_name=char;
        % ���ݲ�ͬ�����ã�����λ�ú�����
        if strcmp(char,'lineColor')
            try
                close lineColor
            catch
            end
            position_value=[1000,530,250,200];
            fig_freecolor = figure('Name',fig_freecolor_name,...
                'MenuBar','none', ...
                'Toolbar','none', ...
                'NumberTitle','off', ...
                'Resize', 'off', ...
                'Position',position_value); %X,Y then Width, Height
            set(fig_freecolor, 'Color', ([50,200,50] ./255));
            % ���1
            uipanel('Title','R','BackgroundColor','white','Units','Pixels','Position',[10,150,220,30]);
            uipanel('Title','G','BackgroundColor','white','Units','Pixels','Position',[10,100,220,30]);
            uipanel('Title','B','BackgroundColor','white','Units','Pixels','Position',[10,50,220,30]);
            % ����1
            uicontrol('Style', 'slider','Min',0,'Max',255,'Value',10,'Position', [10,150,200,15],...
                'Callback',@obtain_FreeColor_Line_R);
            uicontrol('Style', 'slider','Min',0,'Max',255,'Value',10,'Position', [10,100,200,15],...
                'Callback',@obtain_FreeColor_Line_G);
            uicontrol('Style', 'slider','Min',0,'Max',255,'Value',10,'Position', [10,50,200,15],...
                'Callback',@obtain_FreeColor_Line_B);
        elseif strcmp(char,'MarkerFaceColor')
            try
                close MarkerFaceColor
            catch
            end
            position_value=[1000,290,250,200];
            fig_freecolor = figure('Name',fig_freecolor_name,...
                'MenuBar','none', ...
                'Toolbar','none', ...
                'NumberTitle','off', ...
                'Resize', 'off', ...
                'Position',position_value); %X,Y then Width, Height
            set(fig_freecolor, 'Color', ([50,200,50] ./255));
            % ���2
            uipanel('Title','R','BackgroundColor','white','Units','Pixels','Position',[10,150,220,30]);
            uipanel('Title','G','BackgroundColor','white','Units','Pixels','Position',[10,100,220,30]);
            uipanel('Title','B','BackgroundColor','white','Units','Pixels','Position',[10,50,220,30]);
            % ����2
            uicontrol('Style', 'slider','Min',0,'Max',255,'Value',10,'Position', [10,150,200,15],...
                'Callback',@obtain_FreeColor_Face_R);
            uicontrol('Style', 'slider','Min',0,'Max',255,'Value',10,'Position', [10,100,200,15],...
                'Callback',@obtain_FreeColor_Face_G);
            uicontrol('Style', 'slider','Min',0,'Max',255,'Value',10,'Position', [10,50,200,15],...
                'Callback',@obtain_FreeColor_Face_B);
        else
            try
                close MarkerEdgeColor
            catch
            end
            position_value=[1000,50,250,200];
            fig_freecolor = figure('Name',fig_freecolor_name,...
                'MenuBar','none', ...
                'Toolbar','none', ...
                'NumberTitle','off', ...
                'Resize', 'off', ...
                'Position',position_value); %X,Y then Width, Height
            set(fig_freecolor, 'Color', ([50,200,50] ./255));
            % ���3
            uipanel('Title','R','BackgroundColor','white','Units','Pixels','Position',[10,150,220,30]);
            uipanel('Title','G','BackgroundColor','white','Units','Pixels','Position',[10,100,220,30]);
            uipanel('Title','B','BackgroundColor','white','Units','Pixels','Position',[10,50,220,30]);
            % ����3
            uicontrol('Style', 'slider','Min',0,'Max',255,'Value',10,'Position', [10,150,200,15],...
                'Callback',@obtain_FreeColor_Edge_R);
            uicontrol('Style', 'slider','Min',0,'Max',255,'Value',10,'Position', [10,100,200,15],...
                'Callback',@obtain_FreeColor_Edge_G);
            uicontrol('Style', 'slider','Min',0,'Max',255,'Value',10,'Position', [10,50,200,15],...
                'Callback',@obtain_FreeColor_Edge_B);
        end
    end

%% =======================RGB====================================
% Line
    function obtain_FreeColor_Line_R(color,~)
        global line
        values_R = arrayfun(@(x) get(x,'Value'),color);
        line.Color(1)=values_R./255;
    end

    function obtain_FreeColor_Line_G(color,~)
        global line
        values_G = arrayfun(@(x) get(x,'Value'),color);
        line.Color(2)=values_G./255;
    end

    function obtain_FreeColor_Line_B(color,~)
        global line
        values_B = arrayfun(@(x) get(x,'Value'),color);
        line.Color(3)=values_B./255;
    end

% Face
    function obtain_FreeColor_Face_R(color,~)
        global scatter_plot
        values_R = arrayfun(@(x) get(x,'Value'),color);
        scatter_plot.MarkerFaceColor(1)=values_R./255;
    end

    function obtain_FreeColor_Face_G(color,~)
        global scatter_plot
        values_G = arrayfun(@(x) get(x,'Value'),color);
        scatter_plot.MarkerFaceColor(2)=values_G./255;
    end

    function obtain_FreeColor_Face_B(color,~)
        global scatter_plot
        values_B = arrayfun(@(x) get(x,'Value'),color);
        scatter_plot.MarkerFaceColor(3)=values_B./255;
    end
% Edge
    function obtain_FreeColor_Edge_R(color,~)
        global scatter_plot
        values_R = arrayfun(@(x) get(x,'Value'),color);
        scatter_plot.MarkerEdgeColor(1)=values_R./255;
    end

    function obtain_FreeColor_Edge_G(color,~)
        global scatter_plot
        values_G = arrayfun(@(x) get(x,'Value'),color);
        scatter_plot.MarkerEdgeColor(2)=values_G./255;
    end

    function obtain_FreeColor_Edge_B(color,~)
        global scatter_plot
        values_B = arrayfun(@(x) get(x,'Value'),color);
        scatter_plot.MarkerEdgeColor(3)=values_B./255;
    end
end

%% ====================save figure================================
function save_figure(~,~,fig)
outdir = uigetdir({},'Path of results');
cd(outdir);
fig.Visible = 'off';
fig.Position=[10   10   1500   800];
print(fig,'-dtiff','-r600','Scatter_Plot600dpi');
print(fig,'-dtiff','-r300','Scatter_Plot300dpi');
fig.Position=[50   50   800   500];
fig.Visible = 'on';
end
