%********************************SPSO_AP_AD*****************************************************
%Author: Delaram Yazdani
%E-mail: delaram DOT yazdani AT yahoo DOT com
%Last Edited: July 12, 2023
%
% ------------
% Reference:
% ------------
%
%  Delaram Yazdani et al.,
%            "A Species-based Particle Swarm Optimization with Adaptive Population Size and Deactivation of Species for Dynamic Optimization Problems"
%            ACM Transactions on Evolutionary Learning and Optimization, 2023.
%
% --------
% License:
% --------
% This program is to be used under the terms of the GNU General Public License
% e-mail: danial DOT yazdani AT gmail DOT com
% Copyright notice: (c) 2023 Danial Yazdani
%*****************************************************************************************
function [Species,Optimizer]= CreatingSpecies(Optimizer)
for ii=1:numel(Optimizer.Particle)
    Optimizer.Particle(ii).Processed = 0;
end    
[~,SortIndex] = sort([Optimizer.Particle.PbestFitness],'descend');
x = 1;
for jj=1: numel(Optimizer.Particle)
    PopList = NaN(1,numel(Optimizer.Particle));
    if Optimizer.Particle(SortIndex(jj)).Processed == 0
        Species(x).seed = SortIndex(jj);
        Species(x).member = SortIndex(jj);
        Species(x).remove = 0; %if a species is removed by exclusion/overlapp, this field = 1
        Species(x).Active = 1;
        Species(x).distance = NaN;
        Optimizer.Particle(SortIndex(jj)).Processed = 1;
        for ii=1:numel(Optimizer.Particle)
            if Optimizer.Particle(ii).Processed==0
                PopList(ii) = pdist2(Optimizer.Particle(SortIndex(jj)).PbestPosition,Optimizer.Particle(ii).PbestPosition);
            end
        end
        [~,SortDistance] = sort(PopList);
        for n = 1: (Optimizer.SwarmMember-1)
            Species(x).member = [Species(x).member;SortDistance(n)];
            Optimizer.Particle(SortDistance(n)).Processed =1;               
        end 
        Species(x).distance = max(PopList(SortDistance(1:(Optimizer.SwarmMember-1))));
        x = x+1;
    end
end