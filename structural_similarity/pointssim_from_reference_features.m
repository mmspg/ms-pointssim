function [pointssimSym] = pointssim_from_reference_features(sA, sB, featMapB, PARAMS)
% Copyright (C) 2023 ECOLE POLYTECHNIQUE FEDERALE DE LAUSANNE, Switzerland
%
%     Multimedia Signal Processing Group (MMSPG)
%
%     This program is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
%
%     This program is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.
%
%     You should have received a copy of the GNU General Public License
%     along with this program.  If not, see <http://www.gnu.org/licenses/>.
%
%   This file contains code adapted from the PointSSIM metric
%   (https://github.com/mmspg/pointssim), authored by Evangelos Alexiou 
%
% Author:
%   Davi Lazzarotto (davi.nachtigalllazzarotto@epfl.ch)
%
%   INPUTS
%       sA: Custom struct for point cloud A, with fields:
%           geom - Geometry (mandatory field).
%               The size is Nx3, with N the number of points of A.
%           color - RGB color (optional field).
%               The size is Nx3.
%       sB: Custom struct for point cloud B, with fields:
%           geom - Geometry (mandatory field).
%               The size is Mx3, with M the number of points of B.
%           color - RGB color (optional field).
%               The size is Mx3.
%       featMapB: Feature map of point cloud B.
%       PARAMS: Custom struct of parameters for the computation of 
%           structural similarity scores, with the following fields:
%           ESTIMATOR_TYPE - Defines the estimator(s) that will be used to
%               compute statistical dispersion, with available options:
%               'STD', 'VAR', 'MeanAD', 'MedianAD', 'COV', 'QCD', 'Mean'.
%           POOLING_TYPE - Defines the pooling method(s) that will be used
%               to compute a total quality score, with available options:
%               'Mean', 'MSE', 'RMSE'.
%           NEIGHBORHOOD_TYPE - Defines the method used to form the
%               neighborhoods, with two possible options: 'Range', 'Knn'      
%           NEIGHBORHOOD_SIZE - Defines the size of the neighborhoods. If 
%               NEIGHBORHOOD_TYPE is set to 'Range', then this parameter
%               determines the value of the range. If NEIGHBORHOOD_TYPE is 
%               set to 'Knn', then the value of this parameter determines 
%               the 'K' amount of neighbors per neighborhood.               
%
%   OUTPUTS
%       pointssimSym: Symmetric structural similarity score


if nargin < 2
    error('Too few input arguments.');
else

    if ~isfield(sA,'geom') || ~isfield(sB,'geom')
        error('No coordinates found in input point cloud(s).');
    end
    
    if ~isfield(sA,'color') || ~isfield(sB,'color')
        error('No color found in input point cloud(s).');
    end
end


%% Conversion to double
A = structfun(@double, sA, 'UniformOutput', false);
B = structfun(@double, sB, 'UniformOutput', false);


%% Sort geometry and corresponding attributes
[A.geom, idgA] = sortrows(A.geom);
[B.geom, idgB] = sortrows(B.geom);

A.color = A.color(idgA, :);
B.color = B.color(idgB, :);

%% Formulation of neighborhoods in point cloud A
if strcmp(PARAMS.NEIGHBORHOOD_TYPE, 'Knn')
    [idA, ~] = knnsearch(A.geom, A.geom, 'K', PARAMS.NEIGHBORHOOD_SIZE);
elseif strcmp(PARAMS.NEIGHBORHOOD_TYPE, 'Range')
    [idA, ~] = rangesearch(A.geom, A.geom, PARAMS.NEIGHBORHOOD_SIZE);
end


%% Association of neighborhoods between point clouds A and B
% Loop over B and find nearest neighbor in A (set A as the reference)
[idBA, ~] = knnsearch(A.geom, B.geom);
% Loop over A and find nearest neighbor in B (set B as the reference)
[idAB, ~] = knnsearch(B.geom, A.geom);


%% Feature map extraction
[yA, ~, ~] = rgb_to_yuv(A.color(:,1), A.color(:,2), A.color(:,3));
if iscell(idA)
    index_yA = @(x) double(yA(x)');
    colorQuantA = cellfun(index_yA, idA, 'UniformOutput', false);
else
    colorQuantA = double(yA(idA));
end
[featMapA] = feature_map(colorQuantA, PARAMS.ESTIMATOR_TYPE);

%% Structucal similarity score of B (set A as reference)
[errorMapBA] = error_map(featMapB, featMapA, idBA);     % Computation of error map
ssimMapBA = 1 - errorMapBA;                             % Similarity map as 1 - error_map
[ssimBA] = pooling(ssimMapBA, PARAMS.POOLING_TYPE);     % Pooling across similarity map to obtain a quality score

%% Structucal similarity score of A (set B as reference)
[errorMapAB] = error_map(featMapA, featMapB, idAB);     % Computation of error map
ssimMapAB = 1 - errorMapAB;                             % Similarity map as 1 - error_map
[ssimAB] = pooling(ssimMapAB, PARAMS.POOLING_TYPE);     % Pooling across similarity map to obtain a quality score

%% Symmetric structucal similarity score
pointssimSym = min(ssimBA, ssimAB);     % Maximum error, or minimum similarity


