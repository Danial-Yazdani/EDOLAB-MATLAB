%********************************TMIPSO*****************************************************
%Author: Delaram Yazdani
%E-mail: delaram DOT yazdani AT yahoo DOT com
%Last Edited: July 21, 2022
%
% ------------
% Reference:
% ------------
%
%  Hongfeng Wang et al.,
%            "Triggered Memory-Based Swarm Optimization in Dynamic Environments"
%            Applications of Evolutionary Computing, pp. 637-646, 2007.
%
% --------
% License:
% --------
% This program is to be used under the terms of the GNU General Public License
% (http://www.gnu.org/copyleft/gpl.html).
% e-mail: danial DOT yazdani AT gmail DOT com
% Copyright notice: (c) 2023 Danial Yazdani
%*****************************************************************************************
function [Optimizer,Problem] = ChangeReaction_TMIPSO(Optimizer,Problem)
%% Updating ExploiPop
[Optimizer.ExploitPop.PbestValue,Problem] = fitness(Optimizer.ExploitPop.PbestPosition , Problem);
[BestPbestValue,BestPbestID] = max(Optimizer.ExploitPop.PbestValue);
Optimizer.ExploitPop.BestValue = BestPbestValue;
Optimizer.ExploitPop.BestPosition = Optimizer.ExploitPop.PbestPosition(BestPbestID,:);
%% Updating ExplorePop
[Optimizer.ExplorePop.PbestValue,Problem] = fitness(Optimizer.ExplorePop.PbestPosition , Problem);
[BestPbestValue,BestPbestID] = max(Optimizer.ExplorePop.PbestValue);
Optimizer.ExplorePop.BestValue = BestPbestValue;
Optimizer.ExplorePop.BestPosition = Optimizer.ExplorePop.PbestPosition(BestPbestID,:);
%% Updating Memory
[Optimizer.MemoryFitness,Problem] = fitness(Optimizer.MemoryPosition , Problem);
