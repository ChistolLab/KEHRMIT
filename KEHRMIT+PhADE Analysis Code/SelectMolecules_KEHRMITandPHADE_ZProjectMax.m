function MaxProj = SelectMolecules_KEHRMITandPHADE_ZProjectMax(RawMovie,FilterRadius)
% For each pixel find the max intensity throughout the movie - that's the maxZ projection
% Optionally, the movie can first be gaussian-filtered to smooth over some
% of the noise, using a FilterRadius as specified in the inputs
% 
% USE: MaxProj = SelectMolecules_KEHRMITandPHADE_ZProjectMax(RawMovie,FilterRadius)
%
% Gheorghe Chistol, 31 Oct 2022

    if nargin==2
        % Gauss-filter the movie for a less noisy max-z projection
        if FilterRadius<0.1 %non valid filter, it has to be positive and non-zero
            MaxProj = NaN; beep; disp('Invalid Filter Radius'); return;
        end
        %for f=1:length(RawMovie)
        %    Movie{f} = imgaussfilt(RawMovie{f},FilterRadius);
        %end
        Movie=RawMovie;
    elseif nargin==1
        Movie = RawMovie; %no filtering needed
    else
        MaxProj = NaN; beep; disp('Invalid Inputs'); return;
    end
    
    % This is a max projection    
    %[R,C] = size(Movie{1}); %R is # of rows, C is # of columns
    MaxProj = Movie{1};
    for i=2:length(Movie)
        CurrFrame  = Movie{i};
        GreaterInd = CurrFrame>MaxProj;
        MaxProj(GreaterInd)=CurrFrame(GreaterInd);
    end
    
end