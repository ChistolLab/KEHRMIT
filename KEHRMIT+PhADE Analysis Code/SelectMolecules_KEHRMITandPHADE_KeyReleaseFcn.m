function SelectMolecules_KEHRMITandPHADE_KeyReleaseFcn(Selection)
% This is a helper function to SelectMolecules_KEHRMITandPHADE
% it is called whenever a key is pressed or a value is changed in the GUI
% to elicit a response (new selection, zoom, save/close, white/black point edit)
%
% USE: SelectMolecules_KEHRMITandPHADE_KeyReleaseFcn(Selection)
%                      Selection can be 'n', 'z', 'o', 'i' etc.
%
% Gheorghe Chistol, 31 Oct 2022
    
%% Go Through Each Use Case - What to do when a button is pressed    
    if nargin==0
        Selection = get(gcf,'CurrentCharacter');
    end

    switch Selection
        case 'n' %new selection
            h = imline(gca); Line = get(h,'Children'); %get xy coordinates of the selected line
            X = [Line(1).XData Line(2).XData];
            Y = [Line(1).YData Line(2).YData];
            delete(h); hold on; 
            H = plot(X,Y,'y-','LineWidth',3);
            
            UserData = get(gcf,'UserData');
            Movie  = UserData.Movie;  %KEHRMIT Movie
            Movie2 = UserData.Movie2; %PHADE Movie

            if strcmp(UserData.Mode,'KEHRMIT')
                for i=1:length(Movie) %take a crude crop of the molecule, will be later refined
                    CropMovie{i}  = SelectMolecules_KEHRMITandPHADE_RotateAndCrop(Movie{i},X,Y);
                end
                [UserData.Kymogram{end+1}, UserData.KymogramMovie{end+1}, ~, ~] = SelectMolecules_KEHRMITandPHADE_GenerateKymogram(CropMovie,5); %for CMG
                UserData.Kymogram2{end+1}      = NaN;
                UserData.KymogramMovie2{end+1} = NaN;
                
            elseif strcmp(UserData.Mode,'PHADE')
                for i=1:length(Movie2) %take a crude crop of the molecule, will be later refined
                    CropMovie2{i}  = SelectMolecules_KEHRMITandPHADE_RotateAndCrop(Movie2{i},X,Y);
                end
                [UserData.Kymogram2{end+1}, UserData.KymogramMovie2{end+1}, ~, ~] = SelectMolecules_KEHRMITandPHADE_GenerateKymogram(CropMovie2,5); %for CMG
                UserData.Kymogram{end+1}      = NaN;
                UserData.KymogramMovie{end+1} = NaN;
                 
            elseif strcmp(UserData.Mode,'KEHRMIT+PHADE')
                 for i=1:length(Movie) %take a crude crop of the molecule, will be later refined
                    CropMovie{i}  = SelectMolecules_KEHRMITandPHADE_RotateAndCrop(Movie{i},X,Y);
                    CropMovie2{i} = SelectMolecules_KEHRMITandPHADE_RotateAndCrop(Movie2{i},X,Y);
                 end
                [UserData.Kymogram{end+1}, UserData.KymogramMovie{end+1}, MinInd, MaxInd] = SelectMolecules_KEHRMITandPHADE_GenerateKymogram(CropMovie,5); %for CMG
                [UserData.Kymogram2{end+1}, UserData.KymogramMovie2{end+1},~,~]           = SelectMolecules_KEHRMITandPHADE_GenerateKymogram(CropMovie2,5,MinInd,MaxInd); %for Fen1
                 
            else
                disp('Error!!!'); beep; return;
            end
            
            UserData.SelectX{end+1}    = X;
            UserData.SelectY{end+1}    = Y;
            UserData.SelectH{end+1}    = H;
            set(gcf,'UserData',UserData);
            
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%            
        case 'z' %zoom into the image
            h=imrect(gca); %draw a rectangle to define the zoom
            Rect = get(h,'Children');
            Xmin = Rect(4).XData;
            Xmax = Rect(2).XData;
            Ymin = Rect(4).YData;
            Ymax = Rect(2).YData;
            delete(h);
            
            Xmin = SelectMolecules_KEHRMITandPHADE_CheckBoundary(Xmin, 1, 512);
            Xmax = SelectMolecules_KEHRMITandPHADE_CheckBoundary(Xmax, 1, 512);
            Ymin = SelectMolecules_KEHRMITandPHADE_CheckBoundary(Ymin, 1, 512);
            Ymax = SelectMolecules_KEHRMITandPHADE_CheckBoundary(Ymax, 1, 512);
            set(gca,'XLim',[Xmin Xmax],'YLim',[Ymin Ymax]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        case 'o' %zoom out entirely
            CurrImg = get(findobj(gcf,'Type','image'),'CData');
            [W, H, ~] = size(CurrImg); %if the image is monochrome, size=[512 512], if it's color then size=[512 512 3], this syntax catches both
            set(gca,'XLim',[0 W],'YLim',[0 H]);
            
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        case 'h' %change the way the selections are highlighted
            UserData = get(gcf,'UserData');
            Visible = NaN;
            
            if ~isempty(UserData.SelectH)
                Visible=get(UserData.SelectH{1},'Visible');
            end

            if isnan(Visible)
                return; %there are no selections, nothing to be done
            end
            
            if strcmp(Visible,'on') %reverse the visibility
                Visible = 'off'; 
            elseif strcmp(Visible,'off')
                Visible = 'on';
            end
            
            if ~isempty(UserData.SelectH)
                for i=1:length(UserData.SelectH)
                    set(UserData.SelectH{i},'Visible',Visible);
                end
            end
            
            if strcmp(Visible,'off') %plot a box around each selection
                Delta = 3; %width/2 of each box
                for i=1:length(UserData.SelectH)
                    SelectMolecules_KEHRMITandPHADE_DrawBox(UserData.SelectX{i},UserData.SelectY{i},Delta);
                end
            end
            
            if strcmp(Visible,'on') %delete boxes that are dotted
                H = findobj(gca,'LineStyle',':');
                delete(H);
            end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%          
        case 'm' %max projection
             SelectMolecules_KEHRMITandPHADE_UpdateDisplay(); %refresh the display, show max projection
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
        case 'p' %play movie
            UserData    = get(gcf,'UserData');
            DisplayMode = get(get(findobj(gcf,'Tag','DisplayMode'),'SelectedObject'),'String'); %'PHADE Only' or 'KEHRMIT Only' or 'Both'
            %Movie       = NaN; %initialize the movie structure

            if strcmp(DisplayMode,'KEHRMIT Only') || strcmp(DisplayMode,'KEHRMIT')
                Movie = UserData.Movie;
            elseif strcmp(DisplayMode,'PHADE Only') || strcmp(DisplayMode,'PHADE')
                Movie = UserData.Movie2;
            elseif strcmp(DisplayMode,'Both')
                CmgMovie = UserData.Movie;
                FenMovie = UserData.Movie2;
                %keyboard
                for f=1:length(CmgMovie) %do this for each frame
                    CmgFrame = mat2gray(CmgMovie{f},UserData.CLim); %apply the Black/White Point
                    FenFrame = mat2gray(FenMovie{f},UserData.CLim2); %apply the Black/White Point
                    Movie{f} = cat(3,CmgFrame*0, CmgFrame, FenFrame); %rgbImage = cat(3, redChannel, greenChannel, blueChannel);
                end
            end

            ImageHandle = findobj(gcf,'Type','image');
            if ~isobject(ImageHandle)
                disp('Cannot find where to display the movie'); return;
            end
           %keyboard
            for f=1:length(Movie) %show all the frames of the movie
                set(ImageHandle,'CData',Movie{f}); %no need to re-set the CLim
                pause on; pause(0.02);
            end
            SelectMolecules_KEHRMITandPHADE_KeyReleaseFcn('m'); %after the movie is over show max projection            
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        case 'r' %remove selection
            %click nearest the selection you want to remove
            [RemoveX, RemoveY] = SelectMolecules_KEHRMITandPHADE_Ginputc(1, 'Color', 'w', 'LineWidth', 1,'LineStyle',':');
            UserData = get(gcf,'UserData');
            X      = []; %x coord of the center of each selection
            Y      = []; %y coord of the center of each selection
            Index  = [];
            Handle = [];
            
            for s = 1:length(UserData.SelectX)
                X(end+1)      = mean(UserData.SelectX{s});
                Y(end+1)      = mean(UserData.SelectY{s});
                Index(end+1)  = s;
                Handle(end+1) = UserData.SelectH{s};
            end

            %compute the distance between the click site and the existing molecule selections
            DistX = RemoveX-X;
            DistY = RemoveY-Y;
            Dist  = sqrt(DistX.^2+DistY.^2);
            I = find(Dist==min(Dist),1,'first'); %find the indec of the molecule closest to the click site
         
            %remove selection
            UserData.SelectX(Index(I))        = [];
            UserData.SelectY(Index(I))        = [];
            UserData.SelectH(Index(I))        = [];
            UserData.Kymogram(Index(I))       = [];
            UserData.KymogramMovie(Index(I))  = [];
            UserData.Kymogram2(Index(I))      = [];
            UserData.KymogramMovie2(Index(I)) = [];
            delete(Handle(I)); %delete the plot line marking the selection
            set(gcf,'UserData',UserData);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
        case 's' %save existing selections and close
            FileName = get(gcf,'Name');
            FolderName = get(gcf,'FileName');
            %1. save UserData into FolderName / FileName;
            if ~isfolder(FolderName)
                mkdir(FolderName);
            end
            
            %don't overwrite existing file
            if exist([FolderName filesep FileName '_KymoKaP.mat'],'file')==2 %if this file already exists
                % Construct a questdlg about what to do w the file
                choice = questdlg('Would you like to overwrite the existing selection file?', ...
                                  'Overwrite or Not','Yes Overwrite','Do NOT','Do NOT');
                switch choice % Handle response
                    case 'Yes Overwrite'
                        disp('Overwriting the current selection file, saving a backup of the old one');
                        copyfile([FolderName filesep FileName '_KymoKaP.mat'],[FolderName filesep FileName '_KymoKaP_Backup.mat']);
                    case 'Do NOT'
                        disp('Did NOT save the selection')
                        return;
                end
            end
            
            UserData = get(gcf,'UserData');
            if strcmp(UserData.Mode,'KEHRMIT+PHADE')
                set(findobj(gcf,'Tag','DisplayBOTH'),'Value',1); %reset the display mode to see both channels
                SelectMolecules_KEHRMITandPHADE_UpdateDisplay();
            end
            
            UserData = get(gcf,'UserData');
            UserData = rmfield(UserData,{'Movie','Movie2','MaxProj','MaxProj2','SelectH'});
            
            save([FolderName filesep FileName '_KymoKaP.mat'],'UserData');
            disp(['Saved UserData to ' FileName]);
            delete(gcf);
    end
end