%This is how the real-time figures are drawn
function OutputEducationalFigures(Iteration,PeakNumber,VisualizationInfo,CurrentError,Problem)
    for ij =1 : Iteration
        ax1 = subplot(1,2,1);
        ax2 = subplot(1,2,2);
        contour(ax1,VisualizationInfo{ij}.T,VisualizationInfo{ij}.T,VisualizationInfo{ij}.F,25);
        colormap cool;
        xlabel(ax1,'x_1')
        ylabel(ax1,'x_2')
        grid(ax1,'on');
        hold(ax1,'on');
        for ii=1 : PeakNumber
            if VisualizationInfo{ij}.Problem.PeakVisibility(ii)==1
                if ii == VisualizationInfo{ij}.Problem.OptimumID
                    plot(ax1,VisualizationInfo{ij}.Problem.PeaksPosition(ii,2),VisualizationInfo{ij}.Problem.PeaksPosition(ii,1),'p','markersize',15,'markerfacecolor','none','MarkerEdgeColor','k','LineWidth',1.5);
                else
                    plot(ax1,VisualizationInfo{ij}.Problem.PeaksPosition(ii,2),VisualizationInfo{ij}.Problem.PeaksPosition(ii,1),'o','markersize',15,'markerfacecolor','none','MarkerEdgeColor','k','LineWidth',1.5);
                end
            end
        end
        for ii=1 : VisualizationInfo{ij}.IndividualNumber
            plot(ax1,VisualizationInfo{ij}.Individuals(ii,2),VisualizationInfo{ij}.Individuals(ii,1),'o','markersize',7,'markerfacecolor','g','MarkerEdgeColor','none');
        end
        hold(ax1,'off');
        semilogy(ax2,CurrentError(1:VisualizationInfo{ij}.FE),'r','DisplayName','Current Error');
        xlabel(ax2,'Fitness Evaluation');
        ylabel(ax2,'Current Error');
        xlim(ax2,[0 Problem.MaxEvals])
        ylim(ax2,[0 1000])
        legend;
        grid(ax2,'on');
        set(gcf, 'Position',  [100, 100, 1400, 600])
        drawnow;
    end
end