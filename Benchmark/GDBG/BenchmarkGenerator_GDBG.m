%**************Generalized Dynamic Benchmark Generator (GDBG)******************************************************************************
%
%Author: Mai Peng
%Last Edited: May 11, 2024
% e-mail: pengmai1998 AT gmail dot com
%
% ------------
% Reference:
% ------------
%
%  C. Li et al.,
%            "A Generalized Approach to Construct Benchmark Problems for Dynamic Optimization,"
%            SEAL2008, 2008.
%
% --------
% License:
% --------
% This program is to be used under the terms of the GNU General Public License
% (http://www.gnu.org/copyleft/gpl.html).
% e-mail: danial DOT yazdani AT gmail DOT com
% Copyright notice: (c) 2024 Danial Yazdani
%*************************************************************************************************************************************
function Problem = BenchmarkGenerator_GDBG(PeakNumber,ChangeFrequency,Dimension,ShiftSeverity,EnvironmentNumber,BenchmarkName)
    disp('GDBG Running')
    Problem                     = [];
    Problem.FE                  = 0;
    Problem.PeakNumber          = PeakNumber;
    Problem.ChangeFrequency     = ChangeFrequency;
    Problem.Dimension           = Dimension;
    Problem.ShiftSeverity       = ShiftSeverity;
    Problem.EnvironmentNumber   = EnvironmentNumber;
    Problem.Environmentcounter  = 1;
    Problem.RecentChange        = 0;
    Problem.MaxEvals            = Problem.ChangeFrequency * Problem.EnvironmentNumber;
    Problem.Ebbc                = NaN(1,Problem.EnvironmentNumber);
    Problem.CurrentError        = NaN(1,Problem.MaxEvals);
    Problem.MinCoordinate       = -50;
    Problem.MaxCoordinate       = 50;
    Problem.MinHeight           = 30;
    Problem.MaxHeight           = 70;
    Problem.MinWidth            = 1;
    Problem.MaxWidth            = 12;
    Problem.HeightSeverity      = 7;
    Problem.WidthSeverity       = 1;
    Problem.PeakVisibility      = zeros(Problem.EnvironmentNumber,Problem.PeakNumber);
    Problem.OptimumValue        = NaN(Problem.EnvironmentNumber,1);
    Problem.PeaksHeight         = NaN(Problem.EnvironmentNumber,Problem.PeakNumber);
    Problem.PeaksPosition       = NaN(Problem.PeakNumber,Problem.Dimension,Problem.EnvironmentNumber);
    Problem.PeaksPosition(:,:,1)= Problem.MinCoordinate + (Problem.MaxCoordinate-Problem.MinCoordinate)*rand(Problem.PeakNumber,Problem.Dimension);
    Problem.PeaksHeight(1,:)    = Problem.MinHeight + (Problem.MaxHeight-Problem.MinHeight)*rand(Problem.PeakNumber,1);
    Problem.OptimumValue(1)     = max(Problem.PeaksHeight(1,:));
    Problem.BenchmarkName       = BenchmarkName;
    [Problem.OptimumValue(1), Problem.OptimumID(1)] = max(Problem.PeaksHeight(1,:));
    Problem.MinFunctionID       = 1;
    Problem.MaxFunctionID       = 5;
    Problem.FunctionSelect(1,:) = ceil(Problem.MinFunctionID-1 + (Problem.MaxFunctionID-Problem.MinFunctionID+1)*rand(Problem.PeakNumber,1));
    Problem.M = eye(Problem.Dimension); %Rotation Matrixs
    Problem.Theta = 2*pi*rand();
    
    %Generate rotation matrixs
    l = 2 * floor(1 + (Problem.Dimension/2 - 1) * rand());
    r = zeros(1, l);
    available = 1:Problem.Dimension;
    for i = 1:l
        idx = floor(1 + (length(available) - 1) * rand());
        r(i) = available(idx);
        available(idx) = [];
    end
    for i = 1:2:length(r)-1
        R = eye(Problem.Dimension);
        R(r(i), r(i)) = cos(Problem.Theta);
        R(r(i), r(i+1)) = -sin(Problem.Theta);
        R(r(i+1), r(i)) = sin(Problem.Theta);
        R(r(i+1), r(i+1)) = cos(Problem.Theta);
        Problem.M = Problem.M * R;
    end
    for jj=1:Problem.PeakNumber
        if EnvironmentVisualization(Problem.PeaksPosition(jj,:,1),Problem)==Problem.PeaksHeight(1,jj)
            Problem.PeakVisibility(1,jj)= 1;
        end
    end
    for ii=2 : Problem.EnvironmentNumber%Generating all environments
        Problem.FunctionSelect(ii,:) = ceil(Problem.MinFunctionID-1 + (Problem.MaxFunctionID-Problem.MinFunctionID+1)*rand(Problem.PeakNumber,1));
        ShiftOffset = randn(Problem.PeakNumber,Problem.Dimension);
        Shift = (ShiftOffset ./ pdist2(ShiftOffset,zeros(1,Problem.Dimension))).* Problem.ShiftSeverity;
        PeaksPosition  = Problem.PeaksPosition(:,:,ii-1) + Shift;
        PeaksHeight = Problem.PeaksHeight(ii-1,:) + (Problem.HeightSeverity*randn(1,Problem.PeakNumber));
        tmp = PeaksPosition > Problem.MaxCoordinate;
        PeaksPosition(tmp) = (2*Problem.MaxCoordinate)- PeaksPosition(tmp);
        tmp = PeaksPosition < Problem.MinCoordinate;
        PeaksPosition(tmp) = (2*Problem.MinCoordinate)- PeaksPosition(tmp);
        tmp = PeaksHeight > Problem.MaxHeight;
        PeaksHeight(tmp) = (2*Problem.MaxHeight)- PeaksHeight(tmp);
        tmp = PeaksHeight < Problem.MinHeight;
        PeaksHeight(tmp) = (2*Problem.MinHeight)- PeaksHeight(tmp);
        Problem.PeaksPosition(:,:,ii)= PeaksPosition;
        Problem.PeaksHeight(ii,:)    = PeaksHeight;
        Problem.Environmentcounter = Problem.Environmentcounter + 1;
        [Problem.OptimumValue(ii), Problem.OptimumID(ii)] = max(PeaksHeight);
        for jj=1:Problem.PeakNumber
            if abs(EnvironmentVisualization(Problem.PeaksPosition(jj,:,ii),Problem) - Problem.PeaksHeight(ii,jj)) < 0.1
                Problem.PeakVisibility(ii,jj)= 1;
            end
        end
    end
    result = EnvironmentVisualization(Problem.PeaksPosition(:,:,ii),Problem);
    disp(result)
    disp(Problem.PeaksHeight(ii,:))
    Problem.Environmentcounter = 1;
end