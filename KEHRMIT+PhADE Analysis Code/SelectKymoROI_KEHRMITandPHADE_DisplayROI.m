function SelectKymoROI_KEHRMITandPHADE_DisplayROI(Selection,SelectionType,Hframe,i)
% If there are ROI selections for this particular kymogram - show them
% Each selection has the following info [xmin xmax tmin tmax]
% Here x are pixel positions and t are frame numbers in the kymogram
% Hframe is the height of the frame in pixels
%
% USE: SelectKymoROI_KEHRMITandPHADE_DisplayROI(Selection,SelectionType,Hframe)   - plot all the selections
%      SelectKymoROI_KEHRMITandPHADE_DisplayROI(Selection,SelectionType,Hframe,i) - plot only the i-th selection, i could be an array for example [2 3 4]
%
% Gheorghe Chistol, 2020-01-04
    UserData = get(gcf,'UserData');
    KymoMode = UserData.KymoMode; %Kymogram Display Mode KymoMode = 'OneLine' or 'Default'; 
    %Hframe = height of each frame in pixels, usually 5px
    
    if nargin==3
        delete(findobj(gcf,'Type','rectangle')); %delete all the previous ROI sections
    end

    if ~isempty(Selection)
        if nargin==3 %plot all the selections
            Min = 1; Max = length(Selection);
        elseif nargin==4 %i is specified, plot only the ith selection
            Min = min(i); Max = max(i);
        end
        
        hold on;
        
        for i = Min:Max
            if strcmp(KymoMode,'OneLine')
                Hframe = 1;
            end
            
            Pos = Selection{i};%[xmin xmax tmin tmax]
            %for the t-th time point the y coordinate on the kymogram is (t-1)*Hframe+Hframe/2+0.5
            %draw the box a little bigger to include the current timepoint image on the kymogram
            Pos(3) = (Pos(3)-1)*Hframe+0.5;
            Pos(4) = (Pos(4)-1)*Hframe+Hframe+0.5;
            
            if strcmp(SelectionType{i},'single')
                %draw a single box with yellow border
                rectangle('Position',[Pos(1) Pos(3) Pos(2)-Pos(1) Pos(4)-Pos(3)],'FaceColor','none','EdgeColor','y');
            end
            
            if strcmp(SelectionType{i},'double')
                %draw a second box around it to indicate that it's a two-CMG selection, bluish
                rectangle('Position',[Pos(1) Pos(3) Pos(2)-Pos(1) Pos(4)-Pos(3)],'FaceColor','none','EdgeColor',[0.5843    0.8157    0.9882]);
                rectangle('Position',[Pos(1)-.5 Pos(3)-.5 Pos(2)-Pos(1)+1 Pos(4)-Pos(3)+1],'FaceColor','none','EdgeColor',[0.5843    0.8157    0.9882]);
            end
        end
    end
end