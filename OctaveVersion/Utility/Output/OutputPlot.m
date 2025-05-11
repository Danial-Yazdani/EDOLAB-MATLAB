% ------------
% Notification:
% ------------
%
% This file has been modified to ensure compatibility with Octave.
% These modifications include adjustments to MATLAB-specific functions
% and features, allowing the code to run in the Octave environment.
% Users who wish to run EDOLAB in Octave should replace the original file
% with this modified version.
%

%% Generating figure
function [FigureCurrentError] = OutputPlot(CurrentError, RunNumber, E_o, E_bbc, AlgorithmName)
    disp('Generating figure: please wait for calculating the offline error over time...');
    pkg load control;
    figure;

    % Handle the case when RunNumber > 1
    if RunNumber > 1
        FigureCurrentError = mean(CurrentError);
    else
        FigureCurrentError = CurrentError;
    end

    % Plot the current error
    semilogy(FigureCurrentError, 'r', 'DisplayName', 'Current Error');
    hold on;

    % Calculate cumulative sum of error for offline error
    cumsumError = cumsum(FigureCurrentError);
    FigureOfflineError = cumsumError ./ (1:length(FigureCurrentError));
    semilogy(FigureOfflineError, 'b', 'LineWidth', 2, 'DisplayName', 'Offline Error');

    % Set labels and figure properties
    xlabel('Fitness Evaluation');
    ylabel('Error');
    set(gcf, 'Position', [100, 100, 900, 400]);
    legend;
    grid on;
    set(gcf, 'NumberTitle', 'off');  % Don't show the figure number

    % Concatenate the figure name (fixing the append issue)
    FigureName = [AlgorithmName, ': E_o = ', num2str(E_o.mean), ' , E_bbc = ', num2str(E_bbc.mean)];
    set(gcf, 'Name', FigureName);
end

