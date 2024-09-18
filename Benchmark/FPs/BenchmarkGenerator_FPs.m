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
function Problem = BenchmarkGenerator_FPs(PeakNumber,ChangeFrequency,Dimension,ShiftSeverity,EnvironmentNumber,BenchmarkName)
   disp('FPs Running')
   Problem                     = [];
   Problem.FE                  = 0;
   Problem.PeakNumber          = PeakNumber;
   Problem.ChangeFrequency     = ChangeFrequency;
   Problem.Dimension           = Dimension;
   Problem.ShiftSeverity       = ShiftSeverity;
   Problem.EnvironmentNumber   = EnvironmentNumber;
   Problem.Environmentcounter  = 1;
   Problem.RecentChange        = 0;
   Problem.MaxEvals            = Problem.ChangeFrequency * Problem.EnvironmentNumber;
   Problem.Ebbc                = NaN(1,Problem.EnvironmentNumber);
   Problem.CurrentError        = NaN(1,Problem.MaxEvals);
   Problem.MinCoordinate       = -50;
   Problem.MaxCoordinate       = 50;
   Problem.l_sv                = -100;
   Problem.u_sv                = 100;
   Problem.MinHeight           = 0;
   Problem.MaxHeight           = 100;
   Problem.MinFunctionID       = 1;
   Problem.MaxFunctionID       = 8;
   Problem.HeightSeverity      = 7;
   Problem.LowestValue         = 0;
   Problem.BenchmarkName       = BenchmarkName;
   Problem.OptimumValue        = NaN(Problem.EnvironmentNumber,1);
   Problem.PeaksHeight         = NaN(Problem.EnvironmentNumber,Problem.PeakNumber);
   Problem.PeaksPosition       = NaN(Problem.PeakNumber,Problem.Dimension,Problem.EnvironmentNumber);
   Problem.PeaksPositionMap    = NaN(Problem.PeakNumber,Problem.Dimension,Problem.EnvironmentNumber);
   Problem.FunctionSelect      = NaN(Problem.EnvironmentNumber,Problem.PeakNumber);
   Problem.PeaksHeight(1,:)    = Problem.MinHeight + (Problem.MaxHeight-Problem.MinHeight)*rand(Problem.PeakNumber,1);
   Problem.OptimumValue(1)     = max(Problem.PeaksHeight(1,:));
   Problem.SubSpace            = NaN(Dimension,2,PeakNumber,EnvironmentNumber);
   Problem.SubSpaceLowest      = NaN(Problem.EnvironmentNumber,PeakNumber);
   Problem.SubSpaceLinkage     = NaN(PeakNumber,PeakNumber);
   Problem.PeakVisibility      = ones(Problem.EnvironmentNumber,Problem.PeakNumber);
   Problem.FunctionSelect(1,:) = ceil(Problem.MinFunctionID-1 + (Problem.MaxFunctionID-Problem.MinFunctionID+1)*rand(Problem.PeakNumber,1));
   %************************************The parameters can be configured by users************************************
   Problem.Lambda              = 1;    %To determine the correlation between the direction of the current movement and the previous movement
                                       %Set 0 to random move, set 1 to fixed direction move
   Problem.SpaceChange         = 0;    %Set 1 to change subspace every environment.
   Problem.FunctionChange      = 1;    %Set 1 to change subspaces' functions every environment.
   %*****************************************************************************************************************
   
   [SubSpace, SubSpaceLinkage] = KDTree_Partition(PeakNumber,repmat([Problem.MinCoordinate,Problem.MaxCoordinate],Dimension,1));
   for i = 1:PeakNumber
       Problem.SubSpace(:,:,i,1) = zeros(Dimension,2);
   end
   for i = 1:size(SubSpace,1)
       if(rem(i,Dimension) > 0) 
           dim = rem(i,Dimension);
       elseif (rem(i,Dimension) == 0) 
           dim = Dimension;
       end
       Problem.SubSpace(dim,:,ceil(i/Dimension)) = SubSpace(i,:);
   end
   Problem.SubSpaceLinkage = SubSpaceLinkage;
   
   %Set Peak Position in each subspace
   for i = 1:Problem.PeakNumber
       for j = 1:Problem.Dimension
           Problem.PeaksPosition(i,j,1) = Problem.SubSpace(j,1,i,1) + (Problem.SubSpace(j,2,i,1)-Problem.SubSpace(j,1,i,1)) * rand(1,1);
       end
   end
   [Problem.OptimumValue(1), Problem.OptimumID(1)] = max(Problem.PeaksHeight(1,:));
   Problem.PeaksPositionMap(:,:,1) = Transfer(Problem.PeaksPosition(:,:,1),Problem,1);
   
   %Get Subspace Lowest Value for Flat Border.
   bounder = zeros(PeakNumber,Dimension);
   for i = 1:PeakNumber
       for j = 1:Dimension
        bounder(i,j) = Problem.SubSpace(j,1,i,1);
       end
   end
   Problem.SubSpaceLowest(1,:) = EnvironmentVisualization(bounder,Problem);
   
   %Generating all environments
   for ii=2 : Problem.EnvironmentNumber
       %Re-Set SubSpace
       if(Problem.SpaceChange == 1)
           [SubSpace, SubSpaceLinkage] = KDTree_Partition(PeakNumber,repmat([Problem.MinCoordinate,Problem.MaxCoordinate],Dimension,1));
           for i = 1:PeakNumber
               Problem.SubSpace(:,:,i,ii) = zeros(Dimension,2);
           end
           for i = 1:size(SubSpace,1)
               if(rem(i,Dimension) > 0) 
                   dim = rem(i,Dimension);
               elseif (rem(i,Dimension) == 0) 
                   dim = Dimension;
               end
               Problem.SubSpace(dim,:,ceil(i/Dimension),ii) = SubSpace(i,:);
           end
           Problem.SubSpaceLinkage = SubSpaceLinkage;
           %Re-Set Position
           for i = 1:Problem.PeakNumber
               for j = 1:Problem.Dimension
                   Problem.PeaksPosition(i,j,ii) = Problem.SubSpace(j,1,i,ii) + (Problem.SubSpace(j,2,i,ii)-Problem.SubSpace(j,1,i,ii)) * rand(1,1);
               end
           end
           %Re-set Height
           Problem.PeaksHeight(ii,:) = Problem.MinHeight + (Problem.MaxHeight-Problem.MinHeight)*rand(Problem.PeakNumber,1);
           %Re-Set Function
           Problem.FunctionSelect(ii,:) = ceil(Problem.MinFunctionID-1 + (Problem.MaxFunctionID-Problem.MinFunctionID+1)*rand(Problem.PeakNumber,1));
       elseif(Problem.SpaceChange == 0)
           Problem.SubSpace(:,:,:,ii) = Problem.SubSpace(:,:,:,ii-1);
           %Position Change
           v =  (-1) + (1 - (-1))*rand(PeakNumber,Dimension);
           v_normed = zeros(PeakNumber,Dimension);
           for l = 1:PeakNumber
               v_normed(l,:) = v(l,:)./norm(v(l,:));
           end
           if(ii - 2 > 0)
               Problem.PeaksPosition(:,:,ii) = Problem.PeaksPosition(:,:,ii-1) + (Problem.PeaksPosition(:,:,ii-1) - Problem.PeaksPosition(:,:,ii-2))*Problem.Lambda + v_normed * (1-Problem.Lambda) * (Problem.ShiftSeverity * randn());
           elseif(ii -2 <= 0)
               Problem.PeaksPosition(:,:,ii) = Problem.PeaksPosition(:,:,ii-1) + v_normed * (Problem.ShiftSeverity * randn());            
           end
           
           for kk = 1:Problem.PeakNumber
               for gg = 1:Problem.Dimension
                   if(Problem.PeaksPosition(kk,gg,ii) > Problem.SubSpace(gg,2,kk,ii))
                       Problem.PeaksPosition(kk,gg,ii) = Problem.SubSpace(gg,1,kk,ii) + ((Problem.SubSpace(gg,2,kk,ii) - Problem.SubSpace(gg,1,kk,ii)).^2)/(Problem.PeaksPosition(kk,gg,ii) - Problem.SubSpace(gg,1,kk,ii));
                   elseif(Problem.PeaksPosition(kk,gg,ii) < Problem.SubSpace(gg,1,kk,ii))
                       Problem.PeaksPosition(kk,gg,ii) = Problem.SubSpace(gg,1,kk,ii) + (Problem.SubSpace(gg,2,kk,ii) - Problem.SubSpace(gg,1,kk,ii)) * (Problem.SubSpace(gg,1,kk,ii) - Problem.PeaksPosition(kk,gg,ii))/(Problem.SubSpace(gg,2,kk,ii) - Problem.PeaksPosition(kk,gg,ii));
                   end
               end
           end
           %Height Change
           for kk = 1:Problem.PeakNumber
               Problem.PeaksHeight(ii,kk) =  Problem.PeaksHeight(ii - 1,kk) + Problem.HeightSeverity*randn();
               while(Problem.PeaksHeight(ii,kk) < Problem.MinHeight)
                  Problem.PeaksHeight(ii,kk) = Problem.PeaksHeight(ii,kk) + abs(Problem.HeightSeverity*randn());
               end
               while(Problem.PeaksHeight(ii,kk) > Problem.MaxHeight)
                  Problem.PeaksHeight(ii,kk) = Problem.PeaksHeight(ii,kk) - abs(Problem.HeightSeverity*randn());
               end
           end
           %Function Change
           if(Problem.FunctionChange == 0)
               Problem.FunctionSelect(ii,:) = Problem.FunctionSelect(ii-1,:);
           elseif(Problem.FunctionChange == 1)
               Problem.FunctionSelect(ii,:) = ceil(Problem.MinFunctionID-1 + (Problem.MaxFunctionID-Problem.MinFunctionID+1)*rand(Problem.PeakNumber,1));
           end
       end
       Problem.PeaksPositionMap(:,:,ii) = Transfer(Problem.PeaksPosition(:,:,ii),Problem,ii);
       
       %Get Subspace Lowest Value for Flat Border.
       bounder = zeros(PeakNumber,Dimension);
       for i = 1:PeakNumber
           for j = 1:Dimension
                   bounder(i,j) = Problem.SubSpace(j,1,i,ii);
           end
       end
       Problem.Environmentcounter = ii;
       Problem.SubSpaceLowest(ii,:) = EnvironmentVisualization(bounder,Problem);
       [Problem.OptimumValue(ii), Problem.OptimumID(ii)] = max(Problem.PeaksHeight(ii,:));
   end
   Problem.Environmentcounter = 1;
end
%% FPs Function
%X->real location, Map_X->map location, k->the id of subspace
function [Map_X,X_SubSpaceID] = Transfer(X,Problem,EnvironmentNum)
Map_X = zeros(size(X,1),Problem.Dimension);
X_SubSpaceID = zeros(size(X,1),1);
Sv_l = -100;
Sv_u = 100;
for i = 1:size(X,1)
    for j = 1:Problem.PeakNumber
        for k = 1:Problem.Dimension
            if(X(i,k) >= Problem.SubSpace(k,1,j,EnvironmentNum) && X(i,k) < Problem.SubSpace(k,2,j,EnvironmentNum))
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