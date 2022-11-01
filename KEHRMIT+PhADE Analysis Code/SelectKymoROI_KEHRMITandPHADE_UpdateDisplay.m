function SelectKymoROI_KEHRMITandPHADE_UpdateDisplay()
% This is a helper function to SelectKymoROI_KEHRMITandPHADE()
% This function is used to update the display of the current molecule
% Generally used when changing Clim or color display preferences
%
% USE: SelectKymoROI_KEHRMITandPHADE_UpdateDisplay()
%
% Gheorghe Chistol, 31 Oct 2022

    UserData      = get(gcf,'UserData');
    TotalMol      = length(UserData.Kymogram);
    CurrMol       = UserData.CurrMol; %current molecule
    Kymogram      = UserData.Kymogram{CurrMol};  %KEHRMIT signal
    Kymogram2     = UserData.Kymogram2{CurrMol}; %PHADE signal
    ROI           = UserData.ROI{CurrMol}; %there could be 1-2 or there could be none
    SelectionType = UserData.SelectionType{CurrMol}; %either 'single' or 'double'
    
    %% Black/white point for the KEHRMIT image
    CLim(1) = str2double(get(findobj(gcf,'Tag','BlackPointKEHRMIT'),'String'));
    CLim(2) = str2double(get(findobj(gcf,'Tag','WhitePointKEHRMIT'),'String'));

    %% Black/white point for the PHADE image
    CLim2(1) = str2double(get(findobj(gcf,'Tag','BlackPointPHADE'),'String'));
    CLim2(2) = str2double(get(findobj(gcf,'Tag','WhitePointPHADE'),'String'));

    UserData.CLim  = CLim;  
    UserData.CLim2 = CLim2; 
    Mode           = UserData.Mode;  %'KEHRMIT', 'PHADE', or 'KEHRMIT+PHADE'
    ROI            = UserData.ROI{CurrMol}; %there could be 1-2 or there could be none
    SelectionType  = UserData.SelectionType{CurrMol}; %either 'single' or 'double'
    
    if strcmp(Mode,'PHADE')
        [Rows, ~] = size(Kymogram2); %how many rows of pixels are in each kymogram
        Nframes    = length(UserData.KymogramMovie2{CurrMol});
    elseif strcmp(Mode,'KEHRMIT+PHADE') || strcmp(Mode,'KEHRMIT')  
        [Rows, ~] = size(Kymogram); %how many rows of pixels are in each kymogram
        Nframes    = length(UserData.KymogramMovie{CurrMol});
    end
    
    Hframe           = Rows/Nframes; %height of each frame in pixels
    UserData.Hframe  = Hframe; 
    UserData.Nframes = Nframes;

        
    if strcmp(Mode,'KEHRMIT+PHADE')
        CmgKymogram = mat2gray(Kymogram,CLim); %apply the Black/White Point
        FenKymogram = mat2gray(Kymogram2,CLim2);  %apply the Black/White Point
    elseif strcmp(Mode,'KEHRMIT')
        CmgKymogram = mat2gray(Kymogram,CLim); 
        FenKymogram = 0*CmgKymogram; 
    elseif strcmp(Mode,'PHADE')
        FenKymogram = mat2gray(Kymogram2,CLim2);  %apply the Black/White Point
        CmgKymogram = 0*FenKymogram;
    end

    if strcmp(UserData.KymoMode,'OneLine') %Kymogram Display Mode KymoMode = 'OneLine' or 'Default';
        %display the kymogram with one line for each timepoint/frame
        %re-use the data from above: CmgKymogram and FenKymogram
        CmgKymogram = SelectKymoROI_KEHRMITandPHADE_GenerateOneLineKymo(CmgKymogram,Hframe);
        FenKymogram = SelectKymoROI_KEHRMITandPHADE_GenerateOneLineKymo(FenKymogram,Hframe);
    end
    
    %% Determine which display mode is being used: 'PHADE' or 'KEHRMIT' or 'Both'
    H = get(findobj(gcf,'Tag','DisplayMode'),'SelectedObject');
    DisplayMode = get(H,'String'); %'PHADE' or 'KEHRMIT' or 'Both'

    %Generate the rgbImage = cat(3, redChannel, greenChannel, blueChannel);
    if strcmp(DisplayMode,'PHADE')
        RgbKymogram = cat(3, FenKymogram, FenKymogram, FenKymogram); 
    elseif strcmp(DisplayMode,'KEHRMIT')
        RgbKymogram = cat(3, CmgKymogram, CmgKymogram, CmgKymogram); 
    else %the mode is 'Both'
        RgbKymogram = cat(3, CmgKymogram*0, CmgKymogram, FenKymogram); 
    end

    %% Display Image
    ImageHandle = findobj(gcf,'Type','image');
    set(ImageHandle,'CData',RgbKymogram);     
    set(gca,'Units','normalized','Position',[0.0563    0.0373    0.8028    0.9246],...
            'FontSize',14,'XTick',[],'YTick',[],'XLimMode','auto','YLimMode','auto');
 
    SelectKymoROI_KEHRMITandPHADE_DisplayROI(ROI,SelectionType,Hframe); %show the regions of interest (ROIs) over the kymogram
    
    FileName = get(gcf,'Name'); %FileName
    title([FileName ', Mol#' num2str(CurrMol) '/' num2str(TotalMol)],'Interpreter','none'); %display the filename in the title of the figure
    set(gca,'ToolBar',[]); %disable the toolbar
    set(gcf,'UserData',UserData);
    
end