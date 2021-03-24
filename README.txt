STEP 1) FILE OPENING SETTINGS

This step only needs to be done once per computer (or at least per FiJi setup) and will then be stored as default.
Ensure that nd2 files are read windowless as a virtual stack.
To do this:
1) Open Plugins > Bio-Formats > Bio-Formats Plugins Configuration
2) In the 'Formats' tab scroll to Nikon ND2 and make sure 'Windowless' is not checked (leave the window open)
3) Open 1 movie by dragging it into FiJi and in the 'Bio-Formats Import Options' windows make the settings as follows:
	- View stack with: Hyperstack
	- Color mode: Grayscale
	- Use virtual stack: checked
	- All other checkmarks unchecked
	- All other settings at default
4) In the 'Bio-Formats Plugins Configurations' window, now UNCHECK 'Windowless' and close the window
5) From now on all *.nd2 files should be automatically be opened with the correct settings


STEP 2) DATA STORAGE

Make sure that all raw movies are in a single folder, together with the all the relevant macros:
- MovieMaker.ijm
- autocrop.ijm
- setup_moviemaker.ijm
- finalize_moviemake.ijm
- ....?


STEP 3) RUNNING THE MACRO

Open XXXXX.ijm by dragging it into FiJi
Make sure parameter setting in the first few lines of the macro are correct
	pay special attention to the time interval
Hit 'Run' or Ctrl+R/Apple+R to start macro
Wait (usually overnight)





