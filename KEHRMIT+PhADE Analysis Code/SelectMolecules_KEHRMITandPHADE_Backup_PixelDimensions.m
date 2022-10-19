function SelectMolecules_KEHRMITandPHADE(Mode)
% This script is used to select replication bubbles from KEHRMIT+PHADE movies 
% Open a multi-page tiff that has been stabilized in ImageJ and select molecules
%
% USE: SelectMolecules_KEHRMITandPHADE('KEHRMIT')       for KEHRMIT only data
%      SelectMolecules_KEHRMITandPHADE('PHADE')         for PHADE only data
%      SelectMolecules_KEHRMITandPHADE('KEHRMIT+PHADE') for KEHRMIT+PHADE data
%
% Gheorghe Chistol, 02 Jan 2020

BackgrSubtrFilter  = 30;
MaxProjGaussFilter = 3;

temp = load('RawDataPath.mat');  RawDataPath  = temp.RawDataPath; clear temp;
temp = load('AnalysisPath.mat'); AnalysisPath = temp.AnalysisPath; clear temp;
[MovieFile, MovieFolder] = uigetfile([RawDataPath filesep '*.tif'], ['Pick a Stabilized ' Mode 'Movie']);
Movie = SelectMolecules_KEHRMITandPHADE_LoadMovie(MovieFile, MovieFolder);

%% Load the Data and Perform Some Basic Image Processing
if strcmp(Mode,'KEHRMIT')
    RawCmgMovie = Movie([1:1:end]);    %every single frame contains CMG data
    RawFenMovie = NaN; FenMovie = NaN; %non-existent data
    [CmgMovie, ~] = SelectMolecules_KEHRMITandPHADE_SubtractBackground(RawCmgMovie, BackgrSubtrFilter); %subtract any uneven background
    CmgMaxProj = SelectMolecules_KEHRMITandPHADE_ZProjectMax(CmgMovie,MaxProjGaussFilter);
    FenMaxProj = NaN;
elseif strcmp(Mode,'PHADE')
    RawFenMovie = Movie([1:1:end]);    %every single frame contains Fen1 data
    RawCmgMovie = NaN; CmgMovie = NaN; %non-existent data
    [FenMovie, ~] = SelectMolecules_KEHRMITandPHADE_SubtractBackground(RawFenMovie, BackgrSubtrFilter);
    FenMaxProj = SelectMolecules_KEHRMITandPHADE_ZProjectMax(FenMovie,MaxProjGaussFilter);
    CmgMaxProj = NaN;
elseif strcmp(Mode,'KEHRMIT+PHADE')
    RawCmgMovie = Movie([1:2:end]); %odd frames contain CMG data
    RawFenMovie = Movie([2:2:end]); %even frames contain Fen1 data
    [FenMovie, ~] = SelectMolecules_KEHRMITandPHADE_SubtractBackground(RawFenMovie, BackgrSubtrFilter);
    [CmgMovie, ~] = SelectMolecules_KEHRMITandPHADE_SubtractBackground(RawCmgMovie, BackgrSubtrFilter);
    CmgMaxProj = SelectMolecules_KEHRMITandPHADE_ZProjectMax(CmgMovie,MaxProjGaussFilter);
    FenMaxProj = SelectMolecules_KEHRMITandPHADE_ZProjectMax(FenMovie,MaxProjGaussFilter);
else
    disp('Invalid Mode Selected.'); beep; return;
end

%% Window/GUI dimensions designed for a Dell 27inch monitor 2560x1440px
    figure; imshow(ones(512,512)); 
    set(gcf,'Units','Pixels','Position',[2 42 1278 1314]);
    set(gca,'Units','Pixels','Position',[11 181 1088 1151]); %set(gca,'FontSize',14);

    Kpanel = uipanel('Title','KEHRMIT Image','TitlePosition','centertop','FontSize',12,'Units','Pixels','Position',[1110 1220 160 90]);
             uicontrol('Parent',Kpanel,'Style','text','FontSize',11,'HorizontalAlignment','right','String','Black Point','Units','Pixels','Position',[0 40 90 20]);
             uicontrol('Parent',Kpanel,'Style','text','FontSize',11,'HorizontalAlignment','right','String','White Point','Units','Pixels','Position',[0 13 90 20]);
             uicontrol('Parent',Kpanel,'Tag','BlackPointKEHRMIT','Style','edit','FontSize',11,'String','500','Units','Pixels','Position',[95 40 55 20],'Callback','SelectMolecules_KEHRMITandPHADE_UpdateDisplay');
             uicontrol('Parent',Kpanel,'Tag','WhitePointKEHRMIT','Style','edit','FontSize',11,'String','4000','Units','Pixels','Position',[95 13 55 20],'Callback','SelectMolecules_KEHRMITandPHADE_UpdateDisplay');
             
    Ppanel = uipanel('Title','PHADE Image','TitlePosition','centertop','FontSize',12,'Units','Pixels','Position',[1110 1120 160 90]);
             uicontrol('Parent',Ppanel,'Style','text','FontSize',11,'HorizontalAlignment','right','String','Black Point','Units','Pixels','Position',[0 40 90 20]);
             uicontrol('Parent',Ppanel,'Style','text','FontSize',11,'HorizontalAlignment','right','String','White Point','Units','Pixels','Position',[0 13 90 20]);
             uicontrol('Parent',Ppanel,'Tag','BlackPointPHADE','Style','edit','FontSize',11,'String','1000','Units','Pixels','Position',[95 40 55 20],'Callback','SelectMolecules_KEHRMITandPHADE_UpdateDisplay');
             uicontrol('Parent',Ppanel,'Tag','WhitePointPHADE','Style','edit','FontSize',11,'String','10000','Units','Pixels','Position',[95 13 55 20],'Callback','SelectMolecules_KEHRMITandPHADE_UpdateDisplay');
    
    Display = uibuttongroup('Title','Display','Tag','DisplayMode','TitlePosition','centertop','FontSize',12,'Visible','on','Units','Pixels','Position',[1110 1010 160 100],'SelectionChangedFcn','SelectMolecules_KEHRMITandPHADE_UpdateDisplay');
              uicontrol('Parent',Display,'Tag','DisplayKEHRMIT','Style','radiobutton','String','KEHRMIT Only','FontSize',11,'Position',[10 54 150 20],'Value',1);
              uicontrol('Parent',Display,'Tag','DisplayPHADE','Style','radiobutton','String','PHADE Only','FontSize',11,'Position',[10 32 150 20],'Value',0);
              uicontrol('Parent',Display,'Tag','DisplayBOTH','Style','radiobutton','String','Both','FontSize',11,'Position',[10 10 150 20],'Value',0);

    Tpanel = uipanel('Title','Keyboard Shortcuts','TitlePosition','centertop','FontSize',12,'Units','Pixels','Position',[1110 820 160 180]);
             uicontrol('Parent',Tpanel,'Style','text','FontSize',11,'HorizontalAlignment','left','Position',[7 10 150 145],...
                       'String',{'[n] - new selection' '[r] - remove selection' '[z] - zoom in' ...
                                 '[o] - zoom out' '[m] - max projection' '[p] - play movie' ...
                                 '[h] - change highlights' '[s] - save and exit'})

    %disable certain options if only KEHRMIT or only PHADE data is available                             
    if strcmp(Mode,'KEHRMIT')
       set(findobj(gcf,'Tag','DisplayKEHRMIT'),'Value',1); 
       set(findobj(gcf,'Tag','DisplayPHADE'),'Enable','off'); 
       set(findobj(gcf,'Tag','DisplayBOTH'),'Enable','off');
       set(findobj(gcf,'Tag','WhitePointPHADE'),'Enable','off');
       set(findobj(gcf,'Tag','BlackPointPHADE'),'Enable','off');

       %set(findobj(gcf,'Type','image'),'CData',CmgMaxProj);
       %set(gca,'CLim',[1e3 1.5e4]);
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
        UserData.CLim           = [500 2000]; %black/white point for the KEHRMIT movie
        UserData.CLim2          = [500 2000];
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
end
