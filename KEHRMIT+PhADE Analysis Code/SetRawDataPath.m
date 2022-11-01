function SetRawDataPath()
% Use this function to indicate where your raw data is saved
%
% USE: SetRawDataPath()
%
% Gheorghe Chistol, 31 Oct 2022

   StartPath =  'C:\Ghe Samsung Ion 2Tb Documents\Work Documents\MATLAB Code\GitHub KEHRMIT Paper 31-Oct-2022\'; %put your favorite start path here
    RawDataPath = uigetdir(StartPath);
    if ~isempty(RawDataPath)
        save 'RawDataPath.mat' RawDataPath;
        disp(['Raw Data - ' RawDataPath]);
    end
end