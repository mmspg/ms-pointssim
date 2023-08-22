function ms_pssim = ms_pssim(distorted_pcs, reference_pc, MS_PSSIM_PARAMS)
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
%       distorted_pcs: Either a pointCloud object with fields Location 
%           and Color or a cell array containing pointCloud objects. In the
%           latter case, the MS-PointSSIM score is computed for multiple
%           distorted point clouds with respect to the same reference
%           indicated by reference_pc. 
%       reference_pc: pointCloud object with fields Location and Color.
%       MS_PSSIM_PARAMS: Custom struct of parameters for the computation of 
%           MS-PointSSIM scores, with the following fields:
%           BIT_DEPTHS - Cell array containing the voxelization bit depths 
%               used for the computation of the metric.
%           WEIGHTS - Cell array containing the weights assigned to the
%               singlescale scores for each bit depth. Must have the same
%               length as BIT_DEPTHS.
%           NEIGHBORHOOD_TYPES - Either a cell array or a string defining
%               the method used to formulate the neighborhoods. If it is a 
%               cell array, each element may define a different method for
%               each scale. If it is a string, then the same method is
%               used across all scales. The available methods are: 'Range',
%               'Knn'.
%           NEIGHBORHOOD_SIZES - Either a cell array or a numeric value 
%               defining the size of the neighborhoods. If it is a cell 
%               array, each element may define a different size for each 
%               scale. If it is a numeric value, then the same size is is
%               used across all scales. If the NEIGHBORHOOD_TYPE for the
%               corresponding scale is set to 'Range', then this parameter
%               determines the value of the range. If NEIGHBORHOOD_TYPE is 
%               set to 'Knn', then this parameter determines the 'K' amount
%               of neighbors per neighborhood.
%           ESTIMATOR_TYPES - Either a cell array or a string defining the
%               the estimators used to compute statistical dispersion. If
%               it is a cell array, each element may define a different 
%               estimator for each scale. If it is a string, then the same
%               estimator is is used across all scales. The available
%               estimators are: 'STD', 'VAR', 'MeanAD', 
%               'MedianAD', 'COV', 'QCD', 'Mean'.
%           POOLING_TYPES - Either a cell array or a string defining the
%               the pooling methods used to compute a total quality score. 
%               If it is a cell array, each element may define a different 
%               pooling type for each scale. If it is a string, then the 
%               same pooling type is is used across all scales. The
%               available options are:'Mean', 'MSE', 'RMSE'.
%
%   OUTPUTS
%       ms_pssim: Custom struct of output values, with the following
%       fields:
%           scores: Array containing the MS-PointSSIM scores for each
%               pointCloud object in distorted_pcs.
%           singlescale_scores: Array contining the singlescale PointSSIM
%               scores for each pointCloud object in distorted_pcs and for each
%               voxelization scale defined in MS_PSSIM_PARAMS.BIT_DEPTHS.

    if nargin < 2
        error('Too few input arguments.');
    elseif nargin == 2
        %% MS-PointSSIM configurations
        MS_PSSIM_PARAMS.BIT_DEPTHS = {6, 8, 9, 10};
        MS_PSSIM_PARAMS.WEIGHTS = {0.789, 0.053, 0.070, 0.088};
        MS_PSSIM_PARAMS.NEIGHBORHOOD_TYPES = 'Range';
        MS_PSSIM_PARAMS.NEIGHBORHOOD_SIZES = 1;
        MS_PSSIM_PARAMS.ESTIMATOR_TYPES = 'MedianAD';
        MS_PSSIM_PARAMS.POOLING_TYPES = 'Mean';
    end

    if ~isa(reference_pc, 'pointCloud')
        error('reference_pc is not of type pointCloud')
    end

    if ~iscell(distorted_pcs) && ~isa(distorted_pcs, 'pointCloud')
        error('distorted_pcs is not of type pointCloud nor cell')
    elseif ~iscell(distorted_pcs)
        distorted_pcs = {distorted_pcs};
    end

    % Intialize array for PointSSIM scores
    pssim_scores = zeros(length(MS_PSSIM_PARAMS.BIT_DEPTHS), length(distorted_pcs));

    for i = 1:length(MS_PSSIM_PARAMS.BIT_DEPTHS)

        bit_depth = MS_PSSIM_PARAMS.BIT_DEPTHS{i};

        %% Assign values for PointSSIM configuration parameters
        if iscell(MS_PSSIM_PARAMS.NEIGHBORHOOD_TYPES)
            PSSIM_PARAMS.NEIGHBORHOOD_TYPE = MS_PSSIM_PARAMS.NEIGHBORHOOD_TYPES{i};
        else
            PSSIM_PARAMS.NEIGHBORHOOD_TYPE = MS_PSSIM_PARAMS.NEIGHBORHOOD_TYPES;
        end
        
        if iscell(MS_PSSIM_PARAMS.NEIGHBORHOOD_SIZES)
            PSSIM_PARAMS.NEIGHBORHOOD_SIZE = MS_PSSIM_PARAMS.NEIGHBORHOOD_SIZES{i};
        else
            PSSIM_PARAMS.NEIGHBORHOOD_SIZE = MS_PSSIM_PARAMS.NEIGHBORHOOD_SIZES;
        end

        if iscell(MS_PSSIM_PARAMS.ESTIMATOR_TYPES)
            PSSIM_PARAMS.ESTIMATOR_TYPE = MS_PSSIM_PARAMS.ESTIMATOR_TYPES{i};
        else
            PSSIM_PARAMS.ESTIMATOR_TYPE = MS_PSSIM_PARAMS.ESTIMATOR_TYPES;
        end

        if iscell(MS_PSSIM_PARAMS.POOLING_TYPES)
            PSSIM_PARAMS.POOLING_TYPE = MS_PSSIM_PARAMS.POOLING_TYPES{i};
        else
            PSSIM_PARAMS.POOLING_TYPE = MS_PSSIM_PARAMS.POOLING_TYPES;
        end

        %% Point fusion
        reference_pc = pc_fuse_points(reference_pc);

        %% Sort geometry
        [original_geom, original_id] = sortrows(reference_pc.Location);
        original_color = reference_pc.Color(original_id, :);
        reference_pc = pointCloud(original_geom, 'Color', original_color);
        
        %% Voxelize reference point cloud
        reference_vox_pc = pc_vox_scale(reference_pc, [], bit_depth);

        %% Set custom struct with required fields for reference point cloud
        sB.geom = reference_vox_pc.Location;
        sB.color = reference_vox_pc.Color;

        %% Conversion to double
        B = structfun(@double, sB, 'UniformOutput', false);
               
        %% Formulation of neighborhoods in reference point cloud 
        if strcmp(PSSIM_PARAMS.NEIGHBORHOOD_TYPE, 'Knn')
            [idB, ~] = knnsearch(B.geom, B.geom, 'K', PSSIM_PARAMS.NEIGHBORHOOD_SIZE);
        elseif strcmp(PSSIM_PARAMS.NEIGHBORHOOD_TYPE, 'Range')
            [idB, ~] = rangesearch(B.geom, B.geom, PSSIM_PARAMS.NEIGHBORHOOD_SIZE);
        end

        %% Feature map extraction
        [yB, ~, ~] = rgb_to_yuv(B.color(:,1), B.color(:,2), B.color(:,3));
        if iscell(idB)
            index_yB = @(x) double(yB(x)');
            colorQuantB = cellfun(index_yB, idB, 'UniformOutput', false);
        else
            colorQuantB = double(yB(idB));
        end
        [featMapB] = feature_map(colorQuantB, PSSIM_PARAMS.ESTIMATOR_TYPE);

        %% Loop through distorted point clouds
        for j = 1:length(distorted_pcs)

            distorted_pc = distorted_pcs{j};

            %% Point fusion
            distorted_pc = pc_fuse_points(distorted_pc);

            %% Sort geometry
            [distorted_geom, distorted_id] = sortrows(distorted_pc.Location);
            distorted_color = distorted_pc.Color(distorted_id, :);
            distorted_pc = pointCloud(distorted_geom, 'Color', distorted_color);

            %% Voxelize distorted point cloud
            distorted_vox_pc = pc_vox_scale(distorted_pc, [], bit_depth);

            %% Set custom structs with required fields for distorted point cloud
            sA.geom = distorted_vox_pc.Location;            
            sA.color = distorted_vox_pc.Color;
            
            %% Computes singlescale PointSSIM score
            [pointssimSym] = pointssim_from_reference_features(sA, sB, featMapB, PSSIM_PARAMS);
            pssim_scores(i, j) = pointssimSym;

        end
    end

    %% Computes multiscale PointSSIM scores
    ms_pssim_scores = cell2mat(MS_PSSIM_PARAMS.WEIGHTS) * pssim_scores;

    ms_pssim.scores = ms_pssim_scores;
    ms_pssim.singlescale_scores = pssim_scores;
    ms_pssim.MS_PSSIM_PARAMS = MS_PSSIM_PARAMS;

end