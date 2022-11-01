function [Kymogram, BlackPoint, WhitePoint]= SelectMolecules_KEHRMITandPHADE_AdjustKymogram(Kymogram, Nframes)
% set the black point such that 50% of the pixels are black
% set the white point such that the brightest Nframes pixels are white
%
% Gheorghe Chistol, 31 Oct 2022

SortKymo   = sort(Kymogram(:));
BlackPoint = SortKymo(round(length(SortKymo)/3));
WhitePoint = SortKymo(end-Nframes);
Kymogram   = mat2gray(Kymogram,[BlackPoint WhitePoint]);

end