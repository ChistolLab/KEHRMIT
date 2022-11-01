function Output = SelectKymoROI_KEHRMITandPHADE_CheckBoundary(Input, Min, Max)
% To make sure a number is in range, works for arrays
% If input is not in range, outliers are reset to be in range
%
% USE: Output = CheckBoundary(Input, Min, Max)
%
% Gheorghe Chistol, 31 Oct 2022

    Output = Input;
    Output(Input<Min) = Min;
    Output(Input>Max) = Max;
end