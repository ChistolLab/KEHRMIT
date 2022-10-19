function SelectKymoROI_KEHRMITandPHADE_DisplayCurrMolecule(UserData)
% This is a helper function to SelectKymoROI_KEHRMITandPHADE()
% This function is used when the "next molecule" or "previous
% molecule" commands are issued to display the current molecule kymogram and ROIs.
%
% USE: SelectKymoROI_KEHRMITandPHADE_DisplayCurrMolecule(UserData)
%
% Gheorghe Chistol, 2020-01-04
    clear UserData;
    UserData = get(gcf,'UserData');

    TotalMol      = length(UserData.Kymogram);
    CurrMol       = UserData.CurrMol; %current molecule
    Kymogram      = UserData.Kymogram{CurrMol};  %KEHRMIT signal
    Kymogram2     = UserData.Kymogram2{CurrMol}; %PHADE signal
    CLim          = UserData.CLim;  %black/white point for the KEHRMIT image
    CLim2         = UserData.CLim2; %black/white point for the PHADE image
    Mode          = UserData.Mode;  %'KEHRMIT', 'PHADE', or 'KEHRMIT+PHADE'
    ROI           = UserData.ROI{CurrMol}; %there could be 1-2 or there could be none
    SelectionType = UserData.SelectionType{CurrMol}; %either 'single' or 'double'
    
    if strcmp(Mode,'PHADE')
        [Rows, ~] = size(Kymogram2); %how many rows of pixels are in each kymogram
        FrameN    = length(UserData.KymogramMovie2{CurrMol});
    else %KEHRMIT or KEHRMIT+PHADE
        [Rows, ~] = size(Kymogram); %how many rows of pixels are in each kymogram
        FrameN    = length(UserData.KymogramMovie{CurrMol});
    end
    
    Hframe = Rows/FrameN;    %height of each frame in pixels
    SelectKymoROI_KEHRMITandPHADE_DisplayKymo(Kymogram,Kymogram2,CLim,CLim2,Mode); %show the kymogram in the window
    SelectKymoROI_KEHRMITandPHADE_DisplayROI(ROI,SelectionType,Hframe);            %show the regions of interest (ROIs) over the kymogram
    
    FileName = get(gcf,'Name'); %FileName
    title([FileName ', Molecule #' num2str(CurrMol) '/' num2str(TotalMol)],'Interpreter','none'); %display the filename in the title of the figure
    set(gca,'ToolBar',[]); %disable the toolbar
    %ylabel('Frame Number');
end