function [Kymogram,CropMovie,MinInd,MaxInd] = SelectMolecules_KEHRMITandPHADE_GenerateKymogram(Movie,n,MinInd,MaxInd)
% n is the height of the image that goes into making the kymogram
% n=5; %use 6 pixels for movies, 4-5 pixels for kymograms
% MinInd and MaxInd are optional, they are used only for HpaII Kymos
%
% USE: for CMG kymogram [Kymogram,CropMovie,MinInd,MaxInd] = SelectMolecules_KEHRMITandPHADE_GenerateKymogram(Movie,n)
%      for Fen1 kymogram              [Kymogram,CropMovie] = SelectMolecules_KEHRMITandPHADE_GenerateKymogram(Movie,n,MinInd,MaxInd)
%      using the MinInd and MaxInd already determined for the corresponding CMG kymo
%
% Gheorghe Chistol, 31 Oct 2022

    if nargin==2 
        MaxProj    = SelectMolecules_KEHRMITandPHADE_ZProjectMax(Movie);
        [ProjY, ~] = SelectMolecules_KEHRMITandPHADE_ProjectFrame(MaxProj,2); %first project the image onto y (each row collapses into one)
        %ProjectionAxis = 1 for x-projection (each column collapses into one)
        %ProjectionAxis = 2 for y-projection (each row collapses into one)

        %find the peak, keep n brightest consecutive pixels
        Ind = find(ProjY==max(ProjY),1,'first');

        if ~isempty(Ind)
            if rem(n,2) %if n is odd
                MinInd = (Ind-(n-1)/2);
                MaxInd = (Ind+(n-1)/2);
            else %if n is even
                MinInd = (Ind-n/2)+1;
                MaxInd = (Ind+n/2);
            end
        else
            Kymogram = NaN;
            CropMovie = NaN;
            return;
        end

        [Rows, ~] = size(Movie{1});

        while MinInd<1 %shift indices
            MinInd = MinInd+1;
            MaxInd = MaxInd+1;
        end

        while MaxInd>Rows
            MaxInd = MaxInd-1;
            MinInd = MinInd-1;
        end
    end
   
    
    for i=1:length(Movie)
        CropMovie{i} = Movie{i}(MinInd:MaxInd,:);
    end
    
    %assemble kymogram
    [Rows, Cols] = size(CropMovie{1});
    Kymogram = zeros(length(Movie)*Rows,Cols);
    for i=1:length(CropMovie)
        RowInd = ((i-1)*Rows+1):(i*Rows);
        Kymogram(RowInd,:) = CropMovie{i};
    end
end
