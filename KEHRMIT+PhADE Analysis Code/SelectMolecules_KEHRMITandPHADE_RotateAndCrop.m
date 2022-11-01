function CropImg = SelectMolecules_KEHRMITandPHADE_RotateAndCrop(Img,x,y)
% x = [x1 x2]; - x vector
% y = [y1 y2]; - y vector
% x and y vector of the line-selection for a molecule
%
% USE: CropImg = SelectMolecules_KEHRMITandPHADE_RotateAndCrop(Img,x,y)
%
% Gheorghe Chistol, 31 Oct 2022


    [X, I] = sort(x); %sort in ascending order
    Y = y(I); %re-order Y data accordingly
    AngleDeg = atand((Y(2)-Y(1))/(X(2)-X(1))); %angle of rotation - positive means counter-clockwise rotation, 
                                               %negative means clockwise rotation 
    
    RotatedImg = imrotate(Img, AngleDeg, 'loose', 'bicubic');
    [H, ~]=size(Img);
    a=H; %height of the image
    
    [RotX(1), RotY(1)] = SelectMolecules_KEHRMITandPHADE_RotateXY(X(1),Y(1),AngleDeg,a);
    [RotX(2), RotY(2)] = SelectMolecules_KEHRMITandPHADE_RotateXY(X(2),Y(2),AngleDeg,a);

    DeltaX = 5;
    DeltaY = 3;

    XRange = round(min(RotX)-DeltaX):round(max(RotX)+DeltaX);
    YRange = round(min(RotY)-DeltaY):round(max(RotY)+DeltaY);
    
    %make sure the selection is within the image
    [Rows, Cols] = size(RotatedImg);
    XRange = SelectMolecules_KEHRMITandPHADE_CheckBoundary(XRange, 1, Cols);
    YRange = SelectMolecules_KEHRMITandPHADE_CheckBoundary(YRange, 1, Rows);
    
    CropImg = RotatedImg(YRange,XRange);

end