# MS-PointSSIM: Multiscale Point Cloud Structural Similarity Metric

This repository contains the code for MS-PointSSIM [1]. The value for the multi scale point cloud structural similarity is computed by voxelizing both the original and the distorted point clouds at multiple bit depths, computing the PointSSIM [2] metric for each voxelized instance, and combining the obtained values through linear combination. The weights assigned to each scale in the default configuration were obtained using logistic fitting, as described in [1]. 

The MS-PointSSIM can be run through the MATLAB function `ms_pssim(distorted_pcs, reference_pc, MS_PSSIM_PARAMS)` which takes as input either one or many distorted point clouds, its corresponding reference point cloud, as well as the metric parameters. A detailed description of the input arguments can be found in the file `ms_pssim.m`. A simple MATLAB script that computes the MS-PointSSIM between two point clouds with default parameters can be found below:

```
    reference_pc = pcread(<PATH_TO_REFERENCE_POINT_CLOUD>)
    distorted_pc = pcread(<PATH_TO_DISTORTED_POINT_CLOUD>)
    ms_pssim(distorted_pc, reference_pc)
```

The pre-built script `run_example.m` can be used to compute the MS-PointSSIM over an entire dataset. The distorted point clouds should be placed in the folder `input_pcs/dist` and the reference point clouds in `input_pcs/ref`. The name of each reference point cloud and its corresponding distorted point cloud should be the same, and should appear at the beginning of each filename separated from the remainder by the character '_'. For instance, if the reference point cloud file is named 'longdress_vox10.ply' and the distorted point cloud file is named 'longdress_vox10_GPCC_r01.ply', the MS-PointSSIM will be computed between them. Both the multiscale and singlescale scores are saved in the csv file located at `output/metrics.csv`. Alternatively, the input and output folders, and character separators can be easily adapted at the beginning of the `run_example.m` script. 

## Conditions of use

This repository contains code adapted from the PointSSIM metric (https://github.com/mmspg/pointssim). 

Permission is hereby granted, without written agreement and without license or royalty fees, to use, copy, modify, and distribute the data provided and its documentation for research purpose only. The data provided may not be commercially distributed. In no event shall the Ecole Polytechnique Fédérale de Lausanne (EPFL) be liable to any party for direct, indirect, special, incidental, or consequential damages arising out of the use of the data and its documentation. The Ecole Polytechnique Fédérale de Lausanne (EPFL) specifically disclaims any warranties. The data provided hereunder is on an “as is” basis and the Ecole Polytechnique Fédérale de Lausanne (EPFL) has no obligation to provide maintenance, support, updates, enhancements, or modifications.

If you wish to use any of the provided scripts in your research, we kindly ask you to cite [1].

## References 

[1] D. Lazzarotto and T. Ebrahimi, "Towards a Multiscale Point Cloud Structural Similarity Metric," 2023 IEEE International Workshop on Multimedia Signal Processing (MMSP), Poitiers, France, 2023.

[2] E. Alexiou and T. Ebrahimi, "Towards a Point Cloud Structural Similarity Metric," 2020 IEEE International Conference on Multimedia & Expo Workshops (ICMEW), London, United Kingdom, 2020, pp. 1-6. doi: 10.1109/ICMEW46912.2020.9106005