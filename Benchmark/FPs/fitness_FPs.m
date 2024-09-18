%**************Free Peaks Benchmark (FPs)******************************************************************************
%
%Author: Mai Peng
%Last Edited: November 3, 2022
% e-mail: pengmai1998 AT gmail dot com
%
% ------------
% Reference:
% ------------
%
%  C. Li et al.,
%            "An open framework for constructing continuous optimization problems,"
%            IEEE Transactions on Cybernetics, Vol. 49(6), 2018.
%
% --------
% License:
% --------
% This program is to be used under the terms of the GNU General Public License
% (http://www.gnu.org/copyleft/gpl.html).
% e-mail: danial DOT yazdani AT gmail DOT com
% Copyright notice: (c) 2023 Danial Yazdani
%*************************************************************************************************************************************
function [result,Problem] = fitness_FPs(X,Problem)
   for jj = 1:Problem.Dimension        %Ensure that out of bounds solutions can be evaluated normally
      if (X(1,jj) < Problem.MinCoordinate)
         X(1,jj) = Problem.MinCoordinate;
      elseif (X(1,jj) > Problem.MaxCoordinate)
         X(1,jj) = Problem.MaxCoordinate;
      end
   end
   [Map_X,X_SubSpace] = Transfer(X,Problem,Problem.Environmentcounter);
   result = SelectFitnessFunc(Map_X(1,:),X_SubSpace(1),Problem.FunctionSelect(Problem.Environmentcounter,X_SubSpace(1)),Problem,Problem.Environmentcounter,Problem.LowestValue);
end
%% FPs Function
% X->real location, Map_X->map location, k->the id of subspace
function [Map_X,X_SubSpaceID] = Transfer(X,Problem,EnvironmentNum)
Map_X = zeros(size(X,1),Problem.Dimension);
X_SubSpaceID = zeros(size(X,1),1);
Sv_l = -100;
Sv_u = 100;
for i = 1:size(X,1)
    for j = 1:Problem.PeakNumber
        for k = 1:Problem.Dimension
            if(X(i,k) >= Problem.SubSpace(k,1,j,EnvironmentNum) && X(i,k) <= Problem.SubSpace(k,2,j,EnvironmentNum))
            else
                break;
            end
            if(k == Problem.Dimension)
                X_SubSpaceID(i) = j;
                for gg = 1:Problem.Dimension
                    Map_X(i,gg) = Sv_l + (Sv_u - Sv_l)*(X(i,gg)-Problem.SubSpace(gg,1,j,EnvironmentNum))/(Problem.SubSpace(gg,2,j,EnvironmentNum)-Problem.SubSpace(gg,1,j,EnvironmentNum));
                end
            end
        end
    end
end
end

function y = SelectFitnessFunc(x,Peak_ID,Function_ID,Problem,EnvironmentNum,lowestvalue)
    switch(Function_ID)
        case 1 
            y = s1(x,Problem.PeaksHeight(EnvironmentNum,Peak_ID),Problem.PeaksPositionMap(Peak_ID,:,EnvironmentNum),repmat([Problem.l_sv,Problem.u_sv],Problem.Dimension,1));
        case 2
            y = s3(x,Problem.PeaksHeight(EnvironmentNum,Peak_ID),Problem.PeaksPositionMap(Peak_ID,:,EnvironmentNum),repmat([Problem.l_sv,Problem.u_sv],Problem.Dimension,1));
        case 3
            y = s3(x,Problem.PeaksHeight(EnvironmentNum,Peak_ID),Problem.PeaksPositionMap(Peak_ID,:,EnvironmentNum),repmat([Problem.l_sv,Problem.u_sv],Problem.Dimension,1));
        case 4
            y = s5(x,Problem.PeaksHeight(EnvironmentNum,Peak_ID),Problem.PeaksPositionMap(Peak_ID,:,EnvironmentNum),repmat([Problem.l_sv,Problem.u_sv],Problem.Dimension,1));
        case 5
            y = s5(x,Problem.PeaksHeight(EnvironmentNum,Peak_ID),Problem.PeaksPositionMap(Peak_ID,:,EnvironmentNum),repmat([Problem.l_sv,Problem.u_sv],Problem.Dimension,1));
        case 6
            y = s6(x,Problem.PeaksHeight(EnvironmentNum,Peak_ID),Problem.PeaksPositionMap(Peak_ID,:,EnvironmentNum),repmat([Problem.l_sv,Problem.u_sv],Problem.Dimension,1),Problem.Dimension);
        case 7
            y = s7(x,Problem.PeaksHeight(EnvironmentNum,Peak_ID),Problem.PeaksPositionMap(Peak_ID,:,EnvironmentNum),repmat([Problem.l_sv,Problem.u_sv],Problem.Dimension,1),50);
        case 8
            y = s8(x,Problem.PeaksHeight(EnvironmentNum,Peak_ID),Problem.PeaksPositionMap(Peak_ID,:,EnvironmentNum),repmat([Problem.l_sv,Problem.u_sv],Problem.Dimension,1),50,3,5.5);
    end
%map the lowest value to the same level
    if(~isnan(Problem.SubSpaceLowest(EnvironmentNum,Peak_ID)))
        y = lowestvalue + (Problem.PeaksHeight(EnvironmentNum,Peak_ID) - lowestvalue) * ((y - Problem.SubSpaceLowest(EnvironmentNum,Peak_ID))/(Problem.PeaksHeight(EnvironmentNum,Peak_ID) - Problem.SubSpaceLowest(EnvironmentNum,Peak_ID)));
    end
end

function Y = s1(X,Height,Position,subspace)
%dx_X = sqrt(sum((X-repmat(Position,size(X,1),1)).^2));
q = 1;
for i = 1:size(X,2)
    if X(i) >= Position(i)
        q = q * (1-(X(i)-Position(i))/(subspace(i,2)-Position(i)));
    elseif X(i) < Position(i)
        q = q * (1-(Position(i)-X(i))/(Position(i)-subspace(i,1)));
    end
end
dx_X = (1 - q) * sqrt(sum((subspace(:,2) - subspace(:,1)).^2));
Y = Height - dx_X;
end

function Y = s2(X,Height,Position,subspace)
% dx_X = sqrt(sum((X-repmat(Position,size(X,1),1)).^2));
q = 1;
for i = 1:size(X,2)
    if X(i) >= Position(i)
        q = q * (1-(X(i)-Position(i))/(subspace(i,2)-Position(i)));
    elseif X(i) < Position(i)
        q = q * (1-(Position(i)-X(i))/(Position(i)-subspace(i,1)));
    end
end
dx_X = (1 - q) * sqrt(sum((subspace(:,2) - subspace(:,1)).^2));
Y = Height* exp(-dx_X);
end

function Y = s3(X,Height,Position,subspace)
% dx_X = sqrt(sum((X-repmat(Position,size(X,1),1)).^2));
q = 1;
for i = 1:size(X,2)
    if X(i) >= Position(i)
        q = q * (1-(X(i)-Position(i))/(subspace(i,2)-Position(i)));
    elseif X(i) < Position(i)
        q = q * (1-(Position(i)-X(i))/(Position(i)-subspace(i,1)));
    end
end
dx_X = (1 - q) * sqrt(sum((subspace(:,2) - subspace(:,1)).^2));
Y = Height - sqrt(Height * dx_X);
end

function Y = s4(X,Height,Position,subspace)
% dx_X = sqrt(sum((X-repmat(Position,size(X,1),1)).^2));
q = 1;
for i = 1:size(X,2)
    if X(i) >= Position(i)
        q = q * (1-(X(i)-Position(i))/(subspace(i,2)-Position(i)));
    elseif X(i) < Position(i)
        q = q * (1-(Position(i)-X(i))/(Position(i)-subspace(i,1)));
    end
end
dx_X = (1 - q) * sqrt(sum((subspace(:,2) - subspace(:,1)).^2));
Y = Height/(1 + dx_X);
end

function Y = s5(X,Height,Position,subspace)
% dx_X = sqrt(sum((X-repmat(Position,size(X,1),1)).^2));
q = 1;
for i = 1:size(X,2)
    if X(i) >= Position(i)
        q = q * (1-(X(i)-Position(i))/(subspace(i,2)-Position(i)));
    elseif X(i) < Position(i)
        q = q * (1-(Position(i)-X(i))/(Position(i)-subspace(i,1)));
    end
end
dx_X = (1 - q) * sqrt(sum((subspace(:,2) - subspace(:,1)).^2));
Y = Height - dx_X.^2/Height;
end

function Y = s6(X,Height,Position,subspace,Dimension)
% dx_X = sqrt(sum((X-repmat(Position,size(X,1),1)).^2));
q = 1;
for i = 1:size(X,2)
    if X(i) >= Position(i)
        q = q * (1-(X(i)-Position(i))/(subspace(i,2)-Position(i)));
    elseif X(i) < Position(i)
        q = q * (1-(Position(i)-X(i))/(Position(i)-subspace(i,1)));
    end
end
dx_X = (1 - q) * sqrt(sum((subspace(:,2) - subspace(:,1)).^2));
Y = Height - exp(2*sqrt(dx_X/sqrt(Dimension))) + 1;
end

function Y = s7(X,Height,Position,subspace,r)
% dx_X = sqrt(sum((X-repmat(Position,size(X,1),1)).^2));
q = 1;
for i = 1:size(X,2)
    if X(i) >= Position(i)
        q = q * (1-(X(i)-Position(i))/(subspace(i,2)-Position(i)));
    elseif X(i) < Position(i)
        q = q * (1-(Position(i)-X(i))/(Position(i)-subspace(i,1)));
    end
end
dx_X = (1 - q) * sqrt(sum((subspace(:,2) - subspace(:,1)).^2));
if(dx_X <= r)
    Y = Height*cos(pi * dx_X/r);
elseif(dx_X > r)
    Y = -Height - dx_X + r;
end
end

function Y = s8(X,Height,Position,subspace,r,m,n)
% dx_X = sqrt(sum((X-repmat(Position,size(X,1),1)).^2));
q = 1;
for i = 1:size(X,2)
    if X(i) >= Position(i)
        q = q * (1-(X(i)-Position(i))/(subspace(i,2)-Position(i)));
    elseif X(i) < Position(i)
        q = q * (1-(Position(i)-X(i))/(Position(i)-subspace(i,1)));
    end
end
dx_X = (1 - q) * sqrt(sum((subspace(:,2) - subspace(:,1)).^2));
if(dx_X <= r)
    Y = Height*(cos(m*pi*(dx_X - m* (m*dx_X)/r * r)/r) - n*(m*dx_X)/r) / sqrt(dx_X + 1);
elseif(dx_X > r)
    Y = Height - n * m * sqrt(r+1) - dx_X + r;
end
end