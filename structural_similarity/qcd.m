function qcd = qcd(quant)
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
% Author:
%   Davi Lazzarotto (davi.nachtigalllazzarotto@epfl.ch)
%
%   Function than computes the quartile coefficient of dispersion (QCD).
%   INPUTS
%       quant: Array containing the variable for the computation of the QCD             
%
%   OUTPUTS
%       qcd: Computed QCD value.

    qq = quantile(quant, [.25 .75]);
    qcd = (qq(2) - qq(1)) ./ (qq(2) + qq(1));

end