function [FinalSignal, Background] = SelectMolecules_KEHRMITandPHADE_SubtractBackground(Movie, FilterDiameter)
% This function takes a movie (KEHRMIT or PHADE signal) and subtracts the
% background to account for any uneven illumination. This is especially
% useful for PHADE movies where the background can fluctuate significantly
% from frame to frame in the same movie.
%
% USE: [Signal, Background] = SelectMolecules_KEHRMITandPHADE_SubtractBackground(Movie, FilterDiameter)
%                             Movie is a uint16 stack Movie{frame}
%                             FilterDiameter specifies how big the filter "brush" is (20-50 works well)  
%
% Gheorghe Chistol, 31 Oct 2022

    for f=1:length(Movie)
        Background{f}     = imgaussfilt(Movie{f},FilterDiameter);
        Signal{f}         = int32(Movie{f})-int32(Background{f}); %converting to int32 to avoids clipping data
        MeanBackground(f) = mean(mean(Background{f})); %this sets the overall grayscale value of the background
    end
    
    for f=1:length(Movie)
        FinalSignal{f}    = uint16(Signal{f}+mean(MeanBackground)); %converting back to uint16
        %this manipulation ensures that all fames have the same average background
    end
end