function [RotatedX, RotatedY] = SelectMolecules_KEHRMITandPHADE_RotateXY(X,Y,AngleDeg,a)

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