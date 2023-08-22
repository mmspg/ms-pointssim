function [fMap] = feature_map(quant, ESTIMATOR_TYPE)
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
% Feature map(s) of a point cloud, based on attribute-based quantities and
%   statistical dispersion estimator(s).
%
%   [fMap] = feature_map(quant, ESTIMATOR_TYPE)
%
%   INPUTS
%       quant: Attribute-based quantities of a point cloud. The size is 
%           LxK, with L the number of points of the point cloud, and K the 
%           number of points comprising the local neighborhood.
%       ESTIMATOR_TYPE: Defines the estimator(s) that will be used to
%           compute statistical dispersion, with available options:
%           {'STD', 'VAR', 'MeanAD', 'MedianAD', 'COV', 'QCD'}.
%           **{'Mean'} has been additionally included as an extra  
%           statistic to estimate the center of the distribution.**
%           More than one option can be enabled.
%
%   OUTPUTS
%       fMap: Feature map of a point cloud, per estimator. The size is LxE,
%           with E the length of the ESTIMATOR_TYPE.



if strcmp(ESTIMATOR_TYPE, 'STD')
    if iscell(quant)
        fMap = cellfun(@std,quant);
    else
        fMap = std(quant,[],2);
    end
elseif strcmp(ESTIMATOR_TYPE, 'VAR')
    if iscell(quant)
        fMap = cellfun(@var,quant);
    else
        fMap = var(quant,[],2);
    end
elseif strcmp(ESTIMATOR_TYPE, 'MeanAD')
    if iscell(quant)
        meanAD = @(x) mean(abs(x - mean(x)));
        fMap = cellfun(meanAD,quant);
    else
        fMap = mean(abs(quant - mean(quant,2)),2);
    end
elseif strcmp(ESTIMATOR_TYPE, 'MedianAD')
    if iscell(quant)
        medianAD = @(x) median(abs(x - median(x)));
        fMap = cellfun(medianAD,quant);
    else
        fMap = median(abs(quant - median(quant,2)), 2);
    end
elseif strcmp(ESTIMATOR_TYPE, 'COV')
    if iscell(quant)
        coeff_of_variation = @(x) std(x)/mean(x);
        fMap = cellfun(coeff_of_variation,quant);
    else
        fMap = std(quant,[],2)./mean(quant,2);
    end
elseif strcmp(ESTIMATOR_TYPE, 'QCD')   
    if iscell(quant)
        fMap = cellfun(@qcd,quant);
    else
        qq = quantile(quant, [.25 .75], 2);
        fMap = (qq(:,2) - qq(:,1)) ./ (qq(:,2) + qq(:,1));
    end
elseif strcmp(ESTIMATOR_TYPE, 'Mean')
    if iscell(quant)
        fMap = cellfun(@mean,quant);
    else
        fMap = mean(quant,2);
    end
else
    error('Wrong input.');
end

end
