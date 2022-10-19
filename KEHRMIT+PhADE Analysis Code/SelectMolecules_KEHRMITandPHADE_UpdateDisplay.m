function SelectMolecules_KEHRMITandPHADE_UpdateDisplay()
% This function is called whenever a display parameter gets changed in the
% GUI for selecting molecules from a KEHRMIT/PHADE movie.
% This function reads the display parameters and shows an updated image
% Tags to check: 
%                'WhitePointKEHRMIT'
%                'BlackPointKEHRMIT'  
%                'WhitePointPHADE'
%                'BlackPointPHADE'
%                'DisplayMode' 

    %% Determine which display mode is being used
    H = get(findobj(gcf,'Tag','DisplayMode'),'SelectedObject');
    DisplayMode = get(H,'String'); %'PHADE Only' or 'KEHRMIT Only' or 'Both'

    UserData = get(gcf,'UserData');

    if strcmp(DisplayMode,'KEHRMIT Only') || strcmp(DisplayMode,'KEHRMIT')
        %CLim is a vector with the [BlackPoint WhitePoint] for each channel
        CLim(1) = round(str2num(get(findobj(gcf,'Tag','BlackPointKEHRMIT'),'String')));
        CLim(2) = round(str2num(get(findobj(gcf,'Tag','WhitePointKEHRMIT'),'String')));
        set(findobj(gcf,'Type','image'),'CData',UserData.MaxProj);
        set(gca,'CLim',CLim);
        UserData.CLim  = CLim; %update the CLim - the KEHRMIT parameters in the UserData
        UserData.CLim2 = NaN;    

    elseif strcmp(DisplayMode,'PHADE Only') || strcmp(DisplayMode,'PHADE')
        CLim2(1) = round(str2num(get(findobj(gcf,'Tag','BlackPointPHADE'),'String')));
        CLim2(2) = round(str2num(get(findobj(gcf,'Tag','WhitePointPHADE'),'String')));
        set(findobj(gcf,'Type','image'),'CData',UserData.MaxProj2);
        set(gca,'CLim',CLim2);
        UserData.CLim  = NaN;    
        UserData.CLim2 = CLim2; %update the CLim2 - the PHADE parameters in the UserData
        
    elseif strcmp(DisplayMode,'Both')
        CLim(1) = round(str2num(get(findobj(gcf,'Tag','BlackPointKEHRMIT'),'String')));
        CLim(2) = round(str2num(get(findobj(gcf,'Tag','WhitePointKEHRMIT'),'String')));
        CLim2(1) = round(str2num(get(findobj(gcf,'Tag','BlackPointPHADE'),'String')));
        CLim2(2) = round(str2num(get(findobj(gcf,'Tag','WhitePointPHADE'),'String')));
        CmgMaxProj = mat2gray(UserData.MaxProj,CLim);   %apply the Black/White Point
        FenMaxProj = mat2gray(UserData.MaxProj2,CLim2); %apply the Black/White Point
        RgbMaxProj = cat(3,CmgMaxProj*0,CmgMaxProj, FenMaxProj); %rgbImage = cat(3, redChannel, greenChannel, blueChannel);
        set(findobj(gcf,'Type','image'),'CData',RgbMaxProj);
        set(gca,'CLim',[0 1]); %for color images
        UserData.CLim  = CLim; %update the CLim - the KEHRMIT parameters in the UserData
        UserData.CLim2 = CLim2; %update the CLim2 - the PHADE parameters in the UserData
    end

set(gcf,'UserData',UserData);
end