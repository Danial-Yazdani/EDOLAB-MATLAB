%**************Moving Peaks Benchmark (MPB)***********************************************
%Author: Danial Yazdani
% e-mail: danial DOT yazdani AT gmail DOT com
%Last Edited: February 10, 2022
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
% e-mail: danial DOT yazdani AT gmail DOT com
% Copyright notice: (c) 2023 Danial Yazdani
%*****************************************************************************************
function [result,Problem] = fitness_MPB(X,Problem)
   result = max(Problem.PeaksHeight(Problem.Environmentcounter,:) - ((Problem.PeaksWidth(Problem.Environmentcounter,:) .* (pdist2(X,Problem.PeaksPosition(:,:,Problem.Environmentcounter))))));
end