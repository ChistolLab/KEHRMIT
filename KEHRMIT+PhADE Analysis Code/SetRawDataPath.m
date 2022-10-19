function SetRawDataPath()
    StartPath =  '/Users/ghe/Dropbox (HMS)/aWalterLabFiles/_Daily_Electronic_Notes';
    RawDataPath = uigetdir(StartPath);
    if ~isempty(RawDataPath)
        save 'RawDataPath.mat' RawDataPath;
        disp(['Raw Data - ' RawDataPath]);
    end
end