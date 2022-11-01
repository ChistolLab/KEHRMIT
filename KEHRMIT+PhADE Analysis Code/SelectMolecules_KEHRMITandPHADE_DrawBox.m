function H = SelectMolecules_KEHRMITandPHADE_DrawBox(X,Y,Delta)
% Draw a box of width/2 Delta (pixels) around each molecule selection
%
% USE: H = SelectMolecules_KEHRMITandPHADE_DrawBox(X,Y,Delta)
%
% Gheorghe Chistol, 31 Oct 2022

    Angle = -atan((Y(2)-Y(1))/(X(2)-X(1))); %angle of the selection in degrees
    
    if Angle>0
        a = Angle;
        %for positive angle
        Xmax = max(X)+Delta*cos(a);
        Xmin = min(X)-Delta*cos(a);
        Ymax = max(Y)+Delta*sin(a);
        Ymin = min(Y)-Delta*sin(a);
        %Xmin 
        %Ymin
        %plot(Xmax,Ymin,'y+');
        BoxX = [Xmax-Delta*sin(a) Xmax+Delta*sin(a) Xmin+Delta*sin(a) Xmin-Delta*sin(a) Xmax-Delta*sin(a)];
        BoxY = [Ymin-Delta*cos(a) Ymin+Delta*cos(a) Ymax+Delta*cos(a) Ymax-Delta*cos(a) Ymin-Delta*cos(a)];
        H = plot(BoxX,BoxY,'y:','LineWidth',1.5);
    end
    
     if Angle<0
        a = -Angle;
        %for positive angle
        Xmax = max(X)+Delta*cos(a);
        Xmin = min(X)-Delta*cos(a);
        Ymax = max(Y)+Delta*sin(a);
        Ymin = min(Y)-Delta*sin(a);
        %Xmin 
        %Ymin
        %plot(Xmax,Ymin,'y+');
        BoxX = [Xmin-Delta*(a)    Xmin+Delta*sin(a) Xmax+Delta*sin(a) Xmax-Delta*sin(a) Xmin-Delta*sin(a)];
        BoxY = [Ymin+Delta*cos(a) Ymin-Delta*cos(a) Ymax-Delta*cos(a) Ymax+Delta*cos(a) Ymin+Delta*cos(a)];
        H = plot(BoxX,BoxY,'y:','LineWidth',1.5);
    end
    
end