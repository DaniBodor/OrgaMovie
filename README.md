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
  DATA INPUT SETTINGS
  Filetype - currently the only option is '.nd2'
  Time interval - set the interval (in minutes) between consecutive frames
  Experiment name - Anything here will form the first part of your final output movie filenames






