%*********************************psfNBC**********************
%
%Author: Zeneng She
%Last Edited: October 30, 2022
% e-mail: shezeneng AT qq DOT com
%
% ------------
% Reference:
% ------------
%
%  Wenjian Luo et al.,
%       "Identifying Species for Particle Swarm Optimization under Dynamic Environments," 
%       Proceedings of the 2018 IEEE Symposium Series on Computational Intelligence, 2019.
%
% --------
% License:
% --------
% This program is to be used under the terms of the GNU General Public License
% (http://www.gnu.org/copyleft/gpl.html).
% e-mail: danial.yazdani AT gmail dot com
% Copyright notice: (c) 2023 Danial Yazdani
%**************************************************************************
function [Optimizer,Problem] = ChangeReaction_psfNBC(Optimizer,Problem)
%% update memory
seeds = Optimizer.seeds;
Mem = Optimizer.Mem;
mem_Maxsize = Optimizer.mem_Maxsize;
Mem_fit = Optimizer.Mem_fit;
p_self = Optimizer.pop.X;
p_best = Optimizer.pop.PbestPosition;
p_bestfit = Optimizer.pop.PbestValue;
p_v = Optimizer.pop.Velocity;
p_fit = Optimizer.pop.FitnessValue;
n = Optimizer.PopulationSize;
rs = Optimizer.rs;
dim = Optimizer.Dimension;

num_export=min(5,length(seeds));
for i=1:num_export
    mem_size=size(Mem,1);
    wn=seeds(i);
    if mem_size < mem_Maxsize
        Mem=[Mem;p_best(wn,:)];   %% put the best into the memory
        Mem_fit=[Mem_fit p_bestfit(wn)];
    else
        [~,mn]=min(sum((ones(mem_size,1)*p_best(wn,:)-Mem).^2,2));
        if Mem_fit(mn)<p_bestfit(wn)
            Mem(mn,:)=p_best(wn,:);
            Mem_fit(mn)=p_bestfit(wn);
        end
    end
end
%%    update the population
for i=1:n
    [p_fit(i),~]=fitness(p_self(i,:), Problem);   %% reevaluate the population
end
[~,sortorder]=sort(p_fit,'descend');
p_self=p_self(sortorder,:);
p_fit=p_fit(sortorder);
p_v=p_v(sortorder,:);
if ~isempty(Mem)
    ml=size(Mem,1);
    for i=1:ml
        [Mem_fit(i)]=fitness(Mem(i,:),Problem);
    end
    [~,sortorder]=sort(Mem_fit,'descend');
    Mem=Mem(sortorder,:);
    Mem_fit=Mem_fit(sortorder);
    %% random 2
    r1=quantum(Mem(1,:),0.1*rs,Optimizer);
    [r1_fit]=fitness(r1, Problem);
    r2=quantum(Mem(1,:),0.1*rs,Optimizer);
    [r2_fit]=fitness(r2, Problem);
    %% update the population by the memory
    p_self(n,:)=Mem(1,:);
    p_fit(n)=Mem_fit(1);
    p_v(n,:)=zeros(1,dim);
    
    p_self(n-1,:)=r1;
    p_fit(n-1)=r1_fit;
    p_v(n-1,:)=zeros(1,dim);
    
    p_self(n-2,:)=r2;
    p_fit(n-2)=r2_fit;
    p_v(n-2,:)=zeros(1,dim);
    
end
p_bestfit=p_fit;
p_best=p_self;
Optimizer.successfault=zeros(1,n);
Optimizer.numInitial=(1-Optimizer.ratio)*Optimizer.PopulationSize;

Optimizer.pop.X = p_self;
Optimizer.pop.PbestPositon = p_best;
Optimizer.pop.PbestValue = p_bestfit;
Optimizer.pop.FitnessValue = p_fit;
Optimizer.pop.Velocity = p_v;
Optimizer.Mem =  Mem;
Optimizer.Mem_fit = Mem_fit;

[Optimizer.pop.BestValue,BestPbestID] = max(Optimizer.pop.PbestValue);
Optimizer.pop.BestPosition = Optimizer.pop.PbestPosition(BestPbestID,:);
end

function x = quantum(core, length, Optimizer)
    v = randn(1, Optimizer.Dimension);
    len = sqrt(sum(v.^2, 2));

    if len ~= 0
        len = length / len;
    end

    v = v * len;
    x = core + v;
    x = boundary_check(x, Optimizer.MinCoordinate, Optimizer.MaxCoordinate);

end

function x = boundary_check(x, lower_bound, upper_bound)

    while (any(x < lower_bound) || any(x > upper_bound))
        x = (x < lower_bound) .* (2 * lower_bound - x) + (x >= lower_bound) .* x;
        x = (x > upper_bound) .* (2 * upper_bound - x) + (x <= upper_bound) .* x;
    end

end
