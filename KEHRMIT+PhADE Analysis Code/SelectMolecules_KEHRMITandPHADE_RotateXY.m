function [RotatedX, RotatedY] = SelectMolecules_KEHRMITandPHADE_RotateXY(X,Y,AngleDeg,a)
% This function converts the XY coordinates of the molecule to a reference
% frame after the image is rotated. This is used to help crop the molecule
% after the image is rotated
%
% USE: [RotatedX, RotatedY] = SelectMolecules_KEHRMITandPHADE_RotateXY(X,Y,AngleDeg,a)
%
% Gheorghe Chistol, 31 Oct 2022

    if AngleDeg<0 %clockwise rotation
        RotatedX = X*cosd(-AngleDeg) + (a-Y)*sind(-AngleDeg);
        RotatedY = Y*cosd(-AngleDeg) + X*sind(-AngleDeg);
    elseif AngleDeg>0 %counter-clockwise rotation
        RotatedX = X*cosd(AngleDeg) + Y*sind(AngleDeg);
        RotatedY = a*sind(AngleDeg) - X*sind(AngleDeg) + Y*cosd(AngleDeg);
    elseif AngleDeg==0
        RotatedX = X;
        RotatedY = Y;
    end

end