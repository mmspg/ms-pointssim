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
%   This is an example script that runs the MS-PointSSIM metric on all
%   distorted point clouds located at a given directory. The following
%   variables can be modified as parameters:
%       INPUT_REF_DIR - Folder containing reference point clouds in ply
%           format.
%       INPUT_DIST_DIR - Folder containing distorted point clouds in ply
%           format.
%       REF_NAME_SEPARATOR, DIST_NAME_SEPARATOR - Character separating the
%           name of the source point cloud from the rest of the filename. 
%           The name of a reference point cloud should be the same as the 
%           distorted point cloud (for example, 'longdress_vox10.ply' and
%           'longdress_GPCC_L_vox10.ply' share the same name 'longdress' if 
%           these parameters are set to '_'). 
%       OUTPUT_DIR - Folder where a csv file with metrics values is saved.
%       OUTPUT_FILE - Name of csv file with metric values.       

clear all

%% Modifiable input variables
INPUT_REF_DIR = fullfile("input_pcs", "ref");
INPUT_DIST_DIR = fullfile("input_pcs", "dist");

REF_NAME_SEPARATOR = '_';
DIST_NAME_SEPARATOR = '_';

OUTPUT_DIR = "output";
OUTPUT_FILE = "metrics.csv";

%% Creating arrays for saving names and pointCloud objects
ref_point_cloud_names = [];
ref_point_cloud_objects = [];

%% Read all reference point clouds
input_ref_dir_content = dir(INPUT_REF_DIR);
for i = 1:length(input_ref_dir_content)
    filename = input_ref_dir_content(i).name;
    if contains(filename, '.ply')
        point_cloud_name_split = split(filename, REF_NAME_SEPARATOR);
        ref_point_cloud_names = [ref_point_cloud_names, string(point_cloud_name_split{1})];
        ref_point_cloud_objects = [ref_point_cloud_objects, pcread(fullfile(INPUT_REF_DIR, filename))];
    end
end

%% Creating arrays for saving names and pointCloud objects

dist_point_cloud_names = [];
dist_point_cloud_filenames = [];
dist_point_cloud_objects = [];

%% Read all distorted point clouds
input_dist_dir_content = dir(INPUT_DIST_DIR);
for i = 1:length(input_dist_dir_content)
    filename = input_dist_dir_content(i).name;
    if contains(filename, '.ply')
        point_cloud_name_split = split(filename, DIST_NAME_SEPARATOR);
        dist_point_cloud_names = [dist_point_cloud_names, string(point_cloud_name_split{1})];
        dist_point_cloud_filenames = [dist_point_cloud_filenames, string(filename)];
        dist_point_cloud_objects = [dist_point_cloud_objects, pcread(fullfile(INPUT_DIST_DIR, filename))];
    end
end

%% Creating arrays for saving names and metric values
distorted_point_clouds = [];
ms_pssim_scores = [];
singlescale_pssim_scores = [];


for i = 1:length(ref_point_cloud_names)
    %% Compute the MS-PointSSIM for each reference point cloud
    % Selects the distorted point clouds corresponding to the current reference point cloud
    current_dist_point_cloud_objects = num2cell(dist_point_cloud_objects(dist_point_cloud_names == ref_point_cloud_names(i)));
    current_dist_point_cloud_filenames = dist_point_cloud_filenames(dist_point_cloud_names == ref_point_cloud_names(i));
    
    % Computes MS-PointSSIM
    ms_pssim_output = ms_pssim(current_dist_point_cloud_objects, ref_point_cloud_objects(i));
    
    % Stores values in arrays
    distorted_point_clouds = [distorted_point_clouds, current_dist_point_cloud_filenames];
    ms_pssim_scores = [ms_pssim_scores, ms_pssim_output.scores];
    singlescale_pssim_scores = [singlescale_pssim_scores, ms_pssim_output.singlescale_scores];

    %% Arrange arrays with metric values as a table
    bit_depths = ms_pssim_output.MS_PSSIM_PARAMS.BIT_DEPTHS;
    T = table(distorted_point_clouds', ms_pssim_scores', singlescale_pssim_scores');
    T = splitvars(T);
    T.Properties.VariableNames = ["Filename", "MS-PointSSIM", string("vox" + bit_depths + " score")];
    
    
    %% Save table in disk as csv file
    if ~isfolder(OUTPUT_DIR)
        mkdir(OUTPUT_DIR)
    end
    writetable(T, fullfile(OUTPUT_DIR, OUTPUT_FILE));

end


