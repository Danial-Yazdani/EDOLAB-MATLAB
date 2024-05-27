%**************Generalized Dynamic Benchmark Generator (GDBG)******************************************************************************
%
%Author: Mai Peng
%Last Edited: May 11, 2024
% e-mail: pengmai1998 AT gmail dot com
%
% ------------
% Reference:
% ------------
%
%  C. Li et al.,
%            "A Generalized Approach to Construct Benchmark Problems for Dynamic Optimization,"
%            SEAL2008, 2008.
%
% --------
% License:
% --------
% This program is to be used under the terms of the GNU General Public License
% (http://www.gnu.org/copyleft/gpl.html).
% e-mail: danial DOT yazdani AT gmail DOT com
% Copyright notice: (c) 2024 Danial Yazdani
%*************************************************************************************************************************************
function [result,Problem] = fitness_GDBG(X,Problem)
   result = composition_DBG(X, Problem);
end

%% Composition
function F = composition_DBG(X, Problem)
    function_map = {@Sphere, @Rastrigin, @Weierstrass, @Griewank, @Ackley};
    range_map = [-100, 100; -5, 5; -0.5, 0.5; -100, 100; -32, 32];
    selected_indices = Problem.FunctionSelect(Problem.Environmentcounter,:);
    basic_funcs = function_map(selected_indices);
    search_range = range_map(selected_indices, :);
    F = zeros(size(X, 1), 1);
    for n = 1:size(X, 1)
        x = X(n, :);    
        % lambda_i
        m = length(basic_funcs);
        sigma_i = ones(m, 1);
        lambda_i = zeros(m, 1);
        for i = 1:m
            lambda_i(i) = sigma_i(i) * (Problem.MaxCoordinate - Problem.MinCoordinate) / (search_range(i,2) - search_range(i,1));
        end
        O = Problem.PeaksPosition(:,:,Problem.Environmentcounter);
        H = Problem.PeaksHeight(Problem.Environmentcounter,:);
        M = Problem.M;

        weights = zeros(1, length(basic_funcs));
        max_weight = 0;
        for i = 1:length(basic_funcs)
            weights(i) = weight(x, O(i,:), sigma_i(i));
            if weights(i) > max_weight
                max_weight = weights(i);
            end
        end

        for i = 1:length(weights)
            if weights(i) ~= max_weight
                weights(i) = weights(i) * (1 - power(max_weight, 10));
            end
        end

        weights = weights / sum(weights);
        
        C = 2000;
        for i = 1:length(basic_funcs)
            fi = basic_funcs{i};
            fi_max = fi(search_range(i,2) .* ones(1, Problem.Dimension) * M);
            fi0 = @(x) C * fi(x) / abs(fi_max);
            Fi = -fi0((x - O(i,:)) / lambda_i(i) * M) + H(i);
            F = F + weights(i) * Fi;
        end
    end
end

function w = weight(x, O_i, sigma)
    w = exp(-sqrt(sum((x - O_i).^2) / (2 * numel(x) * sigma^2)));
end

%% GDBG Function
% Sphere
function y = Sphere(x)
    y = sum(x.^2);
end

% Rastrigin
function y = Rastrigin(x)
    y = sum(x.^2 - 10 * cos(2 * pi * x) + 10);
end

% Weierstrass
function y = Weierstrass(x)
    a = 0.5;
    b = 3;
    kmax = 20;
    sum1 = 0;
    for k = 0:kmax
        sum1 = sum1 + (a^k) * cos(2 * pi * (b^k) * (x + 0.5));
    end
    sum2 = 0;
    for k = 0:kmax
        sum2 = sum2 + (a^k) * cos(pi * (b^k));
    end
    y = sum(sum1) - length(x) * sum2;
end

% Griewank
function y = Griewank(x)
    sum_sq = sum(x.^2);
    prod_cos = prod(cos(x ./ sqrt(1:length(x))));
    y = 1 + sum_sq / 4000 - prod_cos;
end

% Ackley
function y = Ackley(x)
    sum_sq = sum(x.^2);
    sum_cos = sum(cos(2 * pi * x));
    n = length(x);
    y = -20 * exp(-0.2 * sqrt(sum_sq / n)) - exp(sum_cos / n) + 20 + exp(1);
end