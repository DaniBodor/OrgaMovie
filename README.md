# OrgaMovie Macro Information

This FiJi/ImageJ macro takes any number 4D (xyzt) \*.nd2 image files of organoids and creates color-coded (for depth) time-lapse movies.
The macro will not run on recent versions of ImageJ. The most recent version of ImageJ that this has been stably tested on is 1.49b. Also, the macro currently only works from the workstation (DED-KOPS-001) in the Hubrecht Lab (2nd floor student room). If either of these is limiting for you, please talk to me to figure out a solution.

The code is a fully automated adaptation of a macro poreviously created by Bas Ponsioen and  René M Overmeer (?), first published in _[Targeting mutant RAS in patient-derived colorectal cancer organoids by combinatorial drug screening](https://elifesciences.org/articles/18489)_, eLife 2016;5:e18489 doi: 10.7554/eLife.18489.

# Running the OrgaMovie Macro on the Workstation (DED-KOPS-001)

1) Start FiJi
2) Start OrgaMovie code by hitting F11, or go to _plugins > OrgaMovies > OrgaMovie_Start_
3) Input your favorite settings (see below)
4) Choose input folder where your raw data (\*.nd2 files) are located. Please work from local or external hard disks and NOT from the server. 
5) Wait overnight (rough time estimate: ~14h for 33 movies totalling ~200 GB)
6) Collect your output data from _D:\ANALYSIS DUMP\Final_Movies_
7) Check that your movies are ok and then delete them from the D-drive


# Macro Settings
<img src="https://user-images.githubusercontent.com/14219087/114019216-69930780-986e-11eb-8d59-3a0dcba45a97.PNG" width="351" height="465">

#### Data Input Settings
- Filetype: currently the only option is '.nd2'.
- Time interval: set the interval (in minutes) between consecutive frames.
- Experiment name: Used for output file naming. Default is current date in yymmdd format.
#### Automation Settings
These settings can all be turned on or off.
- Drift correction - Uses _MultiStackReg_ plugin (default in FiJi) to correct drift and shaking of organoid.
- Auto-cropping: Detects portion of frame (XY) that is visited by the organoid in any Z or T and crops around tshis. If multiple organoid regions are found, cropping occurs around the largest organoid only. If unchecked, the entire frame is used, which will lead to (unnecessarily) large file sizes. See default automation settings for more details.
- Auto-contrasting: Automatically detects a good set of intensity values to use for contrasting (green and blue in original manual version of the macro). The lowest pixel value is based on a threshold that excludes most organoid pixels. The highest pixel value is a fraction of the brightest pixel in any Z or T frame. See default automation settings for more details. If unchecked, dimmest and brightest pixel values are used, which tends to not give great contrast but no pixels are lost to the background or overexposed. 
- Last timepoint detection: Finds the last timepoint where an organoid is still visible within the frame. This is based on the coefficient of variation (mean/stdev) of all pixel values in the frame. If unchecked, then all frames of the movie are included in the output, which will lead to (unnecessarily) large file sizes. See default automation settings for more details.
- Change default settings: If this is checked, another dialog will be opened after this to set default automation settings. See below for more details.
#### Movie Output Settings
- Output format: Choose whether output videos should be in between \*.avi or \*.tif or both. Tifs are easier to use for downstream analysis in ImageJ but require significantly more diskspace.
- Duration: The frame-rate of the output movie. Set how many seconds each frame stays in view when playing the movie.
- Gamma factor: applies a [Gamma correction](https://en.wikipedia.org/wiki/Gamma_correction) on the output images. It is unclear to me what exactly this setting does, but the original macro stated "brings low and high intensities together".







