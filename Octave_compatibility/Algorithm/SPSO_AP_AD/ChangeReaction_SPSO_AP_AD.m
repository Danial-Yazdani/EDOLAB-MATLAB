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
function [Optimizer,Problem] = ChangeReaction_SPSO_AP_AD(Optimizer,Problem,Species)
%% determine trackers
Optimizer.tracker = [];
for ii=1:numel(Species) 
    if Species(ii).distance < Optimizer.teta
        Optimizer.tracker = [Optimizer.tracker;ii];
    end
end
%% Updating shift severity
dummy = NaN(numel(Optimizer.tracker),1);
for jj=1 : numel(Optimizer.tracker)
    for ii=1:Optimizer.SwarmMember
        if ~isempty(Optimizer.Particle(Species(Optimizer.tracker(jj)).member(ii)).Pbest_past_environment)
            Optimizer.Particle(Species(Optimizer.tracker(jj)).seed).Shifts = pdist2(Optimizer.Particle(Species(Optimizer.tracker(jj)).member(ii)).Pbest_past_environment,Optimizer.Particle(Species(Optimizer.tracker(jj)).seed).PbestPosition);             
            Optimizer.Particle(Species(Optimizer.tracker(jj)).member(ii)).Pbest_past_environment = [];
            if ii~=1
                Optimizer.Particle(Species(Optimizer.tracker(jj)).member(ii)).Shifts = [];
            end
            break
        end
    end
    if ~isempty(Optimizer.Particle(Species(Optimizer.tracker(jj)).seed).Shifts)
        dummy(jj) = Optimizer.Particle(Species(Optimizer.tracker(jj)).seed).Shifts;
    end
end
dummy = dummy(~isnan(dummy(:)));
if ~isnan(dummy)
    Optimizer.ShiftSeverity = mean(dummy);
end
%% increas diversity for only trackers
if ~isempty(Optimizer.tracker)
    for jj=1:numel(Optimizer.tracker)
        for ii=1:Optimizer.SwarmMember
            R = randn(1,Optimizer.Dimension);
            shift = (R./pdist2(R,zeros(size(R)))).*Optimizer.ShiftSeverity;        
            Optimizer.Particle(Species(Optimizer.tracker(jj)).member(ii)).X = Optimizer.Particle(Species(Optimizer.tracker(jj)).seed).PbestPosition + shift;
        end
        Optimizer.Particle(Species(Optimizer.tracker(jj)).seed).X = Optimizer.Particle(Species(Optimizer.tracker(jj)).seed).PbestPosition;
        Optimizer.Particle(Species(Optimizer.tracker(jj)).seed).Pbest_past_environment = Optimizer.Particle(Species(Optimizer.tracker(jj)).seed).PbestPosition;    
    end
end  
%% Check bound handling
for ii=1 : numel(Species)
    for jj=1 : Optimizer.SwarmMember
        tmp1 = Optimizer.Particle(Species(ii).member(jj)).X<Optimizer.MinCoordinate;
        Optimizer.Particle(Species(ii).member(jj)).X(tmp1)=Optimizer.MinCoordinate;
        Optimizer.Particle(Species(ii).member(jj)).Velocity(tmp1)=0;
        tmp2 = Optimizer.Particle(Species(ii).member(jj)).X>Optimizer.MaxCoordinate;
        Optimizer.Particle(Species(ii).member(jj)).X(tmp2)=Optimizer.MaxCoordinate;
        Optimizer.Particle(Species(ii).member(jj)).Velocity(tmp2)=0;      
    end
end
%% Updating memory for all
for jj=1 : numel(Optimizer.Particle)
    [Optimizer.Particle(jj).FitnessValue,Problem] = fitness(Optimizer.Particle(jj).X , Problem);
    Optimizer.Particle(jj).PbestFitness = Optimizer.Particle(jj).FitnessValue;
    Optimizer.Particle(jj).PbestPosition = Optimizer.Particle(jj).X;
end
%% Updating thresholds parameters
Optimizer.MaxDeactivation = Optimizer.rho * Optimizer.ShiftSeverity;
Optimizer.CurrentDeactivation = Optimizer.MaxDeactivation;
Optimizer.teta = Optimizer.ShiftSeverity;
Optimizer.beta = 1;
