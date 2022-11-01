function [Projection, Axis]= SelectMolecules_KEHRMITandPHADE_ProjectFrame(Image,ProjectionAxis)
%ProjectionAxis = 1 for x-projection (each column collapses into one)
%ProjectionAxis = 2 for y-projection (each row collapses into one)
%
% USE: [Projection, Axis]= SelectMolecules_KEHRMITandPHADE_ProjectFrame(Image,ProjectionAxis)
%
% Gheorghe Chistol, 31 Oct 2022

    [R, C] = size(Image);

    if ProjectionAxis == 1
        for c=1:C
            Projection(c) = mean(Image(:,c));
            Axis(c) = c;
        end
        
    elseif ProjectionAxis ==2
        for r=1:R
            Projection(r) = mean(Image(r,:));
            Axis(r) = r;
        end
    end
end