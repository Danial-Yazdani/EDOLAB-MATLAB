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
function [Optimizer , Problem, Species] = IterativeComponents_SPSO_AP_AD(Optimizer,Problem)
%% create species, determine trackers and best tracker
[Species,Optimizer]=CreatingSpecies(Optimizer);
num_pre_iteration_tracker = numel(Optimizer.tracker);
Optimizer.tracker = [];
best_tracker_indx = [];
tmp7 = -inf;
for ii = 1:numel(Species)
    if Species(ii).distance < Optimizer.teta  
       Optimizer.tracker = [Optimizer.tracker;ii];
       %determine best tracker
       if Optimizer.Particle(Species(ii).seed).PbestFitness > tmp7
           tmp7 = Optimizer.Particle(Species(ii).seed).PbestFitness;
           best_tracker_indx = ii;
       end
    end
end
%% Exclusion
removed_particle_index = []; %includes the index of particles which will be removed by exclusion      
for ii=1:numel(Species)
    for jj=ii+1:numel(Species)
        if pdist2(Optimizer.Particle(Species(ii).seed).PbestPosition,Optimizer.Particle(Species(jj).seed).PbestPosition)<Optimizer.ExclusionLimit
            if Optimizer.Particle(Species(ii).seed).PbestFitness<Optimizer.Particle(Species(jj).seed).PbestFitness
                Species(ii).remove = 1;
                removed_particle_index = [removed_particle_index;Species(ii).member];
            else 
                Species(jj).remove = 1;
                removed_particle_index = [removed_particle_index;Species(jj).member];
            end
        end
    end
end
%% remove tracker index which were removed by exclusion
if ~isempty(Optimizer.tracker)
    for ii=numel(Optimizer.tracker):-1:1
        if Species(Optimizer.tracker(ii)).remove==1
            Optimizer.tracker(ii) = [];
        end
    end
end
num_current_iteration_tracker = numel(Optimizer.tracker);
%%  compare the number of trackers with previous iteration. If it changed, reset the current deactivation value
if num_pre_iteration_tracker < num_current_iteration_tracker
    Optimizer.CurrentDeactivation = Optimizer.MaxDeactivation;
end
%% deactive converged trackers, except for best tracker
tmp9 = 1;
if ~isempty(Optimizer.tracker)
    for ii=1:numel(Optimizer.tracker)
        if Species(Optimizer.tracker(ii)).distance >Optimizer.CurrentDeactivation
            tmp9 = 0;
        else
            if Optimizer.tracker(ii)~=best_tracker_indx
                Species(Optimizer.tracker(ii)).Active = 0;
            end
        end
    end
end
%% Update current deactivation value
if tmp9 == 1 && ~isempty(Optimizer.tracker)
    if Optimizer.CurrentDeactivation > Optimizer.MinDeactivation
        Optimizer.beta = Optimizer.beta * Optimizer.gama;
        Optimizer.CurrentDeactivation =Optimizer.MinDeactivation + (Optimizer.MaxDeactivation-Optimizer.MinDeactivation)*Optimizer.beta;
    end
end
%% remove any species according to their "remove" field
for ii=numel(Species):-1:1
    if Species(ii).remove==1
        Species(ii) = [];
    end
end  
%% update exclusion/generate radious
Optimizer.ExclusionLimit = 0.5*((Optimizer.MaxCoordinate-Optimizer.MinCoordinate)/(numel(Species)) ^ (1/Optimizer.Dimension));
Optimizer.GenerateRadious = 0.3 * ((Optimizer.MaxCoordinate-Optimizer.MinCoordinate)/(numel(Species)) ^ (1/Optimizer.Dimension));
%% Check if all species are convereged
allConverge = 1;
for ii=1:numel(Species)   
    if Species(ii).distance > Optimizer.GenerateRadious
        allConverge = 0 ;
        break
    end
end
%% Check the number of sub-populations to trigger anti-convergence
if numel(Species) >= Optimizer.Nmax && allConverge ==1
    allConverge = 0;
    WorstSwarmValue = inf;
    WorstSwarmIndex = [];
    for ii=1:numel(Species)
        if Optimizer.Particle(Species(ii).seed).PbestFitness < WorstSwarmValue
            WorstSwarmValue = Optimizer.Particle(Species(ii).seed).PbestFitness;
            WorstSwarmIndex = ii;
        end
    end
    for kk=1:Optimizer.SwarmMember                   
        [Optimizer.Particle(Species(WorstSwarmIndex).member(kk)),Problem] = SubPopulationGenerator_SPSO_AP_AD(Optimizer.MinCoordinate,Optimizer.MaxCoordinate,1,Optimizer.Dimension,Problem);       
        if Problem.RecentChange == 1
            [Species,Optimizer]=CreatingSpecies(Optimizer);
            return;
        end
    end
    Species(WorstSwarmIndex).Active = 1;
end
%% Run PSO
for ii=1 : numel(Species)
    if Species(ii).Active ==1
        for jj=1 : Optimizer.SwarmMember
            Optimizer.Particle(Species(ii).member(jj)).Velocity = Optimizer.x *(Optimizer.Particle(Species(ii).member(jj)).Velocity+(Optimizer.c1*rand(1,Optimizer.Dimension).*(Optimizer.Particle(Species(ii).member(jj)).PbestPosition-Optimizer.Particle(Species(ii).member(jj)).X))+(Optimizer.c2*rand(1,Optimizer.Dimension).*(Optimizer.Particle(Species(ii).seed).PbestPosition-Optimizer.Particle(Species(ii).member(jj)).X)));            
            Optimizer.Particle(Species(ii).member(jj)).X = Optimizer.Particle(Species(ii).member(jj)).Velocity + Optimizer.Particle(Species(ii).member(jj)).X;
            %bound handling
            tmp1 = Optimizer.Particle(Species(ii).member(jj)).X<Optimizer.MinCoordinate;
            Optimizer.Particle(Species(ii).member(jj)).X(tmp1)=Optimizer.MinCoordinate;
            Optimizer.Particle(Species(ii).member(jj)).Velocity(tmp1)=0;
            tmp2 = Optimizer.Particle(Species(ii).member(jj)).X>Optimizer.MaxCoordinate;
            Optimizer.Particle(Species(ii).member(jj)).X(tmp2)=Optimizer.MaxCoordinate;
            Optimizer.Particle(Species(ii).member(jj)).Velocity(tmp2)=0;                
            %update fitness
            [Optimizer.Particle(Species(ii).member(jj)).FitnessValue,Problem]=fitness(Optimizer.Particle(Species(ii).member(jj)).X,Problem);
            if Problem.RecentChange == 1
                if ~isempty(removed_particle_index)
                    Optimizer.Particle(removed_particle_index) = [];
                end
                [Species,Optimizer]=CreatingSpecies(Optimizer);
                return
            end   
            %update Pbest
            if Optimizer.Particle(Species(ii).member(jj)).FitnessValue>Optimizer.Particle(Species(ii).member(jj)).PbestFitness
                Optimizer.Particle(Species(ii).member(jj)).PbestFitness=Optimizer.Particle(Species(ii).member(jj)).FitnessValue;
                Optimizer.Particle(Species(ii).member(jj)).PbestPosition=Optimizer.Particle(Species(ii).member(jj)).X;
            end
        end
    end
end
%% remove particles which were removed by exclusion
if ~isempty(removed_particle_index)
    Optimizer.Particle(removed_particle_index) = [];
    [Species,Optimizer]=CreatingSpecies(Optimizer);
end
%% Insert individuals if all species are convereged
if numel(Species) < Optimizer.Nmax && allConverge ==1
    for ii=1:Optimizer.NewlyAddedPopulationSize      
        [Optimizer.Particle(numel(Optimizer.Particle)+1),Problem] = SubPopulationGenerator_SPSO_AP_AD(Optimizer.MinCoordinate,Optimizer.MaxCoordinate,1,Optimizer.Dimension,Problem);       
        if Problem.RecentChange == 1
            [Species,Optimizer]=CreatingSpecies(Optimizer);
            return;
        end
    end 
end 