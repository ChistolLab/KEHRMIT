function OneLineKymogram = SelectKymoROI_KEHRMITandPHADE_GenerateOneLineKymo(Kymogram,FrameHeight)
    % This function collapses each movie frame from a 5-pixel image to a 1-pixel image
    % this helps improve signal to noise and makes the kymogram less tall, 
    % this is especially useful for experiments with a lot of timepoints
    %
    % Kymogram    - should be a monochrome image, so a table of values
    % FrameHeight - specifies the height (in pixels)
    %
    % USE: OneLineKymogram = SelectKymoROI_KEHRMITandPHADE_GenerateOneLineKymo(Kymogram,Height)
    %
    % Gheorghe Chistol, 07 Feb 2022

    [KymoHeight,~,~]=size(Kymogram); %height of the kymogram in pixels
    Nframes = floor(KymoHeight/FrameHeight);
    OneLineKymogram=[];
    for f=1:Nframes
        CurrIndex = ((f-1)*FrameHeight+1):(f*FrameHeight); %the index of the pixels that belong to the current frame
        CurrFrameImg = Kymogram(CurrIndex,:); %the monochrome image corresponding to the current frame
        
        CurrLine = sum(CurrFrameImg)/FrameHeight; %collapses it into a single line
        OneLineKymogram=[OneLineKymogram;CurrLine];
    end

end
