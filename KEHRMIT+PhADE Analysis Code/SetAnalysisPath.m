function SetAnalysisPath()
% Use this function to indicate where your analysis data will be saved
%
% USE: SetAnalysisPath()
%
% Gheorghe Chistol, 31 Oct 2022

    StartPath =  'C:\Ghe Samsung Ion 2Tb Documents\Work Documents\MATLAB Code\GitHub KEHRMIT Paper 31-Oct-2022\'; %put your favorite start path here
    AnalysisPath = uigetdir(StartPath);
    if ~isempty(AnalysisPath)
        save 'AnalysisPath.mat' AnalysisPath;
        disp(['Analysis Path - ' AnalysisPath]);
    end
end