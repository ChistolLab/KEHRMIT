function SelectKymoROI_KEHRMITandPHADE_KeyReleaseFcn(Selection)  
% This is a helper funtion to SelectKymoROI_KEHRMITandPHADE()
% This function responds to keyboard shortcuts typed by the user.
% '>' or '.' - next molecule
% '<' or ',' - previous molecule
% '1' - select region of interest (ROI) with a single CMG/ReplicationFork 
% '2' - select region of interest (ROI) with two divergent CMGs/ReplicationForks
% 'w' - change the width of the image, i.e. the aspect ratio
% 'r' - remove all ROIs for current molecule
% 's' - save the selections and close figure
%
% USE: SelectKymoROI_KEHRMITandPHADE_KeyReleaseFcn(Selection)
%
% Gheorghe Chistol, 2020-01-04

% keep in mind that there are 3 modes, saved in UserData.Mode
% KEHRMIT       - kehrmit only, the PHADE channel is NaN
% PHADE         - phade only, the KEHRMIT channel is NaN
% KEHRMIT+PHADE - both channels are present
%
% Gheorghe Chistol, 31 Oct 2022

    if nargin==0
        Selection = get(gcf,'CurrentCharacter');
    end
    
    switch Selection
        case 'w' %change aspect ratio between 1, 2, and 3
            R = get(gca,'DataAspectRatio');
            if R(2)==1
                set(gca,'DataAspectRatio',[1 2 1]);
            elseif R(2)==2
                set(gca,'DataAspectRatio',[1 3 1]);
            elseif R(2)==3
                set(gca,'DataAspectRatio',[1 4 1]);
            elseif R(2)==4
                set(gca,'DataAspectRatio',[1 1 1]);
            end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
        case '.' %(same key as >) - show next molecule
            UserData = get(gcf,'UserData');
            CurrMol = UserData.CurrMol; %current molecule
            TotalMol = length(UserData.Kymogram); %total number of molecules
            if CurrMol>=TotalMol
                beep; disp('This is the last molecule, can not advance further'); return;
            end
            UserData.CurrMol = UserData.CurrMol+1; %update UserData
            set(gcf,'UserData',UserData);
            SelectKymoROI_KEHRMITandPHADE_UpdateDisplay();
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%            
        case ',' %same key as < - show prev molecule
            UserData = get(gcf,'UserData');
            CurrMol = UserData.CurrMol; %current molecule
            if CurrMol==1
                beep; disp('This is the first molecule, can not go back further'); return; 
            end
            UserData.CurrMol = UserData.CurrMol-1;
            set(gcf,'UserData',UserData);
            SelectKymoROI_KEHRMITandPHADE_UpdateDisplay();
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%            
        case '1' %ROI for a single CMG molecule or a single replication fork
            UserData     = get(gcf,'UserData');
            CurrMol      = UserData.CurrMol; %current molecule
            Mode         = UserData.Mode; %'KEHRMIT', 'PHADE', or 'KEHRMIT+PHADE'
            Kymogram     = UserData.Kymogram{CurrMol};
            Kymogram2    = UserData.Kymogram2{CurrMol};
            
            if strcmp(Mode,'PHADE')
                [Rows, Cols] = size(Kymogram2); %how many rows of pixels are in each kymogram
                Nframes    = length(UserData.KymogramMovie2{CurrMol});
            else %KEHRMIT or KEHRMIT+PHADE
                [Rows, Cols] = size(Kymogram); %how many rows of pixels are in each kymogram
                Nframes    = length(UserData.KymogramMovie{CurrMol});
            end
            
            Hframe       = Rows/Nframes; %height of each frame in pixels
            %for the t-th time point the y coordinate on the kymogram is (t-1)*Hframe+Hframe/2+0.5
            Time         = ((1:Nframes)-1)*Hframe+Hframe/2+0.5; %time vector converted into pixels, one per frame
            
            [x1, y1] = SelectKymoROI_KEHRMITandPHADE_Ginputc(1,'Color','g'); hold on; h1=plot(x1,y1,'+g');
            [x2, y2] = SelectKymoROI_KEHRMITandPHADE_Ginputc(1,'Color','g'); hold on; h2=plot(x2,y2,'+g'); delete(h1); delete(h2);
            
            xmin = min([x1 x2]);
            xmax = max([x1 x2]);
            ymin = min([y1 y2]);
            ymax = max([y1 y2]);
            
            Delta = 0; %how many extra pixels to take on each side
            Tmin     = find(Time>ymin,1,'first');
            Tmax     = find(Time<ymax,1,'last');
            Xmin     = round(xmin-Delta);
            Xmax     = round(xmax+Delta);

            Tmin     = SelectKymoROI_KEHRMITandPHADE_CheckBoundary(Tmin, 1, Nframes);
            Tmax     = SelectKymoROI_KEHRMITandPHADE_CheckBoundary(Tmax, 1, Nframes);            
            Xmin     = SelectKymoROI_KEHRMITandPHADE_CheckBoundary(Xmin, 1, Cols);
            Xmax     = SelectKymoROI_KEHRMITandPHADE_CheckBoundary(Xmax, 1, Cols);            
            UserData.ROI{CurrMol}{end+1}           = [Xmin Xmax Tmin Tmax]; %append to the existing selections
            UserData.SelectionType{CurrMol}{end+1} = 'single'; %type of selection.
            CurrSelection                          = length(UserData.ROI{CurrMol});
            SelectKymoROI_KEHRMITandPHADE_DisplayROI(UserData.ROI{CurrMol},UserData.SelectionType{CurrMol},Hframe,CurrSelection); %display only the last selection
            set(gcf,'UserData',UserData); 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%            
        case '2' %ROI for two diverging CMG molecules
            UserData     = get(gcf,'UserData');
            CurrMol      = UserData.CurrMol; %current molecule
            Mode         = UserData.Mode; %'KEHRMIT', 'PHADE', or 'KEHRMIT+PHADE'
            Kymogram     = UserData.Kymogram{CurrMol};
            Kymogram2    = UserData.Kymogram2{CurrMol};
            
            if strcmp(Mode,'PHADE')
                [Rows, Cols] = size(Kymogram2); %how many rows of pixels are in each kymogram
                Nframes    = length(UserData.KymogramMovie2{CurrMol});
            else %KEHRMIT or KEHRMIT+PHADE
                [Rows, Cols] = size(Kymogram); %how many rows of pixels are in each kymogram
                Nframes    = length(UserData.KymogramMovie{CurrMol});
            end
            
            Hframe       = Rows/Nframes; %height of each frame in pixels
            %for the t-th time point the y coordinate on the kymogram is (t-1)*Hframe+Hframe/2+0.5
            Time         = ((1:Nframes)-1)*Hframe+Hframe/2+0.5; %time vector converted into pixels, one per frame
            
            [x1, y1] = SelectKymoROI_KEHRMITandPHADE_Ginputc(1,'Color','g'); hold on; h1=plot(x1,y1,'+g');
            [x2, y2] = SelectKymoROI_KEHRMITandPHADE_Ginputc(1,'Color','g'); hold on; h2=plot(x2,y2,'+g'); delete(h1); delete(h2);

            xmin = min([x1 x2]);
            xmax = max([x1 x2]);
            ymin = min([y1 y2]);
            ymax = max([y1 y2]);
            
            Delta = 0; %how many extra pixels to take on each side
            Tmin     = find(Time>ymin,1,'first');
            Tmax     = find(Time<ymax,1,'last');
            Xmin     = round(xmin-Delta);
            Xmax     = round(xmax+Delta);

            Tmin     = SelectKymoROI_KEHRMITandPHADE_CheckBoundary(Tmin, 1, Nframes);
            Tmax     = SelectKymoROI_KEHRMITandPHADE_CheckBoundary(Tmax, 1, Nframes);            
            Xmin     = SelectKymoROI_KEHRMITandPHADE_CheckBoundary(Xmin, 1, Cols);
            Xmax     = SelectKymoROI_KEHRMITandPHADE_CheckBoundary(Xmax, 1, Cols);            
            UserData.ROI{CurrMol}{end+1}           = [Xmin Xmax Tmin Tmax]; %append to the existing selections
            UserData.SelectionType{CurrMol}{end+1} = 'double'; %type of selection.
            CurrSelection                          = length(UserData.ROI{CurrMol});
            SelectKymoROI_KEHRMITandPHADE_DisplayROI(UserData.ROI{CurrMol},UserData.SelectionType{CurrMol},Hframe,CurrSelection); %display only the last selection
            set(gcf,'UserData',UserData);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
        case 'r' %remove all ROIs for current molecule
            UserData                        = get(gcf,'UserData');
            CurrMol                         = UserData.CurrMol; %current molecule
            UserData.ROI{CurrMol}           = [];
            UserData.SelectionType{CurrMol} = [];
            set(gcf,'UserData',UserData);
            SelectKymoROI_KEHRMITandPHADE_UpdateDisplay; %display the molecule
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        case 'g' %generate 3-panel report: CMG+PRIMPOL, CMG Only, PRIMPOL only
             CurrImg = findobj(gcf,'Type','image');
             if ~isobject(CurrImg)
                 return;
             end
             CurrKymo = get(CurrImg,'CData'); %save the kymogram
             TopBP1Kymo = cat(3, 0*CurrKymo(:,:,2), CurrKymo(:,:,2), 0*CurrKymo(:,:,2));
             PhadeKymo =  cat(3, 0*CurrKymo(:,:,3), 0*CurrKymo(:,:,3), CurrKymo(:,:,3));
             Composite = [CurrKymo PhadeKymo TopBP1Kymo];
             
             figure;
             imshow(Composite);
             set(gcf,'Units','normalized','Position',[0.5005    0.0472    0.4990    0.8574]);
             set(gca,'Units','normalized','Position',[0.0563    0.0373    0.8028    0.9246]);
             set(gca,'DataAspectRatioMode','manual','DataAspectRatio',[1 3 1]);
             %imwrite(Composite,'TempKymo.png')
             imclipboard('copy',Composite); %copy the kymogram to clipboard.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        case 'c' %Copy Image to System Clipboard
             copygraphics(gcf,'ContentType','image')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%             
        case 'm' %change the kymogram mode between 'Default' and 'OneLine'             
            UserData = get(gcf,'UserData'); 
            KymoMode = UserData.KymoMode;
            if strcmp(KymoMode,'Default')
                UserData.KymoMode='OneLine'; %change from Default to OneLine
                set(gca,'DataAspectRatioMode','manual','DataAspectRatio',[1 1 1]);
            else
                UserData.KymoMode='Default'; %change from OneLine to default
                set(gca,'DataAspectRatioMode','manual','DataAspectRatio',[1 1 1]);
            end
            set(gcf,'UserData',UserData);
            SelectKymoROI_KEHRMITandPHADE_UpdateDisplay; %Update the Molecule Display
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
        case 'e' %exit and save
            UserData   = get(gcf,'UserData');
            FileName   = get(gcf,'Name');     %file name w/o extension
            FolderName = get(gcf,'FileName'); %FolderName
            save([FolderName filesep FileName '_ROI.mat'],'UserData');
            disp(['Data saved to ' FileName   '_ROI.mat']);
            close(gcf);
        end
end