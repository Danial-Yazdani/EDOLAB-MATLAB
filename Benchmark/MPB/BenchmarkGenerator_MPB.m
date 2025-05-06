%**************Moving Peaks Benchmark (MPB)***********************************************
%Author: Danial Yazdani
%e-mail: danial DOT yazdani AT gmail DOT com
%Last Edited: May 6, 2025
%
% ------------
% Reference:
% ------------
%
%  Juergen Branke,
%            "Memory enhanced evolutionary algorithms for changing optimization problems,"
%             IEEE Congress on Evolutionary Computation, 1999.
%
% ------------
% Notification:
% ------------
%
% Scenario 2 of MPB in which conical peaks are used.
% Lambda is removed from MPB, so the peaks are shifted in random directions.
% Values of heights and widths are randomly initialized.
%
% --------
% License:
% --------
% This program is to be used under the terms of the GNU General Public License
% (http://www.gnu.org/copyleft/gpl.html).
% Author: Danial Yazdani
% e-mail: danial DOT yazdani AT gmail DOT com
% Copyright notice: (c) 2023 Danial Yazdani
%*****************************************************************************************
function Problem = BenchmarkGenerator_MPB(BenchmarkName, ConfigurableParameters)
    disp('MPB Running')
    Problem                     = [];
    % Set Configurable Parameters
    fieldNames = fieldnames(ConfigurableParameters);
    for i = 1:length(fieldNames)
        Problem.(fieldNames{i}) = ConfigurableParameters.(fieldNames{i}).value;
    end
    % Set Other Parameters
    Problem.FE                  = 0;
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
    Problem.PeakVisibility      = zeros(Problem.EnvironmentNumber,Problem.PeakNumber);
    Problem.OptimumValue        = NaN(Problem.EnvironmentNumber,1);
    Problem.PeaksHeight         = NaN(Problem.EnvironmentNumber,Problem.PeakNumber);
    Problem.PeaksPosition       = NaN(Problem.PeakNumber,Problem.Dimension,Problem.EnvironmentNumber);
    Problem.PeaksWidth          = NaN(Problem.EnvironmentNumber,Problem.PeakNumber);
    Problem.PeaksPosition(:,:,1)= Problem.MinCoordinate + (Problem.MaxCoordinate-Problem.MinCoordinate)*rand(Problem.PeakNumber,Problem.Dimension);
    Problem.PeaksHeight(1,:)    = Problem.MinHeight + (Problem.MaxHeight-Problem.MinHeight)*rand(Problem.PeakNumber,1);
    Problem.PeaksWidth(1,:)     = Problem.MinWidth + (Problem.MaxWidth-Problem.MinWidth)*rand(Problem.PeakNumber,1);
    Problem.OptimumValue(1)     = max(Problem.PeaksHeight(1,:));
    Problem.BenchmarkName       = BenchmarkName;
    [Problem.OptimumValue(1), Problem.OptimumID(1)] = max(Problem.PeaksHeight(1,:));

    % Set user defined indicators
    Problem.Indicators = struct();
        jsonText = fileread('Indicators/Indicators.json');
    jsonText = regexprep(jsonText, '//[^\n\r]*', '');
    IndicatorDefs = jsondecode(jsonText);
    indicatorNames = fieldnames(IndicatorDefs);
    for i = 1 : numel(indicatorNames)
       name = indicatorNames{i};
       Problem.Indicators.(name).type = IndicatorDefs.(name).type;
       switch Problem.Indicators.(name).type
           case 'FE based'
               Problem.Indicators.(name).trend = NaN(1,Problem.MaxEvals);
           case 'Environment based'
               Problem.Indicators.(name).trend = NaN(1,Problem.EnvironmentNumber);
           case 'None'
               Problem.Indicators.(name).final = NaN;
           otherwise
               error('Unknown indicator type "%s" for %s', Problem.Indicators.(name).type, name);
       end
    end
    
    for jj=1:Problem.PeakNumber
        if EnvironmentVisualization(Problem.PeaksPosition(jj,:,1),Problem)==Problem.PeaksHeight(1,jj)
            Problem.PeakVisibility(1,jj)= 1;
        end
    end
    for ii=2 : Problem.EnvironmentNumber%Generating all environments
        ShiftOffset = randn(Problem.PeakNumber,Problem.Dimension);
        Shift          = (ShiftOffset ./ pdist2(ShiftOffset,zeros(1,Problem.Dimension))).* Problem.ShiftSeverity;
        PeaksPosition  = Problem.PeaksPosition(:,:,ii-1) + Shift;
        PeaksWidth  = Problem.PeaksWidth(ii-1,:) + (Problem.WidthSeverity*randn(1,Problem.PeakNumber));
        PeaksHeight = Problem.PeaksHeight(ii-1,:) + (Problem.HeightSeverity*randn(1,Problem.PeakNumber));
        tmp = PeaksPosition > Problem.MaxCoordinate;
        PeaksPosition(tmp) = (2*Problem.MaxCoordinate)- PeaksPosition(tmp);
        tmp = PeaksPosition < Problem.MinCoordinate;
        PeaksPosition(tmp) = (2*Problem.MinCoordinate)- PeaksPosition(tmp);
        tmp = PeaksHeight > Problem.MaxHeight;
        PeaksHeight(tmp) = (2*Problem.MaxHeight)- PeaksHeight(tmp);
        tmp = PeaksHeight < Problem.MinHeight;
        PeaksHeight(tmp) = (2*Problem.MinHeight)- PeaksHeight(tmp);
        tmp = PeaksWidth > Problem.MaxWidth;
        PeaksWidth(tmp) = (2*Problem.MaxWidth)- PeaksWidth(tmp);
        tmp = PeaksWidth < Problem.MinWidth;
        PeaksWidth(tmp) = (2*Problem.MinWidth)- PeaksWidth(tmp);
        Problem.PeaksPosition(:,:,ii)= PeaksPosition;
        Problem.PeaksHeight(ii,:)    = PeaksHeight;
        Problem.PeaksWidth(ii,:)  = PeaksWidth;
        Problem.Environmentcounter = Problem.Environmentcounter + 1;
        [Problem.OptimumValue(ii), Problem.OptimumID(ii)] = max(PeaksHeight);
        for jj=1:Problem.PeakNumber
            if EnvironmentVisualization(Problem.PeaksPosition(jj,:,ii),Problem) == Problem.PeaksHeight(ii,jj)
                Problem.PeakVisibility(ii,jj)= 1;
            end
        end
    end
    Problem.Environmentcounter = 1;
end