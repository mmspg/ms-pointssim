function [score] = pooling(qMap, POOLING_TYPE)
% Copyright (C) 2020 ECOLE POLYTECHNIQUE FEDERALE DE LAUSANNE, Switzerland
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
%
% Author:
%   Evangelos Alexiou (evangelos.alexiou@epfl.ch)
%
% Reference:
%   E. Alexiou and T. Ebrahimi, "Towards a Point Cloud Structural
%   Similarity Metric," 2020 IEEE International Conference on Multimedia &
%   Expo Workshops (ICMEW), London, United Kingdom, 2020, pp. 1-6.
%
%
% Application of pooling method(s) over a quality map of a point cloud, to
%   compute quality score(s). A quality map contains similarity (or error) 
%   values, each corresponding to one point of a point cloud.
%
%   [score] = pooling(qMap, POOLING_TYPE)
%
%   INPUTS
%       qMap: Quality map of a point cloud. The size is Lx1, with L the
%           number of similarity (or error) values (equal to the number of 
%           points in the point cloud).
%       POOLING_TYPE: Defines the pooling method(s) that will be used to
%           compute a total quality score, with available options:
%           {'Mean', 'MSE', 'RMSE'}.
%           More than one option can be enabled.
%
%   OUTPUTS
%       score: Quality score of a point cloud, per pooling method. The size
%            is 1xP, with P the length of the POOLING_TYPE.

if strcmp(POOLING_TYPE, 'Mean')
    score = nanmean(qMap);

elseif strcmp(POOLING_TYPE, 'MSE')
    score = nanmean(qMap.^2);

elseif strcmp(POOLING_TYPE, 'RMSE')
    score = sqrt(nanmean(qMap.^2));

else
    error('Wrong input.');
end

end
