function CropImg = SelectMolecules_KEHRMITandPHADE_RotateAndCrop(Img,x,y)
% x = [x1 x2]; - x vector
% y = [y1 y2]; - y vector
% x and y vector of the line-selection for a molecule


[X, I] = sort(x); %sort in ascending order
Y = y(I); %re-order Y data accordingly
AngleDeg = atand((Y(2)-Y(1))/(X(2)-X(1))); %angle of rotation - positive means counter-clockwise rotation, 
                                           %negative means clockwise rotation 
RotatedImg = imrotate(Img, AngleDeg, 'loose', 'bicubic');

%temp = get(gca,'UserData');
%MaxProj = temp.MaxProj; clear temp;
[H, ~]=size(Img);
a=H; %height of the image

[RotX(1), RotY(1)] = SelectMolecules_KEHRMITandPHADE_RotateXY(X(1),Y(1),AngleDeg,a);
[RotX(2), RotY(2)] = SelectMolecules_KEHRMITandPHADE_RotateXY(X(2),Y(2),AngleDeg,a);

%figure;
%imshow(RotatedImg, [400 3000],'InitialMagnification',200);
DeltaX = 5;
DeltaY = 3;
%hold on
%rectangle('Position',[min(RotX)-DeltaX min(RotY)-DeltaY 2*DeltaX+abs(RotX(2)-RotX(1)) 2*DeltaY],'EdgeColor','g','FaceColor','none')
XRange = round(min(RotX)-DeltaX):round(max(RotX)+DeltaX);
YRange = round(min(RotY)-DeltaY):round(max(RotY)+DeltaY);

%make sure the selection is within the image
[Rows, Cols] = size(RotatedImg);
XRange = SelectMolecules_KEHRMITandPHADE_CheckBoundary(XRange, 1, Cols);
YRange = SelectMolecules_KEHRMITandPHADE_CheckBoundary(YRange, 1, Rows);

CropImg = RotatedImg(YRange,XRange);
%figure;
%imshow(CropImg, [400 3000],'InitialMagnification',1000);
end