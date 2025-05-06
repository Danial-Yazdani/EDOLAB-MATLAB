%% Generating figure
function [FigureCurrentError] = OutputPlot(CurrentError,RunNumber,E_o,E_bbc,AlgorithmName)
    disp('Generating figure: please wait for calculating the offline error over time...');
    figure;
    if RunNumber>1
        FigureCurrentError = mean(CurrentError);
    else
        FigureCurrentError = CurrentError;
    end
    semilogy(FigureCurrentError,'r','DisplayName','Current Error');
    hold on;
    cumsumError = cumsum(FigureCurrentError);
    FigureOfflineError = cumsumError ./ (1:length(FigureCurrentError));
    semilogy(FigureOfflineError,'b','LineWidth',2,'DisplayName','Offline Error');
    xlabel('Fitness Evaluation');
    ylabel('Error');
    set(gcf, 'Position',  [100, 100, 900, 400])
    legend;
    grid on;
    set(gcf,'NumberTitle','off') %don't show the figure number
    FigureName = append(AlgorithmName, ': E_o = ',num2str(E_o.mean),' , E_bbc = ',num2str(E_bbc.mean));
    set(gcf,'Name',FigureName)
end