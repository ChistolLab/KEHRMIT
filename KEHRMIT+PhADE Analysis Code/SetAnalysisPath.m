function SetAnalysisPath()
    StartPath =  '/Users/ghe/Dropbox (HMS)/aWalterLabFiles/_Daily_Electronic_Notes';
    AnalysisPath = uigetdir(StartPath);
    if ~isempty(AnalysisPath)
        save 'AnalysisPath.mat' AnalysisPath;
        disp(['Analysis Path - ' AnalysisPath]);
    end
end