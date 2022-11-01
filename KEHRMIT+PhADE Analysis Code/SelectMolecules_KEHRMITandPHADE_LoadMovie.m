function Movie = SelectMolecules_KEHRMITandPHADE_LoadMovie(MovieFile, MovieFolder)
% load the stabilized movie frame by frame
%
% USE: Movie = SelectMolecules_LoadMovie(MovieFile, MovieFolder)
%
% Gheorghe Chistol, 31 Oct 2022

    info = imfinfo([MovieFolder filesep MovieFile]);
    num_images = numel(info);
    for k = 1:num_images
        Movie{k} = imread([MovieFolder filesep MovieFile], k);
    end

end