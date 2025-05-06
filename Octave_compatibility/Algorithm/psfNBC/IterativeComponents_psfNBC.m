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
function [Optimizer, Problem] = IterativeComponents_psfNBC(Optimizer, Problem)
    %% Sub-swarm movement
    lower_bound = Optimizer.MinCoordinate;
    upper_bound = Optimizer.MaxCoordinate;
    bounds = [lower_bound, upper_bound];
    n = Optimizer.PopulationSize;
    %% set for range of velocity
    max_v = (bounds(2) - bounds(1)) / 2;
    min_v = -max_v;

    %% parameters used in DE,DE/best/1
    w = Optimizer.x;
    c1 = Optimizer.c1;
    c2 = Optimizer.c2;
    p_Max = 10;
    dim = Optimizer.Dimension;
    %% rs in spso
    Optimizer.rs = (upper_bound - lower_bound) * sqrt(dim) / (2 * power(Problem.PeakNumber, 1 / dim));
    %% initialization
    p_self = Optimizer.pop.X;
    p_best = Optimizer.pop.PbestPosition;
    p_v = Optimizer.pop.Velocity;
    p_fit = Optimizer.pop.FitnessValue;
    p_bestfit = Optimizer.pop.PbestValue;
    successfault = Optimizer.successfault;

    %% evolve
    %% first set change=fales
    Problem.RecentChange = 0;
    %% sort particles in fitness descending order and calculate distances among them
    [~, sortorder] = sort(p_bestfit, 'descend');
    p_bestfit = p_bestfit(sortorder);
    p_fit = p_fit(sortorder);
    p_v = p_v(sortorder, :);
    p_best = p_best(sortorder, :);
    p_self = p_self(sortorder, :);
    successfault = successfault(sortorder);
    matdis = zeros(n, n);

    for i = 1:n - 1
        matdis(i + 1:n, i) = sqrt(sum((ones(n - i, 1) * p_best(i, :) - p_best(i + 1:n, :)).^2, 2));
        matdis(i, i + 1:n) = matdis(i + 1:n, i);
    end

    %% divide to species
    [m, Optimizer.seeds] = psfNBC(Optimizer, matdis);
    Optimizer.numInitial = 0;
    %% evolve each species
    count = 1;

    while ~isempty(m)
        s = m(m(:, 2) == count, 1);
        %% check convergence
        b = check_converge(matdis, s);

        if b == true
            mem_size = size(Optimizer.Mem, 1);

            if mem_size < Optimizer.mem_Maxsize
                Optimizer.Mem = [Optimizer.Mem; p_best(s(1), :)];
                Optimizer.Mem_fit = [Optimizer.Mem_fit, p_bestfit(s(1))];
            else
                [~, mn] = min(sum((ones(mem_size, 1) * p_best(s(1), :) - Optimizer.Mem).^2, 2));

                if Optimizer.Mem_fit(mn) < p_bestfit(s(1))
                    Optimizer.Mem(mn, :) = p_best(s(1), :);
                    Optimizer.Mem_fit(mn) = p_bestfit(s(1));
                end

            end

            p_self(s, :) = rand(length(s), dim) * (bounds(2) - bounds(1)) + bounds(1);
            p_best(s, :) = p_self(s, :);
            p_v(s, :) = rand(length(s), dim) * (max_v - min_v) + min_v;

            for i = 1:length(s)
                [p_fit(s(i)), Problem] = fitness(p_self(s(i), :), Problem);
                p_bestfit(s(i)) = p_fit(s(i));
                successfault(s(i)) = 0;
                Optimizer.numInitial = Optimizer.numInitial + 1;

                if Problem.RecentChange == 1
                    break;
                end

            end

        else
            %% remove redudant particles
            if length(s) > p_Max

                for i = p_Max + 1:length(s)
                    p_self(s(i), :) = rand(1, dim) .* (bounds(2) - bounds(1)) + bounds(1);
                    p_best(s(i), :) = p_self(s(i), :);
                    p_v(s(i), :) = rand(1, dim) .* (max_v - min_v) + min_v;
                    [p_fit(s(i)), Problem] = fitness(p_self(s(i), :), Problem);
                    p_bestfit(s(i)) = p_fit(s(i));
                    successfault(s(i)) = 0;
                    Optimizer.numInitial = Optimizer.numInitial + 1;

                    if Problem.RecentChange == 1
                        break;
                    end

                end

                s = s(1:p_Max);
            end

            if Problem.RecentChange == 1
                break;
            end

            %% evolve species
            seed = s(1);

            for i = 1:length(s)
                curr = s(i);

                if i == length(s) && successfault(seed) >= 3
                    xtmp = quantum(p_best(seed, :), 1.0, Optimizer);
                elseif i == 1
                    p_v(curr, :) = w * (p_v(curr, :) + c1 * rand(1, dim) .* (p_best(curr, :) - p_self(curr, :))) + (randn(1, dim) * 0.2);
                    xtmp = p_self(curr, :) + p_v(curr, :);
                else
                    p_v(curr, :) = w * (p_v(curr, :) + c1 * rand(1, dim) .* (p_best(curr, :) - p_self(curr, :)) + c2 * rand(1, dim) .* (p_best(seed, :) - p_self(curr, :)));
                    xtmp = p_self(curr, :) + p_v(curr, :);
                end

                xtmp = boundary_check(xtmp, lower_bound, upper_bound);
                p_v(curr, :) = xtmp - p_self(curr, :);
                p_self(curr, :) = xtmp;
                [p_fit(curr), Problem] = fitness(p_self(curr, :), Problem);

                if i == length(s) && successfault(seed) >= 3

                    if p_fit(curr) > p_bestfit(seed)
                        p_v(curr, :) = p_self(curr, :) - p_best(seed, :);
                    else
                        p_v(curr, :) = p_best(seed, :) - p_self(curr, :);
                    end

                end

                p_v(curr, :) = (p_v(curr, :) < min_v) .* min_v + (p_v(curr, :) >= min_v) .* p_v(curr, :);
                p_v(curr, :) = (p_v(curr, :) > max_v) .* max_v + (p_v(curr, :) <= max_v) .* p_v(curr, :);

                if p_fit(curr) > p_bestfit(curr)
                    p_bestfit(curr) = p_fit(curr);
                    p_best(curr, :) = p_self(curr, :);
                    successfault(curr) = 0;
                else
                    successfault(curr) = successfault(curr) + 1;
                end

                if Problem.RecentChange == 1
                    break;
                end

            end

        end

        Optimizer.pop.X = p_self;
        Optimizer.pop.FitnessValue = p_fit;
        Optimizer.pop.PbestPosition = p_best;
        Optimizer.pop.PbestValue = p_bestfit;
        Optimizer.pop.Velocity = p_v;
        Optimizer.successfault = successfault;

        m = m(m(:, 2) ~= count, :);
        count = count + 1; % species number

        if Problem.RecentChange == 1
            return
        end

    end

    [BestPbestValue, BestPbestID] = max(Optimizer.pop.PbestValue);

    if BestPbestValue > Optimizer.pop.BestValue
        Optimizer.pop.BestValue = BestPbestValue;
        Optimizer.pop.BestPosition = Optimizer.pop.PbestPosition(BestPbestID, :);
    end

end

function b = check_converge(matdis, s)
    b = false;

    if length(s) > 1
        seed = s(1);
        meandis = mean(matdis(seed, s(2:end)));

        if meandis <= 0.0001
            b = true;
        end

    end

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

function [m, seeds] = psfNBC(Optimizer, matdis)
    %PSNBC
    % matdis is the mix of distances between current and history
    % m is result of the mix

    fu = 2.25;
    fl = 1.25;
    factor = fl + rand() * (fu - fl);
    numInitial = Optimizer.numInitial;
    n = length(matdis);
    partial = n - numInitial;

    if numInitial > 0
        partial = partial + 1;
    end

    nbc = zeros(partial, 3);
    nbc(:, 1) = 1:partial;
    nbc(1, 2) = -1;
    nbc(1, 3) = 0;

    for i = 2:partial
        [u, v] = min(matdis(i, 1:i - 1));
        nbc(i, 2) = v;
        nbc(i, 3) = u;
    end

    meandis = factor * mean(nbc(2:end, 3));
    nbc(nbc(:, 3) > meandis, 2) = -1;
    nbc(nbc(:, 3) > meandis, 3) = 0;
    seeds = nbc(nbc(:, 2) == -1, 1);
    m = zeros(n, 2);
    m(:, 1) = 1:n;

    for i = 1:n
        [~, v] = min(matdis(seeds, i));
        m(i, 2) = seeds(v);
    end

    count = 1;

    for i = 1:length(seeds)
        m(m(:, 2) == seeds(i), 2) = count;
        count = count + 1;
    end

end
