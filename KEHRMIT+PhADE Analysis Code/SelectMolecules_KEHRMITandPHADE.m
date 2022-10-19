function SelectMolecules_KEHRMITandPHADE(Mode)
% This script is used to select replication bubbles from KEHRMIT+PHADE movies 
% Open a multi-page tiff that has been stabilized in ImageJ and select molecules
%
% USE: SelectMolecules_KEHRMITandPHADE('KEHRMIT')       for KEHRMIT only data
%      SelectMolecules_KEHRMITandPHADE('PHADE')         for PHADE only data
%      SelectMolecules_KEHRMITandPHADE('KEHRMIT+PHADE') for KEHRMIT+PHADE data
%
% Gheorghe Chistol, 02 Jan 2020

%% For Convenience Change the Defaults Here
CLimKehrmit = [3000 6000];
CLimPhade   = [1500 5000];

%% Filtering Parameters for Background Subtraction and for Smoothing
BackgrSubtrFilter  = 20;
MaxProjGaussFilter = 2;

temp = load('RawDataPath.mat');  RawDataPath  = temp.RawDataPath; clear temp;
temp = load('AnalysisPath.mat'); AnalysisPath = temp.AnalysisPath; clear temp;
[MovieFile, MovieFolder] = uigetfile([RawDataPath filesep '*.tif'], ['Pick a Stabilized ' Mode 'Movie']);
Movie = SelectMolecules_KEHRMITandPHADE_LoadMovie(MovieFile, MovieFolder);

%% Load the Data and Perform Some Basic Image Processing
if strcmp(Mode,'KEHRMIT')
    RawCmgMovie   = Movie([1:1:end]);    %every single frame contains CMG data
    RawFenMovie   = NaN; FenMovie = NaN; %non-existent data
    [CmgMovie, ~] = SelectMolecules_KEHRMITandPHADE_SubtractBackground(RawCmgMovie, BackgrSubtrFilter); %subtract any uneven background
    CmgMaxProj    = SelectMolecules_KEHRMITandPHADE_ZProjectMax(CmgMovie,MaxProjGaussFilter);
    FenMaxProj    = NaN;
elseif strcmp(Mode,'PHADE')
    RawFenMovie   = Movie([1:1:end]);    %every single frame contains Fen1 data
    RawCmgMovie   = NaN; CmgMovie = NaN; %non-existent data
    [FenMovie, ~] = SelectMolecules_KEHRMITandPHADE_SubtractBackground(RawFenMovie, BackgrSubtrFilter);
    FenMaxProj    = SelectMolecules_KEHRMITandPHADE_ZProjectMax(FenMovie,MaxProjGaussFilter);
    CmgMaxProj    = NaN;
elseif strcmp(Mode,'KEHRMIT+PHADE')
    RawCmgMovie   = Movie([1:2:end]); %even frames contain TopBP1 data
    RawFenMovie   = Movie([2:2:end]); %odd frames contain PhADE data
    [FenMovie, ~] = SelectMolecules_KEHRMITandPHADE_SubtractBackground(RawFenMovie, BackgrSubtrFilter);
    [CmgMovie, ~] = SelectMolecules_KEHRMITandPHADE_SubtractBackground(RawCmgMovie, BackgrSubtrFilter);
    CmgMaxProj    = SelectMolecules_KEHRMITandPHADE_ZProjectMax(CmgMovie,MaxProjGaussFilter);
    FenMaxProj    = SelectMolecules_KEHRMITandPHADE_ZProjectMax(FenMovie,MaxProjGaussFilter);
else
    disp('Invalid Mode Selected.'); beep; return;
end

%% Window/GUI dimensions
    figure; imshow(ones(512,512)); 
    set(gcf,'Units','Normalized','Position',[0.000 0.027 0.53 0.877]);
    set(gca,'Units','Normalized','Position',[0.008 0.008 0.85 0.99]);

    Kpanel = uipanel('Title','KEHRMIT Img','TitlePosition','centertop','FontSize',10,...
                     'Units','Normalized','Position',[0.8678    0.82   0.1252    0.1]);
             uicontrol('Parent',Kpanel,'Style','text','FontSize',9,'HorizontalAlignment','right','String','Black Pt', ...
                       'Units','Normalized', 'Position',[0 0.5821    0.5769    0.2985]);
             uicontrol('Parent',Kpanel,'Style','text','FontSize',9,'HorizontalAlignment','right','String','White Pt',...
                       'Units','Normalized','Position',[0 0.1791    0.5769    0.2985]);
             uicontrol('Parent',Kpanel,'Tag','BlackPointKEHRMIT','Style','edit','FontSize',9,'String',num2str(min(CLimKehrmit)),...
                       'Units','Normalized','Position', [0.6026    0.5821    0.3526    0.2985],...
                       'Callback','SelectMolecules_KEHRMITandPHADE_UpdateDisplay');
             uicontrol('Parent',Kpanel,'Tag','WhitePointKEHRMIT','Style','edit','FontSize',9,'String',num2str(max(CLimKehrmit)),...
                       'Units','Normalized','Position',[0.6026    0.1791    0.3526    0.2985],...
                       'Callback','SelectMolecules_KEHRMITandPHADE_UpdateDisplay');
             
    Ppanel = uipanel('Title','PHADE Img','TitlePosition','centertop','FontSize',10,'Units','Normalized',...
                     'Position',[0.8678    0.71    0.1252    0.1]);
             uicontrol('Parent',Ppanel,'Style','text','FontSize',9,'HorizontalAlignment','right','String','Black Pt',...
                       'Units','Normalized','Position',[0 0.5821    0.5769    0.2985]);
             uicontrol('Parent',Ppanel,'Style','text','FontSize',9,'HorizontalAlignment','right','String','White Pt',...
                       'Units','Normalized','Position',[0 0.1791    0.5769    0.2985]);
             uicontrol('Parent',Ppanel,'Tag','BlackPointPHADE','Style','edit','FontSize',9,'String',num2str(min(CLimPhade)),...
                       'Units','Normalized','Position', [0.6026    0.5821    0.3526    0.2985],...
                       'Callback','SelectMolecules_KEHRMITandPHADE_UpdateDisplay');
             uicontrol('Parent',Ppanel,'Tag','WhitePointPHADE','Style','edit','FontSize',9,'String',num2str(max(CLimPhade)),...
                       'Units','Normalized','Position',[0.6026    0.1791    0.3526    0.2985],...
                       'Callback','SelectMolecules_KEHRMITandPHADE_UpdateDisplay');
    
    Display = uibuttongroup('Title','Display','Tag','DisplayMode','TitlePosition','centertop','FontSize',10,'Visible','on',...
                            'Units','Normalized','Position',[0.8678    0.6   0.1252    0.1],...
                            'SelectionChangedFcn','SelectMolecules_KEHRMITandPHADE_UpdateDisplay');
              uicontrol('Parent',Display,'Tag','DisplayKEHRMIT','Style','radiobutton','String','KEHRMIT','FontSize',9,...
                        'Units','Normalized','Position',[0.0577    0.6883    0.9615    0.2597],'Value',1);
              uicontrol('Parent',Display,'Tag','DisplayPHADE','Style','radiobutton','String','PHADE','FontSize',9,...
                        'Units','Normalized','Position',[0.0577    0.4026    0.9615    0.2597],'Value',0);
              uicontrol('Parent',Display,'Tag','DisplayBOTH','Style','radiobutton','String','Both','FontSize',9,...
                        'Units','Normalized','Position',[0.0577    0.1169    0.9615    0.2597],'Value',0);

    Tpanel = uipanel('Title','Shortcuts','TitlePosition','centertop','FontSize',10,'Units','Normalized',...
                     'Position',[0.8678    0.09   0.1252    0.3]);
             uicontrol('Parent',Tpanel,'Style','text','FontSize',8,'HorizontalAlignment','left','Units','Normalized',...
                       'Position',[0.0385    0.0570    0.9615    0.9177],...
                       'String',{'[n] - new selection' ...
                                 '[r] - remove selection' ...
                                 '[z] - zoom in' ...
                                 '[o] - zoom out' ...
                                 '[m] - max projection' ...
                                 '[p] - play movie' ...
                                 '[h] - change highlights' ...
                                 '[s] - save and exit'})
    
    %% Disable certain options if only KEHRMIT or only PHADE data is available                             
    if strcmp(Mode,'KEHRMIT')
       set(findobj(gcf,'Tag','DisplayKEHRMIT'),'Value',1); 
       set(findobj(gcf,'Tag','DisplayPHADE'),'Enable','off'); 
       set(findobj(gcf,'Tag','DisplayBOTH'),'Enable','off');
       set(findobj(gcf,'Tag','WhitePointPHADE'),'Enable','off');
       set(findobj(gcf,'Tag','BlackPointPHADE'),'Enable','off');
    elseif strcmp(Mode,'PHADE')
       set(findobj(gcf,'Tag','DisplayPHADE'),'Value',1); 
       set(findobj(gcf,'Tag','DisplayKEHRMIT'),'Enable','off'); 
       set(findobj(gcf,'Tag','DisplayBOTH'),'Enable','off');
       set(findobj(gcf,'Tag','WhitePointKEHRMIT'),'Enable','off');
       set(findobj(gcf,'Tag','BlackPointKEHRMIT'),'Enable','off');    
    end

%% Create Data Structures    
    UserData.Mode           = Mode;
    UserData.Movie          = CmgMovie(1:end); %movie with adjusted background
    UserData.Movie2         = FenMovie(1:end); %movie with adjusted background
    UserData.MaxProj        = CmgMaxProj; %maximum projection image
    UserData.MaxProj2       = FenMaxProj; %maximum projection image
    UserData.SelectX        = {};  %the x coordinates of each molecule selection
    UserData.SelectY        = {};  %the y coordinates of each molecule selection
    UserData.SelectH        = {};  %the object handles for each molecule selection (for display on the figure)
    UserData.Kymogram       = {};  %one kymogram will be generated from each selected molecule
    UserData.KymogramMovie  = {};  %one kymogram movie will be generated from each selected molecule
    UserData.Kymogram2      = {};  %one kymogram will be generated from each selected molecule
    UserData.KymogramMovie2 = {};  %one kymogram movie will be generated from each selected molecule
    UserData.CLim           = NaN; %black/white points, refers to the KEHRMIT movie, will be set later
    UserData.CLim2          = NaN; %black/white points, refers to the PHADE movie, will be set later
    
    set(gcf,'UserData',UserData);       %save the movie to the axis for later access
    set(gcf,'Name',MovieFile(1:end-4)); %FileName no extension
    set(gcf,'FileName',AnalysisPath);   %FolderName
    set(gcf,'KeyReleaseFcn','SelectMolecules_KEHRMITandPHADE_KeyReleaseFcn');

    SelectMolecules_KEHRMITandPHADE_UpdateDisplay(); %refresh the display, show max projection
    
    title(MovieFile,'Interpreter','none');
    set(gca,'ToolBar',[]); %disable the toolbar
%% If a file with molecule selections already exists - load it!
    FileName   = get(gcf,'Name');     %file name w/o extension
    FolderName = get(gcf,'FileName'); %FolderName
    if ~exist([FolderName filesep FileName '_KymoKaP.mat'],'file')
        return;
    end
    
    disp(['Existing ROI Selections loaded from ' FileName '_KymoKaP.mat']);
    temp = load([FolderName filesep FileName '_KymoKaP.mat'],'UserData'); %UserData Should be Inside
    OldUserData = temp.UserData; clear temp;
    %update the current user data from the old user data
    UserData.SelectX        = OldUserData.SelectX;
    UserData.SelectY        = OldUserData.SelectY;
    UserData.Kymogram       = OldUserData.Kymogram;
    
    if isfield(OldUserData,'Kymogram2')
        UserData.Kymogram2      = OldUserData.Kymogram2;
    else
        UserData.Kymogram2      = OldUserData.Kymogram;
    end
    
    UserData.KymogramMovie  = OldUserData.KymogramMovie;
    
    if isfield(OldUserData,'KymogramMovie2')
        UserData.KymogramMovie2 = OldUserData.KymogramMovie2;
    else
        UserData.KymogramMovie2 = OldUserData.KymogramMovie;
    end

    if isfield(OldUserData,'CLim')
        UserData.CLim           = OldUserData.CLim; %black/white point for the KEHRMIT movie
        UserData.CLim2          = OldUserData.CLim2; %black/white point for the PHADE movie
    else
        UserData.CLim           = CLimKehrmit; 
        UserData.CLim2          = CLimPhade;
    end
    
    clear OldUserData;
    set(findobj(gcf,'Tag','WhitePointKEHRMIT'),'String',num2str(max(UserData.CLim))); %update the text boxes
    set(findobj(gcf,'Tag','BlackPointKEHRMIT'),'String',num2str(min(UserData.CLim))); %update the text boxes
    set(findobj(gcf,'Tag','WhitePointPHADE'),'String',num2str(max(UserData.CLim2))); %update the text boxes
    set(findobj(gcf,'Tag','BlackPointPHADE'),'String',num2str(min(UserData.CLim2))); %update the text boxes
    
    %plot all the existing molecule selections
    hold on; 
    for i=1:length(UserData.SelectX)
        UserData.SelectH{i} = plot(UserData.SelectX{i},UserData.SelectY{i},'c-','LineWidth',3);
        x=mean(UserData.SelectX{i});
        y=mean(UserData.SelectY{i});
        T = num2str(i);
        text(x,y-4,T,'Color','w');
    end
    
    set(gcf,'UserData',UserData);       %save the movie to the axis for later access
    SelectMolecules_KEHRMITandPHADE_UpdateDisplay(); %refresh the display, show max projection
    set(gca,'ToolBar',[]); %disable the toolbar
end
