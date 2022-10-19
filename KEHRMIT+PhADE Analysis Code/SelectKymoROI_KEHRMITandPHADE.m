function SelectKymoROI_KEHRMITandPHADE()
% This function lets the user view the kymograms of previously selected
% molecules, and allows the user to select regions of interest (ROIs) in those
% kymograms for further analysis. Typically we select ROIs for CMG velocity analysis. 
% The user can select two types of ROIs:
%  - Type 1: a single CMG (KEHRMIT), or a single replication fork (PHADE)
%  - Type 2: two CMGs (KEHRMIT), or two replication forks (PHADE)
%
% USE: SelectKymoROI_KEHRMITandPHADE()
%
% Gheorghe Chistol, 2020-01-04

%% For Convenience Change the Defaults Here
CLimKehrmit = [1400 2000];
CLimPhade   = [17500 22000];
    
    %% load the Analysis Folder, pick the file of interest, and load UserData
    temp = load('AnalysisPath.mat'); AnalysisPath = temp.AnalysisPath; clear temp;
    [fname, folder] = uigetfile([AnalysisPath filesep '*_KymoKaP.mat'], 'Pick a File with Molecule Selections and Kymograms'); disp(fname);
    temp = load([folder filesep fname],'UserData'); UserData = temp.UserData; clear temp;
    
    %% check if there is already a KaP ROI selection file 

    if exist([folder filesep fname(1:end-4) '_ROI.mat'],'file') %the roi selection file exists
        disp('Loading Existing KaP_ROI File');
        disp([folder filesep fname(1:end-4) '_ROI.mat']);
        temp = load([folder filesep fname(1:end-4) '_ROI.mat'],'UserData'); UserData = temp.UserData; clear temp;        
    else %the roi selection doesn't exist
        UserData.ROI           = cell(length(UserData.Kymogram)); %pre-allocate cells for ROI selections for each molecule
        UserData.SelectionType = cell(length(UserData.Kymogram));
    end
    UserData.CurrMol       = 1;
    
    UserData.KymoMode      = 'Default'; %defa
    figure;imshow([0],'Border','tight');
    set(gcf,'UserData',UserData); %save the movie to the axis for later access
    set(gcf,'KeyReleaseFcn','SelectKymoROI_KEHRMITandPHADE_KeyReleaseFcn');

    %set FolderName and FileName to figure for later use
    FileName = fname(1:end-4); %no extension
    set(gcf,'Name',FileName); %FileName
    set(gcf,'FileName',AnalysisPath); %FolderName
    %SelectKymoROI_KEHRMITandPHADE_UpdateDisplay();
    %SelectKymoROI_KEHRMITandPHADE_KeyReleaseFcn('.'); %same as ">" = display the first molecule
     
    Kpanel = uipanel('Title','KEHRMIT Img','TitlePosition','centertop','FontSize',10,'Units','Normalized','Position',[0.8678    0.82   0.1252    0.1]);
             uicontrol('Parent',Kpanel,'Style','text','FontSize',9,'HorizontalAlignment','right','String','Black Pt','Units','Normalized',...
                       'Position',[0 0.5821    0.5769    0.2985]);
             uicontrol('Parent',Kpanel,'Style','text','FontSize',9,'HorizontalAlignment','right','String','White Pt','Units','Normalized',...
                       'Position',[0 0.1791    0.5769    0.2985]);
             uicontrol('Parent',Kpanel,'Tag','BlackPointKEHRMIT','Style','edit','FontSize',9,'String',num2str(CLimKehrmit(1)),'Units','Normalized',...
                       'Position', [0.6026    0.5821    0.3526    0.2985],'Callback','SelectKymoROI_KEHRMITandPHADE_UpdateDisplay');
             uicontrol('Parent',Kpanel,'Tag','WhitePointKEHRMIT','Style','edit','FontSize',9,'String',num2str(CLimKehrmit(2)),'Units','Normalized',...
                       'Position',[0.6026    0.1791    0.3526    0.2985],'Callback','SelectKymoROI_KEHRMITandPHADE_UpdateDisplay');
             
    Ppanel = uipanel('Title','PHADE Img','TitlePosition','centertop','FontSize',10,'Units','Normalized',...
                     'Position',[0.8678 0.71 0.1252 0.1]);
             uicontrol('Parent',Ppanel,'Style','text','FontSize',9,'HorizontalAlignment','right','String','Black Pt','Units','Normalized',...
                       'Position',[0 0.5821 0.5769 0.2985]);
             uicontrol('Parent',Ppanel,'Style','text','FontSize',9,'HorizontalAlignment','right','String','White Pt','Units','Normalized',...
                       'Position',[0 0.1791 0.5769 0.2985]);
             uicontrol('Parent',Ppanel,'Tag','BlackPointPHADE','Style','edit','FontSize',9,'String',num2str(CLimPhade(1)),'Units','Normalized',...
                       'Position', [0.6026 0.5821 0.3526 0.2985],'Callback','SelectKymoROI_KEHRMITandPHADE_UpdateDisplay');
             uicontrol('Parent',Ppanel,'Tag','WhitePointPHADE','Style','edit','FontSize',9,'String',num2str(CLimPhade(2)),'Units','Normalized',...
                       'Position',[0.6026 0.1791 0.3526 0.2985],'Callback','SelectKymoROI_KEHRMITandPHADE_UpdateDisplay');
    
    Display = uibuttongroup('Title','Display','Tag','DisplayMode','TitlePosition','centertop','FontSize',10,'Visible','on','Units','Normalized',...
                            'Position',[0.8678 0.6 0.1252 0.1],'SelectionChangedFcn','SelectKymoROI_KEHRMITandPHADE_UpdateDisplay');
              uicontrol('Parent',Display,'Tag','DisplayKEHRMIT','Style','radiobutton','String','KEHRMIT','FontSize',9,...
                        'Units','Normalized','Position',[0.0577 0.6883 0.9615 0.2597],'Value',0);
              uicontrol('Parent',Display,'Tag','DisplayPHADE','Style','radiobutton','String','PHADE','FontSize',9,...
                        'Units','Normalized','Position',[0.0577 0.4026 0.9615 0.2597],'Value',0);
              uicontrol('Parent',Display,'Tag','DisplayBOTH','Style','radiobutton','String','Both','FontSize',9,...
                        'Units','Normalized','Position',[0.0577 0.1169 0.9615 0.2597],'Value',1);
             
    %show textbox with all the commands listed
    Tpanel = uipanel('Title','Keyboard Shortcuts','TitlePosition','centertop','FontSize',11,'Units','normalized',...
                     'Position',[0.75 0.01 0.24 0.5]);
             uicontrol('Parent',Tpanel,'Style','text','FontSize',10,'HorizontalAlignment','left','Units','normalized',...
                       'Position',[0.0385 0.0570 0.9615 0.9177],...
                       'String',{'[>] - next molecule' ...
                                 '[<] - prev molecule' ...
                                 '[1] - ROI with 1 fork' ...
                                 '[2] - ROI with 2 forks' ...
                                 '[r] - remove all ROIs' ...
                                 '[w] - image width' ...
                                 '[g] - show the 3-Color Summary' ...
                                 '[c] - Copy 3-Color Img to clipboard' ...
                                 '[m] - kymo display mode Default <-> OneLine' ...
                                 '[e] - save and exit' ...
                                 '[Shift+Windows+S] - take screenshot' });
                             
    set(gcf,'Units','normalized','Position',[0.0005    0.0285    0.4990    0.9125]);
    set(gca,'Units','normalized','Position',[0.0563    0.0373    0.8028    0.9246]);
    SelectKymoROI_KEHRMITandPHADE_UpdateDisplay();
    axis image; %fill the current axes with the image
    set(gca,'DataAspectRatioMode','manual','DataAspectRatio',[1 3 1]);

end