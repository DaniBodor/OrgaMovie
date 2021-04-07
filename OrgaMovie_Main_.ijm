// !!!!!!!!!!!!!!!!!!!!!!! in settings wegschrijven definitie Ch, Slice, Frames
//As of may 2015 the new formed image (make substack..., merge channels...) is no longer automatically selected!

/// data op X (NIET lokaal gehaald)
/// nog eens fiji op D terwijl F leeg is. beter?
/// verhuis Fiji naa de F en run

//	java.lang.IllegalArgumentException: Invalid Z index: 12/12
//	java.lang.IllegalArgumentException: Invalid Z index: 23/20

// *****************************************************
// *****************************************************

// opkrikken tijdelijke min en max als multipl groot wordt

// wat is het probleem van time-projcted ????

// 1) laatste window van de virtual transmitted --> steeds geen vierkante ROI
// 2) positions 4 (1 of 2)

// label ipv for-loop voor draw-functies

// als je geen depth hebt, dat dat een loop wordt

// REMOVE !!!! DoingOtherTests EN TESTS IN FUNCTION - function TimeProjectionOnTransmitted(title,slice){

// VERBETER DE SetBrightness etc....... ook CONTRAST standaardiseren


passargument = getArgument();
if (passargument == ""){
	exit("You started the wrong macro. Please run:\n OrgaMovie Start")
}

input_arguments = split(passargument, "$");

t_step = input_arguments[0];
unused = input_arguments[1];
prefix = input_arguments[2];
do_registration = input_arguments[3];
do_autocrop = input_arguments[4];
do_autoBC = input_arguments[5];
do_autotime = input_arguments[6];
do_autoZ = input_arguments[7];
gamma_factor_import = input_arguments[8];
multiply_factor_import = input_arguments[9];
sec_p_frame = input_arguments[10];
inputfilename = input_arguments[11];
movie_index = input_arguments[12];
if (isNaN(movie_index)) {
	movie_index = movie_index; // i.e. do nothing
} else if (movie_index < 10) {
	movie_index = "0" + d2s(movie_index, 0);
} else movie_index = d2s(movie_index, 0);
run_mode = input_arguments[13]; // "queue" OR "process"
minOrgaSize = input_arguments[14];
	minOrgaSize = parseInt(minOrgaSize);
cropBoundary = input_arguments[15];
loop_number = input_arguments[16];
	loop_number = parseInt(loop_number);
BC_thresh_meth = input_arguments[17];
export_format = input_arguments[18];
	if (export_format != "*.tif only") makeAVI = true;
	if (export_format != "*.avi only") makeTIF = true;
maxBrightnessFactor = input_arguments[19];
covCutoff = input_arguments[20];
minMovieLength = input_arguments[21];

if (run_mode == "process"){
	for(i = 0; i < input_arguments.length; i++){
		if (input_arguments[i] == "Movie_index_1_follows"){
			movie_index_1 = i+1;
			i += 1000000;
		}
	}
	movie_index_list = Array.slice(input_arguments, movie_index_1, input_arguments.length);
}


export_folder = "Final_Movies";
micron = getInfo("micrometer.abbreviation");
lastframe = 0;

/*
t_step = 3;
date = "25-3-2021";
prefix = "Pos_";
do_registration = 0;
do_autocrop = 1;
do_autoBC = 1;
do_autotime = 0;
do_autoZ = 0;
gamma_factor_import = 0.7;
multiply_factor_import = 1.0;
sec_p_frame = 1.3;
inputfilename = File.openDialog("Choose LIF-file to process");
run_mode = "queue";
movie_index = "00";
minOrgaSize = 350;
cropBoundary = 75;
*/


if (run_mode == "queue"){
	print("macro initiated for movie: " + movie_index);
	print("wait for file to open");
	print(inputfilename);
} else  print("macro entered in process mode");


LimitTimepointForDebugging = 0;
TempDisk = "F"; ///////////// If the MACRO does not do all timepoints then check line 2 This is a setting to speed up testing (and I might have forgotten to reset it...)
OutputDisk = "D";

PrintLikeCrazy = 0;
PauseAfterSettings = 1;
SingleTPtoZstack = 0;
if (SingleTPtoZstack) {
	waitForUser("Sure you want SingleTPtoZstack @ 1 ????");
} //bp
GreenEnhanceContrastSaturationFactor = 0.1; //bp ---> line ~ 1000 --> run("Enhance Contrast", "saturated="+GreenEnhanceContrastSaturationFactor);
// set at 0 --> no saturated pixels
MarginForScaleBar = 4;
MinimalTextSize = 12;

GarbageEverynTimes = 4; // bp37
tiffFile = 0; // if you load an tiff file, it will be recognized
nd2File = 0; // if you load an nd2 file, it will be recognized 

TCPForOverruling = ""; //nw//

Timo = 0;
TempXtoD = 0;



//INDEX OF MACRO:
//GENERAL SETTINGS
//FIRST DIALOG (restart? transmitted? check position?)
//RESTART, CHECK LAST POSITION
//LOAD SETTINGS
//RESTART, SETTINGS 	
//RESTART, DIALOG, CHOSE POSITION
//NORMAL, SETTINGS\
//NORMAL, POSITION NUMBER
//NORMAL, POSITION NAME	
//NORMAL, TRANSMITTED CHANNEL
//NORMAL, CHANGE LUT SETTING FOR WHITE CHANNELS
//NORMAL, SAVE SETTINGS
//SET STANDARD SETTINGS (OR LOAD FROM SETTINGSFILE)
//NORMAL, DIALOG "SETTINGS"
//NORMAL, DIALOG "Chose channels for DeadDye and Nuclei"
//NORMAL, DIALOG "Extended settings"
//NORMAL, SAVE SETTINGS 2
//RESTART, GET SETTING FOR ALL POSITIONS
//NORMAL, SET ROI, ZPLANE AND B&C
//NORMAL, CHECK LAST TIMEPOINT BLACK	
//NORMAL, MAKE TEMPORARY WINDOWS FOR B&C NON-TRANSMITTED CHANNELS
//NORMAL, DELETE Z-planes, CREATE 2 WINDOWS
//NORMAL, DELETE Z-planes, GET TOP AND BOTTOM
//NORMAL, DELETE Z-planes, GET MULTIPY FACTOR FOR DEPTHCODING
//NORMAL, SAVE SETTINGS 3

//ALL, START OF ACTUAL PROCESSING OPEN POSITION
//ALL, PROCESS TRANSMITTED
//ALL, PROCESS CHANNELS
//ALL, SAV PROGRESS TO NETWORK
//ALL, MERGE TIMEPOINTS
//ALL, COMBINE THE CHANNELS AND TRANS/DEPTHCODING
//ALL, SAVE PROGRESS FILE FOR RESTART
//ALL, SAVE PROGRESS TO NETWORK
//FUNCTIONS

// wegwerken : StringPreviousRun
// dat vinkje in de restart-dialog moet nog weg

run("Close All");
run("Collect Garbage");
ImageJDirectory = getDirectory("imagej");

if (File.exists("D:\\ANALYSIS DUMP\\")) {
	OutputDisk = "D";
	TempDisk = "D";
}
if (File.exists("F:\\ANALYSIS DUMP\\")) {
	TempDisk = "F";
} // kan met length of string omdat-i achteraan staat!!!

if (File.exists(TempDisk + ":\\ANALYSIS DUMP\\Queue-info.txt")) {
	QueueString = File.openAsRawString(TempDisk + ":\\ANALYSIS DUMP\\Queue-info.txt");
	Index = indexOf(QueueString, "nQueuedExp_");
	nQueuedExp = substring(QueueString, Index + 11, lengthOf(QueueString));
	nQueuedExp = 1 * nQueuedExp;
} else {
	nQueuedExp = 0;
}


QueueFinished = 1;
if (File.exists(TempDisk + ":\\ANALYSIS DUMP\\RunAllQueue-info.txt")) {
	RunAllQueuedString = File.openAsRawString(TempDisk + ":\\ANALYSIS DUMP\\RunAllQueue-info.txt");
	Index = indexOf(RunAllQueuedString, "RunAllQueued_");
	RunAllQueuedPrevious = substring(RunAllQueuedString, Index + 13, Index + 14);
	if (RunAllQueuedPrevious) {
		Index = indexOf(RunAllQueuedString, "current_Exp_");
		ExpWhenPreviousGotStuck = substring(RunAllQueuedString, Index + 12, Index + 13);
		Index = indexOf(RunAllQueuedString, "nExp_");
		nExp = substring(RunAllQueuedString, Index + 5, Index + 6);
		Index = indexOf(RunAllQueuedString, "QueueFinished_");
		QueueFinished = substring(RunAllQueuedString, Index + 14, Index + 15);
	}
}

QueueMultiple = 0;
Q = "";
nExp = 1;
Restart = 0;
QuitQueuing = 0;
ExpForRestart = 1;
RestartMessage = "";

// dialog
if (nQueuedExp == 0) {
	Dialog.create("no queued experiments");
		Dialog.addMessage("All Queued Experiments have been run !!");
		Dialog.addCheckbox("Start adding experiment(s) to the queue ?", 1);
		Dialog.setInsets(40, 10, 0);
		Dialog.addMessage("***** BP & RO only ******");
		Dialog.addNumber("Manipulate nQueuedExp ", nQueuedExp);
		Dialog.addNumber("Manipulate QueueFinished ", QueueFinished);
	//Dialog.show();
		QueueMultiple = Dialog.getCheckbox();
		nQueuedExp = Dialog.getNumber();
		QueueFinished = Dialog.getNumber();
}
if (QueueMultiple) {
	Q = "Queued ";
	nExp = 1;
}

OptionArray = newArray("Add another experiment to the queue", "Run ALL queued experiments", "Start all over again setting experiments in queue", "Restart (the queue-run got stuck...)");
QueueFollowUp = "";
QuitQueuing = 0; // deze MOET 0 blijven	
if (nQueuedExp == 1) {
	Text = "1 Experiment Queued";
}
if (nQueuedExp > 1) {
	Text = d2s(nQueuedExp, 0) + " Experiments Queued";
}

if (QueueFinished == 0) {
	QueueFollowUp = OptionArray[3];
	QuitQueuing = 0;
	ExpForRestart = ExpWhenPreviousGotStuck;
	RestartMessage = " \n \n previous run got stuck at Exp#" + ExpWhenPreviousGotStuck + " \n \n ";
}
if (nQueuedExp > 0) {
	Dialog.create("some experiments queued");
		Dialog.setInsets(0, 10, 0);
		Dialog.addMessage(Text + RestartMessage);
		if (run_mode == "queue") Dialog.addRadioButtonGroup("What do you want to do?", OptionArray, 4, 1, OptionArray[0]);
		else if (run_mode == "process") Dialog.addRadioButtonGroup("What do you want to do?", OptionArray, 4, 1, OptionArray[1]);
		Dialog.setInsets(20, 20, 0);
		Dialog.addCheckbox("Single analysis (no queuing)", QuitQueuing);
		Dialog.setInsets(-3, 20, 0);
		Dialog.addMessage("(upon checking, queued data are perfectly safe)");
		Dialog.setInsets(40, 10, 0);
		Dialog.addMessage("***** BP & RO only ******");
		Dialog.addNumber("Manipulate nQueuedExp ", nQueuedExp);
	//Dialog.show();
		QueueFollowUp = Dialog.getRadioButton;
		QuitQueuing = Dialog.getCheckbox();
		nQueuedExp = Dialog.getNumber();
}
// in all cases evaluate this :
a = QueueMultiple;
if (QueueFollowUp == OptionArray[0]) {
	QueueMultiple = 1;
	nExp = 1;
	Q = "Queued ";
}
RunAllQueued = 0;
if (QueueFollowUp == OptionArray[1]) {
	RunAllQueued = 1;
	QueueMultiple = 1;
	nExp = nQueuedExp;
	Q = "Queued ";
	Restart = 1;
}
RestartQueuing = 0;
if (QueueFollowUp == OptionArray[2]) {
	RestartQueuing = 1;
	QueueMultiple = 1;
	nExp = 1;
	Q = "Queued ";
	nQueuedExp = 0;
}
RestartQueueRun = 0;
if (QueueFollowUp == OptionArray[3]) {
	RestartQueueRun = 1;
	QueueMultiple = 1;
	nExp = nQueuedExp;
	Q = "Queued ";
	RunAllQueued = 1;
	Restart = 1;
}
FirstRoundRestart = 1;

if (QuitQueuing) {
	QueueMultiple = 0;
	nExp = 1;
	Q = "";
	RunAllQueued = 0;
	RestartQueuing = 0;
	RestartQueueRun = 0;
}

if (RestartQueueRun) {
	Dialog.create("Do a RESTART in the queued run");
		Dialog.addMessage("Do a RESTART in the queued run" + RestartMessage);
		Dialog.addNumber("Which experiment ?", ExpForRestart);
	Dialog.show();
		ExpForRestart = Dialog.getNumber();
}
print("");
if (RunAllQueued && LimitTimepointForDebugging > 0) {
	print("");
	waitForUser("LimitTimepointForDebugging is at " + LimitTimepointForDebugging + " \n \n do you want that ???");
	print("");
} //bp37 vanwege de print's


// deze for-loop gaat over de GEHELE macro !!!
// deze for-loop gaat over de GEHELE macro !!!
// deze for-loop gaat over de GEHELE macro !!!
for (Exp = 1; Exp < nExp + 1; Exp++) {
	if (Exp == 1 && RunAllQueued) {
		QueueFinished = 0;
		RunAllQueuedString = "RunAllQueued_" + RunAllQueued + " current_Exp_" + Exp + " ; nExp_" + nExp + " ; QueueFinished_" + QueueFinished;
		File.saveString(RunAllQueuedString, TempDisk + ":\\ANALYSIS DUMP\\RunAllQueue-info.txt");
	}

	if (RunAllQueued) {
		for (v = 0; v < 20; v++) {
			print("#");
		}
		for (v = 0; v < 10; v++) {
			print("RunAllQueued ; next Exp, namely Exp #" + Exp);
		}
		for (v = 0; v < 20; v++) {
			print("#");
		}
	}
	if (RestartQueueRun && FirstRoundRestart) {
		Exp = ExpForRestart;
	}

	//GENERAL SETTINGS
	while (isOpen("Exception")) {
		selectWindow("Exception");
		run("Close");
	} //Reset things to prevent error
	setOption("ExpandableArrays", true); //Makes expandable arrays possible
	//run("Set Measurements...", "area mean limit redirect=None decimal=1"); //Set measurements to include mean gray

	// for analysis
	File.makeDirectory(TempDisk + ":\\ANALYSIS DUMP\\");
	File.makeDirectory(TempDisk + ":\\ANALYSIS DUMP\\TEMP DUMP\\");
	File.makeDirectory(TempDisk + ":\\ANALYSIS DUMP\\Settings\\");
	File.makeDirectory(TempDisk + ":\\ANALYSIS DUMP\\Settings\\Settings Archive\\");
	// deze hieronder kan toch weg?
	File.makeDirectory(TempDisk + ":\\ANALYSIS DUMP\\" + Q + "Exp" + Exp + "\\");
	File.makeDirectory(TempDisk + ":\\ANALYSIS DUMP\\" + Q + "Exp" + Exp + "\\Settings\\");
	File.makeDirectory(TempDisk + ":\\ANALYSIS DUMP\\" + Q + "Exp" + Exp + "\\RESULT\\"); //Make directories so the macro kan write away temp files and results (doesn't do anything if they alreadt exist)
	if (QueueMultiple) {
		Temp = nQueuedExp + 1;
		File.makeDirectory(TempDisk + ":\\ANALYSIS DUMP\\" + Q + "Exp" + Temp + "\\");
		File.makeDirectory(TempDisk + ":\\ANALYSIS DUMP\\" + Q + "Exp" + Temp + "\\Settings\\");
		File.makeDirectory(TempDisk + ":\\ANALYSIS DUMP\\" + Q + "Exp" + Temp + "\\RESULT\\");
	} // altijd 1 folder vooruit maken ; beetje raar maar kan geen kwaad 
	// for output
	// deze hieronder kan toch weg?
	File.makeDirectory(OutputDisk + ":\\ANALYSIS DUMP\\");
	File.makeDirectory(OutputDisk + ":\\ANALYSIS DUMP\\TEMP DUMP\\");
	File.makeDirectory(OutputDisk + ":\\ANALYSIS DUMP\\Settings\\");
	File.makeDirectory(OutputDisk + ":\\ANALYSIS DUMP\\Settings\\Settings Archive\\");
	File.makeDirectory(OutputDisk + ":\\ANALYSIS DUMP\\" + Q + "Exp" + Exp + "\\");
	File.makeDirectory(OutputDisk + ":\\ANALYSIS DUMP\\" + Q + "Exp" + Exp + "\\Settings\\");
	File.makeDirectory(OutputDisk + ":\\ANALYSIS DUMP\\" + Q + "Exp" + Exp + "\\RESULT\\"); //Make directories so the macro kan write away temp files and results (doesn't do anything if they alreadt exist)
	if (QueueMultiple) {
		Temp = nQueuedExp + 1;
		File.makeDirectory(OutputDisk + ":\\ANALYSIS DUMP\\" + Q + "Exp" + Temp + "\\");
		File.makeDirectory(OutputDisk + ":\\ANALYSIS DUMP\\" + Q + "Exp" + Temp + "\\Settings\\");
		File.makeDirectory(OutputDisk + ":\\ANALYSIS DUMP\\" + Q + "Exp" + Temp + "\\RESULT\\");
	} // altijd 1 folder vooruit maken ; beetje raar maar kan geen kwaad 
	
	// DB output image to better place
	image_output_location = OutputDisk + ":\\ANALYSIS DUMP\\" + export_folder + File.separator;
	File.makeDirectory(image_output_location);

	ChannelColourOriginal = newArray("White", "Green", "Red", "Blue", "Cyan", "Magenta", "Yellow");
	ChannelColour = newArray("None", "Green", "Red", "Blue", "Cyan", "Magenta", "Yellow");
	AspectArray = newArray("no", "square", "4:3", "16:9");
	ScreenWidth = screenWidth();
	ScreenHeight = screenHeight();
	FitWidthFactor = 0.8;
	FitHeightFactor = 0.8; //RO 2204
	FitWidth = FitWidthFactor * screenWidth; //RO 2204						
	FitHeight = FitHeightFactor * screenHeight; //RO 2204
	WindowSeparateMarginX = 30; //RO 2204

	//FIRST DIALOG (restart? transmitted? check position?)

	if (File.exists(TempDisk + ":\\ANALYSIS DUMP\\Settings\\Settings_Previous_Exp.tif")) {
		PresenceSettingsFile = 1;
		open(TempDisk + ":\\ANALYSIS DUMP\\Settings\\Settings_Previous_Exp.tif"); //bpx
		info = getMetadata("info");
		close();
		List.setList(info);
		TransmittedChannelPresent = List.get("TransmittedChannelPresent");
		CheckPositionNumber = List.get("CheckPositionNumber");
		CheckPositionName = List.get("CheckPositionName");
		ReadFileName = List.get("ReadFileName"); //bp33

	} else {
		PresenceSettingsFile = 0;
		TransmittedChannelPresent = 1;
		CheckPositionNumber = 1;
		CheckPositionName = 1;
		ReadFileName = 1; //bp33
	}

	if (RunAllQueued == 0 && Exp == 1) {
		Dialog.create("Restart?");
			Dialog.addCheckbox("Select box if this is a restart", 0);
			Dialog.addCheckbox("Is there a Transmitted Channel?", TransmittedChannelPresent);
			Dialog.addCheckbox("Check Position number?", CheckPositionNumber);
			Dialog.addCheckbox("Check Position Name?", CheckPositionName);
			Dialog.addCheckbox("Read file name from metadata ?", ReadFileName); //bp34
		//Dialog.show();
			Restart = Dialog.getCheckbox();
			TransmittedChannelPresent = Dialog.getCheckbox();
			TCPForOverruling = TransmittedChannelPresent;
			CheckPositionNumber = Dialog.getCheckbox();
			CheckPositionName = Dialog.getCheckbox();
			ReadFileName = Dialog.getCheckbox(); //	bp34
	}

	//RESTART, CHECK LAST POSITION
	if (QueueMultiple == 0) {
		WhereToSaveSettings = 1;
	}
	if (QueueMultiple) {
		WhereToSaveSettings = nQueuedExp + 1;
	}

	if (Restart) {
		if (File.exists(TempDisk + ":\\ANALYSIS DUMP\\" + Q + "Exp" + Exp + "\\Settings\\Settings_Exp" + Exp + ".tif")) {} else {
			exit("No Settings File!, cannot restart!");
		}

		List.clear; //Start with retrieving last position sucessfully completed

		if (File.exists(TempDisk + ":\\ANALYSIS DUMP\\" + Q + "Exp" + Exp + "\\Settings\\Progress.tif")) {
			open(TempDisk + ":\\ANALYSIS DUMP\\" + Q + "Exp" + Exp + "\\Settings\\Progress.tif"); //bpx
			info = getMetadata("info");
			List.setList(info);
			Progress = parseFloat(List.get("Progress"));
		} else {
			Progress = -1;
		}
	}

	List.clear; //Start with retrieving settings from a previous run (if there is one)

	//LOAD SETTINGS		
	if (Restart) {
		if (File.exists(TempDisk + ":\\ANALYSIS DUMP\\" + Q + "Exp" + Exp + "\\Settings\\Settings_Exp" + Exp + ".tif")) {
			open(TempDisk + ":\\ANALYSIS DUMP\\" + Q + "Exp" + Exp + "\\Settings\\Settings_Exp" + Exp + ".tif");
			info = getMetadata("info");
			close(); //print(info);
			List.setList(info);
		}
	} else {
		if (File.exists(TempDisk + ":\\ANALYSIS DUMP\\Settings\\Settings_Previous_Exp.tif")) {
			open(TempDisk + ":\\ANALYSIS DUMP\\Settings\\Settings_Previous_Exp.tif");
			info = getMetadata("info");
			close(); //print(info);
			List.setList(info);
		}
	}

	SelectionX1 = newArray;
	SelectionX2 = newArray;
	SelectionY1 = newArray;
	SelectionY2 = newArray;
	TransmittedMin = newArray;
	TransmittedMax = newArray;
	TransmittedZslice = newArray;
	NumberOfTimepoints = newArray;
	LastTimepointBlack = newArray;
	Singletimepoint = newArray;
	ScaleBarYArray = newArray;
	nPixelsScaleBarArray = newArray;
	nMicronsScaleBarArray = newArray;
	ArrayZResolution = newArray;
	Threshold = newArray();

	ArraySkipPositions = newArray(10000);
	Array.fill(ArraySkipPositions, 0); //bp17
	SplitZ = newArray(10000);
	Array.fill(SplitZ, 0); //bp21	 	// 0 betekent geen splitting en 2 of 3 wil zeggen dat er gechopt wordt en het echte getal zegt in hoeveel delen 
	PileUpChunks = newArray(10000);
	Array.fill(PileUpChunks, 0); //bp37	
	SplitAndUnsplit = newArray(10000);
	Array.fill(SplitAndUnsplit, 0); //bp37	

	DefaultGamma = 0.55;
	DefaultMultiply = 1.2;
	SetLastTimepoint = 0;
	CheckLastTimepointBlack = 0;
	TimeProjectTransm = 0;
	nFramesForTimeProject = 35; // = parameter for this function

	ChannelColourOriginal = newArray("White", "Green", "Red", "Blue", "Cyan", "Magenta", "Yellow");

	RedDeadChannelUse = newArray("Nuclei", "DeadStuff", "Other", "Other", "Other", "Other", "Other", "Other");
	NucleiChannel = "None";
	DeadChannel = "None";
	oldhour = 0;
	oldminute = 0;
	oldsecond = 0;
	olddayOfMonth = 0;
	oldmonth = 0;
	oldyear = 0;

	SetBrightness = 150;
	FluoOffset = 4;
	RedDeadDye = false;
	Hidewindows = 1;
	Date = 20001231;
	NameExperiment = "NameExperiment"; //ShiftPositions = 0;	
	ColourName = 1;
	AddTime = 1;
	AddScaleBar = 1;
	AddScaleBarZ = 1;
	ExtendedSettings = 1;
	UseDepthcoding = "With";
	Interval = 10;
	ColorTime = "White";
	FractionForText = 20;
	FractionForBar = 0.15;
	WriteBarDimensions = 1;
	ScaleBarLineWidth = 2;
	NumberOfTPTempStacks = 8;
	NumberOfZsTempStacks = 5;
	SaveProgressToNetwork = false;
	DeleteZStacks = 1;
	SkipGlow = 0;
	TextInGlowIsWhite = 1;
	SetMultiplyBeforeDepthcoding = 1;
	WindowForPause = 1; //RO this failed if the settings file was not present!
	AddPositionName = 1;
	GuidedBC = 1;
	TimeProjectTransm = 1;
	TimeForPause = 250; // milliseconden
	PauseInterval = 3; //bpm
	PlaceScaleBarZ = "Top";
	UnsplitStillToDo = 1;
	NowDoTheUnsplit = 0;
	SplitAndUnsplitFill = 1; //BP37
	UpperLeft = 0;
	GarbageInterval = 1;
	AspectChoice = AspectArray[0];
	DefineFrameRate = 0;
	DefineAviLength = 0;
	FrameRateAvi = 10;
	AviLength = 20; // i.e. seconds

	//End of Standard settings, only used if the Settings file is not in the right position (you need to start from somewhere...)

	ChannelName = newArray("Max Project", "Max Project2", "Max Project3", "Max Project4", "Max Project5", "Max Project6", "Max Project7", "Max Project8", "Max Project9", "Max Project10"); //RO 2304

	// GET Settings from file (if present) // GET Settings from file (if present) // GET Settings from file (if present) 

	if (PresenceSettingsFile) {

		CodedFile = List.get("CodedFile");
		file = replace(CodedFile, "SLASH", "\\\\");
		SaveProgressToNetwork = List.get("SaveProgressToNetwork");
		CodedNetworkDirectory = List.get("CodedNetworkDirectory");
		NetworkDirectory = replace(CodedNetworkDirectory, "SLASH", "\\\\");
		PositionNumber = newArray;
		PositionName = newArray;
		PositionChannelAmount = newArray;
		TopZ = newArray;
		BottomZ = newArray;
		TransmittedChannelNumber = newArray(PositionNumber.length);
		MultiplyBeforeDepthcoding = newArray;
		GammaCorr = newArray; //Singletimepoint=newArray;

		//PositionNumber=corresponding position in LIF file, PositionName=Name as given in LASAF, PositionChannelAmount=amount of channels in said position
		TransmittedChannelPresent = List.get("TransmittedChannelPresent");
		if (TCPForOverruling != TransmittedChannelPresent) {
			TransmittedChannelPresent = TCPForOverruling;
		}
		CheckPositionNumber = List.get("CheckPositionNumber"); //RO2906 wrong position!
		CheckPositionName = List.get("CheckPositionName");
		if (nd2File || tiffFile) {
			CheckPositionName = 0;
		} //RO2906 wrong position!
		AmountOfPositions = List.get("AmountOfPositions");
		WindowForPause = List.get("WindowForPause");
		for (l = 0; l < AmountOfPositions; l++) {
			PositionNumber[l] = List.get("PositionNumber" + l);
			PositionName[l] = List.get("PositionName" + l);
			TopZ[l] = List.get("TopZ_" + l);
			BottomZ[l] = List.get("BottomZ_" + l);
			MultiplyBeforeDepthcoding[l] = List.get("MultiplyBeforeDepthcoding" + l);
			GammaCorr[l] = List.get("GammaCorr" + l);
			SetLastTimepoint = List.get("SetLastTimepoint");
			Threshold[l] = List.get("Threshold" + l);
		}
		ArraySizeForChannelUseandColour = parseFloat(List.get("ArraySizeForChannelUseandColour"));
		maxNumberOfChannels = parseFloat(List.get("maxNumberOfChannels"));
		UseChannel = newArray;
		ChannelColour = newArray; //ChannelName=newArray;	
		for (l = 0; l < ArraySizeForChannelUseandColour; l++) {
			if (PresenceSettingsFile) {
				UseChannel[l] = List.get("UseChannel" + l);
				ChannelName[l] = List.get("ChannelName" + l);
			} else {
				UseChannel[l] = 1;
				ChannelName[l] = "Ch" + l;
			}
		}

		RedDeadDye = List.get("RedDeadDye");
		Hidewindows = List.get("Hidewindows");
		UpperLeft = List.get("UpperLeft");
		Date = List.get("Date");
		NameExperiment = List.get("NameExperiment");
		ColourName = List.get("ColourName");
		AddTime = List.get("AddTime");
		AddScaleBar = List.get("AddScaleBar");
		FractionForBar = List.get("FractionForBar");
		ScaleBarLineWidth = List.get("ScaleBarLineWidth");
		WriteBarDimensions = List.get("WriteBarDimensions");
		AddScaleBarZ = List.get("AddScaleBarZ");
		PlaceScaleBarZ = List.get("PlaceScaleBarZ");
		ExtendedSettings = List.get("ExtendedSettings");
		UseDepthcoding = List.get("UseDepthcoding");
		Interval = List.get("Interval");
		ColorTime = List.get("ColorTime");
		GuidedBC = List.get("GuidedBC");
		RedDeadDye = List.get("RedDeadDye");
		SkipGlow = List.get("SkipGlow"); //	AspectChoice = List.get("AspectChoice");	
		FractionForText = List.get("FractionForText");
		NumberOfTPTempStacks = List.get("NumberOfTPTempStacks");
		NumberOfZsTempStacks = List.get("NumberOfZsTempStacks");
		SaveProgressToNetwork = List.get("SaveProgressToNetwork");
		WindowForPause = List.get("WindowForPause");
		TimeForPause = List.get("TimeForPause");
		PauseInterval = List.get("PauseInterval");
		GarbageInterval = List.get("GarbageInterval");
		if (CheckPositionName) {
			AddPositionName = List.get("AddPositionName");
		} else {
			AddPositionName = 0;
		}
		DeleteZStacks = List.get("DeleteZStacks");
		TextInGlowIsWhite = List.get("TextInGlowIsWhite");
		SetMultiplyBeforeDepthcoding = List.get("SetMultiplyBeforeDepthcoding");
		maxNumberOfChannels = parseFloat(List.get("maxNumberOfChannels"));

		DefineFrameRate = List.get("DefineFrameRate");
		DefineAviLength = List.get("DefineAviLength");
		FrameRateAvi = List.get("FrameRateAvi");
		AviLength = List.get("AviLength");

		for (l = 0; l < maxNumberOfChannels; l++) {
			UseChannel[l] = List.get("UseChannel" + l);
			ChannelName[l] = List.get("ChannelName" + l);
			RedDeadChannelUse[l] = List.get("RedDeadChannelUse" + l);
			NucleiChannel = List.get("NucleiChannel");
			DeadChannel = List.get("DeadChannel");
		}
		ChromaticAberration = List.get("ChromaticAberration");
		FeasableRib = List.get("FeasableRib");

		DefaultGamma = List.get("DefaultGamma");
		DefaultGamma = parseFloat(DefaultGamma);
		if (isNaN(DefaultGamma)) {
			DefaultGamma = 0.55;
		} // the isNaN is a trik to make sure that also the very first time the macro is used, there is a default setting
		DefaultMultiply = List.get("DefaultMultiply");
		DefaultMultiply = parseFloat(DefaultMultiply);
		if (isNaN(DefaultMultiply)) {
			DefaultMultiply = 1.2;
		}
		SetLastTimepoint = List.get("SetLastTimepoint");
		if (isNaN(parseFloat(SetLastTimepoint))) {
			SetLastTimepoint = 0;
		}
		CheckLastTimepointBlack = List.get("CheckLastTimepointBlack");
		if (isNaN(parseFloat(CheckLastTimepointBlack))) {
			CheckLastTimepointBlack = 0;
		}
		TimeProjectTransm = List.get("TimeProjectTransm");

		AddScaleBarZLeft = 0;
		if (AddScaleBarZ && PlaceScaleBarZ == "Left") {
			AddScaleBarZLeft = 1;
		}
		AddScaleBarZTop = 0;
		if (AddScaleBarZ && PlaceScaleBarZ == "Top") {
			AddScaleBarZTop = 1;
		}

	}

	if (Restart) { // <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< RESTART BEGIN >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		// This part is to retreive the positional data in the case of a restart.
		// Note we are not opening any file yet as we don't need to ask for settings, the positions will be opened as required!
		//RESTART, SETTINGS
		CodedFile = List.get("CodedFile");
		file = replace(CodedFile, "SLASH", "\\\\");
		SaveProgressToNetwork = List.get("SaveProgressToNetwork");
		CodedNetworkDirectory = List.get("CodedNetworkDirectory");
		NetworkDirectory = replace(CodedNetworkDirectory, "SLASH", "\\\\");
		PositionNumber = newArray;
		PositionName = newArray;
		PositionChannelAmount = newArray;
		TopZ = newArray;
		BottomZ = newArray;
		TransmittedChannelNumber = newArray(PositionNumber.length);
		MultiplyBeforeDepthcoding = newArray;
		GammaCorr = newArray; //Singletimepoint=newArray;

		BottomZ_1 = newArray;
		TopZ_1 = newArray;
		GammaCorr_1 = newArray;
		MultiplyBeforeDepthcoding_1 = newArray;
		BottomZ_2 = newArray;
		TopZ_2 = newArray;
		GammaCorr_2 = newArray;
		MultiplyBeforeDepthcoding_2 = newArray;
		BottomZ_3 = newArray;
		TopZ_3 = newArray;
		GammaCorr_3 = newArray;
		MultiplyBeforeDepthcoding_3 = newArray;

		//PositionNumber=corresponding position in LIF file, PositionName=Name as given in LASAF, PositionChannelAmount=amount of channels in said position
		TransmittedChannelPresent = List.get("TransmittedChannelPresent");
		TCPForOverruling = TransmittedChannelPresent;
		CheckPositionNumber = List.get("CheckPositionNumber");
		CheckPositionName = List.get("CheckPositionName");
		AmountOfPositions = List.get("AmountOfPositions");
		WindowForPause = List.get("WindowForPause");
		SetLastTimepoint = List.get("SetLastTimepoint");
		DefineFrameRate = List.get("DefineFrameRate");
		DefineAviLength = List.get("DefineAviLength");
		FrameRateAvi = List.get("FrameRateAvi");
		AviLength = List.get("AviLength");

		for (l = 0; l < AmountOfPositions; l++) {
			ArraySkipPositions[l] = List.get("ArraySkipPositions_" + l); //bp17
			PileUpChunks[l] = List.get("PileUpChunks_" + l);
			if (isNaN(PileUpChunks[l])) {
				PileUpChunks[l] = 1; 
			} //bp37
			SplitAndUnsplit[l] = List.get("SplitAndUnsplit_" + l);
			if (isNaN(SplitAndUnsplit[l])) {
				SplitAndUnsplit[l] = 0;
			} //bp37
			PositionNumber[l] = List.get("PositionNumber" + l);
			PositionName[l] = List.get("PositionName" + l);
			PositionChannelAmount[l] = List.get("PositionChannelAmount" + l);
			TransmittedChannelNumber[l] = List.get("TransmittedChannelNumber" + l);
			TopZ[l] = List.get("TopZ_" + l);
			BottomZ[l] = List.get("BottomZ_" + l);
			MultiplyBeforeDepthcoding[l] = List.get("MultiplyBeforeDepthcoding" + l);
			GammaCorr[l] = List.get("GammaCorr" + l);
			SplitZ[l] = List.get("SplitZ" + l);

			if (SplitZ[l] > 0) {
				BottomZ_1[l] = List.get("BottomZ_1_" + l);
				TopZ_1[l] = List.get("TopZ_1_" + l);
				GammaCorr_1[l] = List.get("GammaCorr_1_" + l);
				MultiplyBeforeDepthcoding_1[l] = List.get("MultiplyBeforeDepthcoding_1_" + l);
				BottomZ_2[l] = List.get("BottomZ_2_" + l);
				TopZ_2[l] = List.get("TopZ_2_" + l);
				GammaCorr_2[l] = List.get("GammaCorr_2_" + l);
				MultiplyBeforeDepthcoding_2[l] = List.get("MultiplyBeforeDepthcoding_2_" + l);
			}
			if (SplitZ[l] == 3) {
				BottomZ_3[l] = List.get("BottomZ_3_" + l);
				TopZ_3[l] = List.get("TopZ_3_" + l);
				GammaCorr_3[l] = List.get("GammaCorr_3_" + l);
				MultiplyBeforeDepthcoding_3[l] = List.get("MultiplyBeforeDepthcoding_3_" + l);
			}

		}

		ArraySizeForChannelUseandColour = parseFloat(List.get("ArraySizeForChannelUseandColour"));
		maxNumberOfChannels = parseFloat(List.get("maxNumberOfChannels"));
		UseChannel = newArray;
		ChannelColour = newArray;
		ChannelName = newArray;
		for (l = 0; l < ArraySizeForChannelUseandColour; l++) {
			ChannelColour[l] = List.get("ChannelColour" + l);
			if (PresenceSettingsFile) {
				UseChannel[l] = List.get("UseChannel" + l);
				ChannelName[l] = List.get("ChannelName" + l);
			} else {
				UseChannel[l] = 1;
				ChannelName[l] = "Ch" + l;
			}
		}
		PreviousRunWasDone = false;
		if (Progress == -1) {
			Progress = 0;
		} else {
			Progress = Progress + 1;
		}
		print("Progress " + Progress);
		if (Progress >= AmountOfPositions) {
			Progress = 0;
			PreviousRunWasDone = true;
		}
		if (File.exists(TempDisk + ":\\ANALYSIS DUMP\\" + Q + "Exp" + Exp + "\\Settings\\Progress.tif")) {
			selectWindow("Progress.tif");
		}
		//RESTART, DIALOG, CHOOSE POSITION	

		AskFromWichPos = 0;
		if (RunAllQueued == 0 && Exp == 1) {
			AskFromWichPos = 1;
		}
		if (RestartQueueRun && FirstRoundRestart) {
			AskFromWichPos = 1;
		}
		// now the FirstRoundRestart can be set at 0, because not necessary anymore
		FirstRoundRestart = 0;
		if (AskFromWichPos) {
			ArrayWithSkippedPositions = newArray(0);
			Temp = newArray(1);
			for (h = 0; h < AmountOfPositions; h++) {
				if (ArraySkipPositions[h] == 1) {
					Temp[0] = h;
					ArrayWithSkippedPositions = Array.concat(ArrayWithSkippedPositions, Temp);
					print("ArraySkipPositions :");
					Array.print(ArraySkipPositions);
					print(" :");
					print("");
				}
			}

			Dialog.create("Restart from which position?")
				if (PreviousRunWasDone) {
					Dialog.addMessage("!======================! ATTENTION: !======================!");
					Dialog.addMessage("Last run was completed or progress file doesn't match the settings file");
					Dialog.addMessage("!======================!===========!=====================!");
				}
				Dialog.addMessage("Please choose from which position the macro should restart");
				Dialog.addMessage("The suggested start is already selected");
				if (File.exists(TempDisk + ":\\ANALYSIS DUMP\\" + Q + "Exp" + Exp + "\\Settings\\Progress.tif")) {
					Dialog.addMessage("The Progress window shows the last postion completed successfully");
				} else {
					Dialog.addMessage("Could not complete the first position!");
				}
				Dialog.addRadioButtonGroup("Please choose position to start from", PositionNumber, AmountOfPositions, 1, PositionNumber[Progress]);
				for (h = 0; h < ArrayWithSkippedPositions.length; h++) {
					Dialog.addMessage("#" + ArraySkipPositions[h] + " was skipped");
				}
			Dialog.show();
				StartfromPositionNumber = Dialog.getRadioButton();

		} else {
			StartfromPositionNumber = PositionNumber[Progress];
		}

		for (l = 0; l < AmountOfPositions; l++) {
			if (PositionNumber[l] == StartfromPositionNumber) {
				StartFromi = l;
				print("StartFromi: " + StartFromi); 
			}
		}
		if (RunAllQueued && RestartQueueRun == 0) {
			StartFromi = 0;
		} // bp37
		if (File.exists(TempDisk + ":\\ANALYSIS DUMP\\" + Q + "Exp" + Exp + "\\Settings\\Progress.tif")) {
			selectWindow("Progress.tif");
			close();
		}

	} else { // <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< RESTART ELSE >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

		//NORMAL, SETTINGS	
		StartFromi = 0;

		//file = File.openDialog("Choose LIF-file to process");
		file = inputfilename; // ##DB## picked up from input arguments
		CodedFile = replace(file, "\\\\", "SLASH");

		liffFile = 0;
		if (endsWith(file, ".lif")) {
			liffFile = 1;
		}
		tiffFile = 0;
		if (endsWith(file, ".tif")) {
			tiffFile = 1;
		}
		if (tiffFile) {
			TransmittedChannelPresent = 0;
			CheckPositionNumber = 0;
			CheckPositionName = 0;
			ReadFileName = 0;
		}
		nd2File = 0;
		if (endsWith(file, ".nd2")) {
			nd2File = 1;
		}
		if (nd2File) {
			TransmittedChannelPresent = 0;
			CheckPositionNumber = 0;
			CheckPositionName = 0;
			ReadFileName = 0;
		}

		run("Bio-Formats", "open=[" + file + "] color_mode=Default split_channels view=Hyperstack stack_order=XYCZT");
		setLocation(1,1);
		print("CURRENT TIME -", makeDateOrTimeString("time"));

		FilePathForInCase = File.directory;

		if (Timo == 3) {
			waitForUser("open tif");
			run("Bio-Formats Importer", "open=[] color_mode=Default split_channels view=Hyperstack stack_order=XYCZT use_virtual_stack");
			file = File.directory + getTitle();
		}

		//Chose a file to process, this way we also set which file to use for the open commands
		//The CodedFile is required as \ marks disappear when saved to a file (required for Restart)


		MetadataLIF = getImageInfo(); // is a large string containing all info about the opened images
		print(MetadataLIF);
		if (Timo == 3) {
			waitForUser("print(MetadataLIF)");
		}
		PositionNumber = newArray;

		if (PresenceSettingsFile) {
			TimeProjectTransm = List.get("TimeProjectTransm");
		} else {
			TimeProjectTransm = 0;
		}
		nFramesForTimeProject = 35; // = parameter for this function

		//NORMAL, POSITION NUMBER	
		if (CheckPositionNumber) { // Added this if-loop in case the metadata is such that the search is incorrect i.e. giving an error...
			AmountOfPositions = 0;
			Start = 0;
			Name = "0";
			continueW = 1;
			while (continueW == 1) { //This while loop is to determine how many and which postions were opened and to add them to an array
				continueW = 0;
				IndexPos = indexOf(MetadataLIF, "Name ", Start) - 9; //RO 0204 changed this to be able to process positions larger than 99...
				IndexPos = indexOf(MetadataLIF, " ", IndexPos); //RO 0204 changed this to be able to process positions larger than 99...
				Start = IndexPos + 10;
				IndexPosEnd = indexOf(MetadataLIF, " ", IndexPos + 1); //RO 0204 changed this to be able to process positions larger than 99...
				Name = substring(MetadataLIF, IndexPos, IndexPosEnd); //RO 0204 changed this to be able to process positions larger than 99...
				PositionNumber[AmountOfPositions] = parseFloat(Name) + 1;
				AmountOfPositions = AmountOfPositions + 1;
				Name = parseFloat(Name);
				if (Name >= 0) {
					continueW = 1;
				};	// !!##DB this semi colon is very weird, but the macro currently runs so I'm hesitant to remove it
			}
			PositionNumber = Array.trim(PositionNumber, PositionNumber.length - 1);
			//Remove the last point in the Array as this is not a number! 
			PositionNumber = Array.sort(PositionNumber); //Sort the array as he order in the metadata is 0-1-10-11-...-2-3 etc. this doesnot correspond to the order the images are opened!
			AmountOfPositions = AmountOfPositions - 1;
			//Correct for loop going 1 to far (asigning LD as a position number) Need this variable to make determine array.length when retreiving data from the settings file

		} else {
			if (tiffFile == 0) {
				Dialog.create("How many positions were opened?") // I added this in case the check positions doesn't work and the user opted to switch it off
					Dialog.addNumber("Amount of positions", 1); // and I needed a way to find out how many positions were opened PS I haven;t really tested this...
				//Dialog.show();
					AmountOfPositions = Dialog.getNumber();
			} else {
				AmountOfPositions = 1;
			}
			PositionNumber = newArray(AmountOfPositions);
			for (PositionNumberFill = 0; PositionNumberFill < PositionNumber.length; PositionNumberFill++){
				PositionNumber[PositionNumberFill] = PositionNumberFill + 1;
			} 

		}

		PositionName = newArray(PositionNumber.length);
		PositionChannelAmount = newArray(PositionNumber.length);
		TransmittedChannelNumber = newArray(PositionNumber.length);
		Transmittedfound = newArray(PositionNumber.length);
		Array.fill(Transmittedfound, 0);
		print("AmountOfPositions" + AmountOfPositions);

		// Counts the number of channels and determines the name for each postion 
		// The name for each position is derived from the title of the window (is always 'filename'.lif - 'Positionname' - C='channelnumber')
		// Set i as position.length -1 as we start with the highest position number (ie the last one opened)
		for (i = AmountOfPositions - 1; i >= 0; i--) {

			//NORMAL, POSITION NAME	
			ImageTitle = getTitle();
			if (tiffFile) {
				TiffName = ImageTitle;
			}
			if (nd2File) {
				nd2Name = ImageTitle;
			}
			EndIndex = indexOf(ImageTitle, "- C=") - 1;
			EditTitle = ImageTitle; //bp11
			StringLength = lengthOf(EditTitle);
			TitleLength = StringLength - 4; // want altijd .tif of .nd2 etc
			if (CheckPositionName && nd2File == 0 && tiffFile == 0 && TitleLength > 6) {
				BeginIndex = indexOf(ImageTitle, ".lif - ") + 7;
				EndIndex = indexOf(ImageTitle, "- C=") - 1;
				filename = substring(ImageTitle, 0, BeginIndex - 3); 
				if (EndIndex < BeginIndex) {
					PositionName[i] = "No name" + i;
				} else { // RO 2904
					PositionNameTemp = substring(ImageTitle, BeginIndex, EndIndex);
					PositionName[i] = replace(PositionNameTemp, "/", "--");
				} // Need to replace/ if it is to be used in saving the file
			}
			count = 0;
			if (nd2File == 0 && tiffFile == 0) {
				while (endsWith(ImageTitle, count) == 0) count = count + 1; //Keeps on adding up till c equals the number at the end of the title, in other words the channel number
				channels = count + 1;
				PositionChannelAmount[i] = channels; //The amount of channels is the channel number +1 (as channel 1 is "C=0")
			}
			if (nd2File || tiffFile) {
				//if (nd2File) waitForUser("it's an nd2-file, so macro assumes that it is 1 channel only");		// ##DB## commented out
				if (tiffFile) waitForUser("it's a tiff-file, so macro assumes that it is 1 channel only");
				PositionChannelAmount[i] = 1;
			}

			//NORMAL, TRANSMITTED CHANNEL		

			getDimensions(dummy, dummy, nChannels, dummy, dummy);
			if (nChannels > 1) {
				waitForUser(" YOU FORGOT TO SPLIT CHANNELS UPON OPENING ; DO AGAIN");
			}

			Transmittedfound[i] = 0; //Next part closes all non-White channels and counts the amount of white channels, if there is 1 then it also defines the transmitted channel
			//Counting i down as the last channel opened (hihgest number) is the one on top, could actually also do it the other way around as we select the window...
			if (tiffFile + nd2File == 0) {

				for (j = PositionChannelAmount[i] - 1; j >= 0; j--) {
					c = j; //Loop to process the channels! for this position
					ImageTitle = getTitle();
					EndIndex = indexOf(ImageTitle, "- C=") - 1;
					if (tiffFile) {
						/* I do nothing here, because nd2 is from spinning disk which does not generate transmitted channel */
						/*filename=getTitle;*/
					}
					if (nd2File) {
						/* I do nothing here, because nd2 is from spinning disk which does not generate transmitted channel */
					}

					TempName = substring(ImageTitle, 0, EndIndex);
					selectWindow(TempName + " - C=" + c);
					Temp = getTitle();
					Colour = ChannelColourOriginal[GetLUTColour(Temp)]; //This returns the channel colour GetLUTColour(returns a number) which refers to the position in the array ChannelColourOriginal)	
					ChannelColour[j] = Colour;
					print("Colour: " + Colour); //So we now make an array with the colour of each channel
					if (TransmittedChannelPresent) {
						if (Colour != "White") {
							close();
						} else {
							Transmittedfound[i] = Transmittedfound[i] + 1;
							TransmittedChannelNumber[i] = j;
							rename("temp"); // need to rename so "Put Behind [tab]" will work
							rename(TempName + " - C=" + c);
							run("Put Behind [tab]");
							wait(200);

						}
					} else {
						if (c != 0) {
							close();
						} else {
							run("Put Behind [tab]");
						}
					}
				} //	end of for channelAmount
			} //
			if (tiffFile + nd2File > 0) {
				ChannelColour = newArray(1);
				ChannelColour[0] = "White";
			}

		} //	End of determining amount of channels per position and which are white (closing all non white windows)
		// end of for positionAmount

		if (TransmittedChannelPresent) {
			LastPositionOnly = 1;
			for (i = AmountOfPositions - 1; i >= 0; i--) {
				ImageTitle = getTitle();
				EndIndex = indexOf(ImageTitle, "- C=") - 1;
				TempName = substring(ImageTitle, 0, EndIndex);
				ImageTitleold = newArray;
				for (j = 0; j < Transmittedfound[i]; j++) {
					ImageTitleold[j] = TempName + " - C=" + j;
					run("Put Behind [tab]");
				}
				if (Transmittedfound[i] != 1) {

					if (LastPositionOnly) {
						if (i == AmountOfPositions - 1) {
							LastPositionOnly = 0;
							getLocationAndSize(x0, y0, WidthTrans, HeightTrans);
							Zoom = getZoom();
							ActualWidthTrans = WidthTrans / Zoom;
							ActualHeightTrans = HeightTrans / Zoom;
							TotalWidth = (ActualWidthTrans + 5) * (Transmittedfound[i] - 1);
							Zoom = 1;
							while (Zoom * TotalWidth > ScreenWidth) {
								Zoom = Zoom * 0.9;
							}
							NewWidthTrans = ActualWidthTrans * Zoom;
							NewHeightTrans = ActualHeightTrans * Zoom;
							y1 = 0.5 * ScreenHeight - 0.5 * NewHeightTrans;
							x1 = 1;

							ImageTitles = newArray;
							for (j = 0; j < Transmittedfound[i]; j++) {
								ImageTitles[j] = getTitle();
								rename("Trans?" + ImageTitles[j]);
								run("Put Behind [tab]");
							}
							for (j = 0; j < Transmittedfound[i]; j++) {
								selectWindow("Trans?" + ImageTitles[j]);
								setLocation(x1, y1, NewWidthTrans, NewHeightTrans);
								x1 = x1 + NewWidthTrans + 10;
							}

							MaxGrey = 0;
							for (j = 0; j < Transmittedfound[i]; j++) {
								selectWindow("Trans?" + ImageTitles[j]);
								run("Select All");
								run("Measure");
								CurrentGrey = getResult("Mean", nResults - 1);
								if (CurrentGrey > MaxGrey) {
									MaxGrey = CurrentGrey;
									WindowOfMaxGrey = getTitle;
								}
							}
							selectWindow(WindowOfMaxGrey);
							Zoom = getZoom;
							run("Set... ", "zoom=" + Zoom * 110);
							waitForUser(" Macro is not sure which one is the Transmitted Channel ! \n \n Please select the transmitted channel of Position " + i + 1 + " \n THEN Press OK ! \n \n (macro thinks it's this enlarged one) ");

							TrueTransmitted = getTitle();
							print("TrueTransmitted = " + TrueTransmitted);
							EndIndex = indexOf(TrueTransmitted, "- C=") - 1;
							ThisChannelIsTheTransmitted = substring(TrueTransmitted, lengthOf(TrueTransmitted) - 1, lengthOf(TrueTransmitted));
							ThisChannelIsTheTransmitted = parseFloat(ThisChannelIsTheTransmitted);
							TransmittedChannelNumber[i] = ThisChannelIsTheTransmitted;
						}

						for (j = 0; j < Transmittedfound[i]; j++) {
							selectWindow("Trans?" + ImageTitles[j]);
							if (getTitle() == TrueTransmitted) {
								rename(ImageTitles[j]);
								Array.print(TransmittedChannelNumber);
								Array.fill(TransmittedChannelNumber, ThisChannelIsTheTransmitted);
								Array.print(TransmittedChannelNumber);
							} else {
								rename(ImageTitles[j]);
							}
							wait(500);
						}
					}
					for (j = 0; j < Transmittedfound[i]; j++) {

						if (j == ThisChannelIsTheTransmitted) {
							run("Set... ", "zoom=100");
						} else {
							if (isOpen(ImageTitleold[j])) {
								selectWindow(ImageTitleold[j]);
								close();
							}
						}
					}

				}
				c = TransmittedChannelNumber[i]; 
				selectWindow(TempName + " - C=" + c);
				rename("TransmittedVirtual_" + PositionNumber[i]);
				TransmittedWindow = getTitle;
				getDimensions(dummy, dummy, dummy, ZSLICE, TIMEPOINTS);
				ZSLICE = round(ZSLICE / 2);
				TIMEPOINTS = round(TIMEPOINTS / 2); //bp(floor) !!!!!!!!!!!!!!!!!!!!!!!!! 
				Stack.setPosition(1, ZSLICE, TIMEPOINTS);
				setMetadata("Position", j);
				//bp time-project
				DoSetZ = 1; //RO 0704	SetTransmittedBrightness("TransmittedVirtual_"+PositionNumber[i]);					//Sets the brightness to a predefined setting (best guess to start from...)
				if (TimeProjectTransm == 0) {
					drawROI("TransmittedVirtual_" + PositionNumber[i]);
				}
				run("Put Behind [tab]");
				wait(100);
			} // vd for(i=AmountOfPositions-1;	//bp19
			run("Collect Garbage"); //bpgarbage
		}
		for (i = AmountOfPositions - 1; i >= 0; i--) {
			if (TransmittedChannelPresent == 0) {
				TransmittedChannelNumber[i] = -1;
			}
		}

		//NORMAL, CHANGE LUT SETTING FOR WHITE CHANNELS
		//This part moves all non-transmitted white channels to the next colour in the array, at this time it doesn't prevent a white channel getting a lut already used by another channel
		Array.getStatistics(PositionChannelAmount, min, maxNumberOfChannels, mean, stdDev);
		ChannelColourTracking = newArray("White", "Green", "Red", "Blue", "Cyan", "Magenta", "Yellow"); //for some reason putting: ChannelColourTracking=ChannelColourOriginal; also changes the latter array in parallel !better to do it this way! PS ChannelColourOriginal=ChannelColourOriginal; seems to create a loop!
		ChannelColourTracking[0] = "None";
		NextColour = 0;
		i = 0;
		for (j = 0; j < maxNumberOfChannels; j++) {
			if (TransmittedChannelPresent == 0) {
				TransmittedChannelNumber[i] = -1;
			}
			if (TransmittedChannelNumber[i] != j) {
				if (ChannelColour[j] == "White") {
					ChannelColour[j] = ChannelColourTracking[NextColour];
					while (ChannelColour[j] == "None") {
						ChannelColour[j] = ChannelColourTracking[NextColour];
						ChannelColourTracking[NextColour] = "None";
						NextColour = NextColour + 1;
					}
					print(ChannelColour[j]);
				}
			}
		}
		Array.print(ChannelColour);

		Array.getStatistics(PositionChannelAmount, min, maxNumberOfChannels, mean, stdDev);
		ArraySizeForChannelUseandColour = AmountOfPositions * maxNumberOfChannels;
		UseChannel = newArray(ArraySizeForChannelUseandColour);

	} // <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< RESTART END >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

	AskToCheckSettings = 0;
	CheckSettings = 0; //bp44
	if (RunAllQueued == 0 && Restart == 1) {
		AskToCheckSettings = 1;
		Extra = "";
	}
	if (RestartQueueRun && Exp == ExpForRestart) {
		AskToCheckSettings = 1;
		Extra = " \n \n by the way, changing the settings can only be done for THIS experiment";
	}
	if (AskToCheckSettings) {
		Dialog.create("Before Restarting...");
			Dialog.addMessage("Before Restarting...");
			Dialog.addCheckbox("Check and/or modify the settings ?", CheckSettings);
			Dialog.addMessage(Extra);
		Dialog.show();
			CheckSettings = Dialog.getCheckbox();
	} //bp44

	if (TempXtoD) {
		fileTemp = replace(file, "X", "D");
		file = fileTemp;
		print("file_" + file);
		waitForUser("file_" + file);
	}

	print("file_" + file);
	Array.print(PositionNumber);
	if (CheckPositionName) {
		Array.print(PositionName);
	}
	Array.print(PositionChannelAmount);
	print("maxNumberOfChannels " + maxNumberOfChannels);
	//First print command, to check whether everything is as selected
	// ==================================== Now we know the amount of positions, which positions and the amount of channels per position. And Which is the transmitted Now let get the general settings ======================================
	// ==================================== Now we know the amount of positions, which positions and the amount of channels per position. And Which is the transmitted Now let get the general settings ======================================

	//SET STANDARD SETTINGS (OR LOAD FROM SETTINGSFILE)
	//Standard settings, only used if the Settings file is not in the right position (you need to start from somewhere...)
	//ChannelName=newArray( "Max Project", "Max Project2", "Max Project3", "Max Project4", "Max Project5", "Max Project6", "Max Project7"); //List.set("ChannelName"+0,ChannelName[0]);
	UseChannel = newArray(maxNumberOfChannels);
	Array.fill(UseChannel, 1);
	ChannelNumber = newArray(maxNumberOfChannels);
	for (countNofCh = 0; countNofCh < maxNumberOfChannels; countNofCh++) {
		CountChannelNumber = countNofCh + 1;
		ChannelNumber[countNofCh] = (CountChannelNumber);
	}

	//End of Retrieve the settings from a previous run, this way the user doesn't need to change the same things every time
	run("Collect Garbage");
	if (Restart) {} else {
		run("Tile");
	} //bp

	if (TransmittedChannelPresent && Restart == 0) {
		LastWindow = PositionNumber[PositionNumber.length - 1];
		selectWindow("TransmittedVirtual_" + LastWindow);
		run("Out [-]");
		run("In [+]");
		if (TimeProjectTransm == 0) {
			drawROI("TransmittedVirtual_" + LastWindow);
		}
	}

	if (Restart) {} else { // <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< RESTART BEGIN/ELSE >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

		//NORMAL, DIALOG "SETTINGS"
		// !!!!!!!!!!!!!!! =========== Here We open a window to define all settings ===============!!!!!!!!!!!!!
		blank = newArray();
		for (bl = 0; bl < UseChannel.length; bl++) blank[bl] = " ";
		Array.print(ChannelColour);
		if (ReadFileName) { //bp33
			FileExtension = ".lif";
			if (nd2File) {
				FileExtension = ".nd2";
			}
			if (tiffFile) {
				FileExtension = ".tif";
			}
			// want met tiffFile of nd2File kan-i geen lif vinden
			IndexFileExtension = indexOf(EditTitle, FileExtension);
			EditTitle = substring(EditTitle, 0, IndexFileExtension);
			LastFigureInString = lengthOf(EditTitle);
			Continue = 1;
			u = 0;
			while (Continue) {
				Character = substring(EditTitle, u, u + 1);
				Character = parseFloat(Character);
				if (isNaN(Character)) {
					LastFigureInString = u;
					Continue = 0;
				}
				u = u + 1;
				print("");
				print(u);
				print(Character);
				print(LastFigureInString);
			}
			nFigures = LastFigureInString;
			Date = substring(EditTitle, 0, nFigures);
			NameExperiment = substring(EditTitle, nFigures + 1, lengthOf(EditTitle));
		} //bp33

		TCP = TransmittedChannelPresent;
		Dialog.create("Settings");
			Dialog.addString("Date experiment:", "");
			Dialog.addString("Name Experiment:", prefix + "_" + movie_index); //##DB## picked up from input arguments
			if (t_step == round(t_step)) {
				DecimalPlaces = 0;
			} else {
				DecimalPlaces = 1;
			} // + figure out, whether to use decimals or not. only when interval had a decimal other than 0
			Dialog.setInsets(10, 0, 3);
			Dialog.addNumber("Time Interval", t_step, DecimalPlaces, 5, "min"); //##DB## picked up from input arguments
			i = 0;
			Shift = (parseFloat(PositionChannelAmount[i]) - 1) * 22 + 22; //Assumes that the positions have the same amount as the first channel
			Dialog.setInsets(22, 0, 5)
			Dialog.addMessage("UseChannel Channel ChannelName ChannelColour");
			for (j = 0; j < PositionChannelAmount[i]; j++) {
				if (TransmittedChannelNumber[i] == j) {
					Dialog.addMessage("This Channel (" + ChannelNumber[j] + ") is the Transmitted! No settings Required!");
				} else {
					Dialog.setInsets(-5, 60, -22)
					Dialog.addCheckbox(" ", UseChannel[j])
					Dialog.setInsets(-20, 100, -40.5);
					Dialog.addChoice(ChannelNumber[j], ChannelColourOriginal, ChannelColour[j]);
					Dialog.setInsets(-20, 120, 0)
					Dialog.addString(" ", ChannelName[j], 10);
				}
			}
			Dialog.addMessage(" ");
			Dialog.setInsets(0, 40, -10);
			Dialog.addRadioButtonGroup("If <=2 Channels: Add depthcoding?", newArray("With", "Without"), 1, 2, UseDepthcoding);
			Dialog.addMessage(" ");
			Dialog.setInsets(0, 40, 0);
			Dialog.addCheckbox("RedDeadDye", RedDeadDye);
			if (TCP) {
				Dialog.setInsets(5, 40, 0);
				Dialog.addCheckbox("Time-Project Transmitted for Crop-ROI", TimeProjectTransm);
			}
			Dialog.setInsets(5, 40, 0);
			Dialog.addCheckbox("Limit Z-Stacks to be used?", DeleteZStacks);
			Dialog.setInsets(5, 40, 0);
			Dialog.addCheckbox("Set last Timepoint for each postion?", SetLastTimepoint);
			if (CheckPositionName) {
				Dialog.setInsets(5, 40, 0);
				Dialog.addCheckbox("Add Position Name to Filename?", AddPositionName);
			}
			Dialog.setInsets(5, 40, 0);
			Dialog.addCheckbox("Show Extended Settings?", ExtendedSettings);
		//Dialog.show();
		// !!!!!!!!!!!!!!! =========== Here We open a window to define all settings ===============!!!!!!!!!!!!!
		NumberOfChannelsToBeProcessed = 0;
		// !!!!!!!!!!!!!!! =========== Here We retreive all the chosen settings ===============!!!!!!!!!!!!!
			Date = Dialog.getString();
			print("Date experiment: " + Date);
			NameExperiment = Dialog.getString();
			print("Name Experiment: " + NameExperiment);
			Interval = Dialog.getNumber();
			print("Time Interval: " + Interval + " min");
			i = 0;
			for (j = 0; j < PositionChannelAmount[i]; j++) {
				if (TransmittedChannelNumber[i] == j) {
					NumberOfChannelsToBeProcessed = NumberOfChannelsToBeProcessed + 1;
				} else {
					UseChannel[j] = Dialog.getCheckbox();
					if (UseChannel[j]) {
						ChannelColour[j] = Dialog.getChoice();
						NumberOfChannelsToBeProcessed = NumberOfChannelsToBeProcessed + 1;
					} else {
						ChannelColour[j] = "None";
					}
					ChannelName[j] = Dialog.getString();
				}
			}
			print("NumberOfChannelsToBeProcessed: " + NumberOfChannelsToBeProcessed);
			UseDepthcoding = Dialog.getRadioButton;
			RedDeadDye = Dialog.getCheckbox();
			if (TCP) {
				TimeProjectTransm = Dialog.getCheckbox();
			} else {
				TimeProjectTransm = 0;
			}
			DeleteZStacks = Dialog.getCheckbox();
			SetLastTimepoint = Dialog.getCheckbox();
			if (CheckPositionName) {
				AddPositionName = Dialog.getCheckbox();
			}
			ExtendedSettings = Dialog.getCheckbox();
		//bpx
		if (QueueMultiple) {
			nQueuedExp = nQueuedExp + 1;
		}
		if (RedDeadDye) NumberOfChannelsToBeProcessed = NumberOfChannelsToBeProcessed - 1;
		print("NumberOfChannelsToBeProcessed: " + NumberOfChannelsToBeProcessed);
		if (NumberOfChannelsToBeProcessed > 2) UseDepthcoding = "Without";

		if (UseDepthcoding == "Without" && NumberOfChannelsToBeProcessed <= 2) { //RO232 changed message and gave option to change setting (prevents having to restart the macro)
			Dialog.create("UseDepthcoding");
				Dialog.addMessage("UseDepthcoding is now 'WITHOUT'. \n \n you really want that ?? ");
				Dialog.addRadioButtonGroup("Add depthcoding?", newArray("With", "Without"), 1, 2, UseDepthcoding);
			Dialog.show();
				UseDepthcoding = Dialog.getRadioButton;
		}
		if (UseDepthcoding == "Without" && NumberOfChannelsToBeProcessed > 2) {
			waitForUser("There are more than 1 fluorescent channels! \n Depthconding can only be used with 1 channel! \n \n UseDepthcoding is now 'WITHOUT'.");
		} //RO232 changed message and gave option to change setting (prevents having to restart the macro)

		// !!!!!!!!!!!!!!! =========== Here We retreive all the chosen settings ===============!!!!!!!!!!!!!

		// !!!!!!!!!!!!!!! =========== Here We retreive settings for the red dead dye substraction ===============!!!!!!!!!!!!!
		//NORMAL, DIALOG "Choose channels for DeadDye and Nuclei"
		if (RedDeadDye) {
			Dialog.create("Choose channels for DeadDye and Nuclei");
				for (j = 0; j < PositionChannelAmount[i]; j++) {
					if (TransmittedChannelNumber[i] != j) {
						if (UseChannel[j]) {
							Dialog.addRadioButtonGroup(ChannelName[j], newArray("Nuclei", "DeadStuff", "Other"), 1, 3, RedDeadChannelUse[j]);
						}
					}
				}
			Dialog.show();
				for (j = 0; j < PositionChannelAmount[i]; j++) {
					if (TransmittedChannelNumber[i] != j) {
						if (UseChannel[j]) {
							RedDeadChannelUse[j] = Dialog.getRadioButton;
							if (RedDeadChannelUse[j] == "Nuclei") {
								NucleiChannel = j;
							}
							if (RedDeadChannelUse[j] == "DeadStuff") {
								DeadChannel = j;
							}
						}
					}
				}
		} else {
			NucleiChannel = "NaN";
			DeadChannel = "NaN";
		}
		// !!!!!!!!!!!!!!! =========== Here We retreive settings for the red dead dye substraction ===============!!!!!!!!!!!!!

		// !!!!!!!!!!!!!!! =========== Here We open a window to define where to save the progress file ===============!!!!!!!!!!!!!
		if (SaveProgressToNetwork) {
			NetworkDirectory = getDirectory("Choose location to save progress file");
			CodedNetworkDirectory = replace(NetworkDirectory, "\\\\", "SLASH");
		}

		// !!!!!!!!!!!!!!! =========== Here We open a window to define where to save the progress file ===============!!!!!!!!!!!!!
		//NORMAL, DIALOG "Extended settings"
		// !!!!!!!!!!!!!!! =========== Here We open a window to define all extended settings ===============!!!!!!!!!!!!!
		if (TransmittedChannelPresent) {
			selectWindow(TransmittedWindow);
			getDimensions(dummy, dummy, dummy, slices, dummy);
		}
		if (ExtendedSettings) {
			Shift = 130;
			Dialog.create("Extended settings");
				Dialog.addNumber("Number of TimePoints B&C window:", NumberOfTPTempStacks, 0, 12, "");
				Dialog.setInsets(10, Shift, 0);
				Dialog.addCheckbox("SetMultiplyBeforeDepthcoding", SetMultiplyBeforeDepthcoding);
				Dialog.addNumber("Default Gamma factor", DefaultGamma, 2, 9, "");
				Dialog.addNumber("Default Multiply factor", DefaultMultiply, 2, 9, "");
				Dialog.setInsets(10, Shift, 0);
				Dialog.addCheckbox("Window to pause macro", WindowForPause);
				Dialog.addNumber("Pause window - duration", TimeForPause, 0, 6, "msec");
				Dialog.addNumber("Pause window - every", PauseInterval, 0, 6, "frames");
				Dialog.addNumber("Collect Garbage - every", GarbageInterval, 0, 6, "frames");
				Dialog.setInsets(15, 0, 3);
				Dialog.addNumber("Fraction For Text (1/x) : ", FractionForText, 0, 3, "");
				Dialog.setInsets(15, Shift, 0);
				Dialog.addCheckbox("Add Channel Name?", ColourName);
				Dialog.setInsets(5, Shift, 0);
				Dialog.addCheckbox("Add Time Stamp?", AddTime);
				Dialog.addChoice("Colour Timestamp:", newArray("White", "Black", "Red", "Green", "Blue", "Cyan", "Magenta", "Yellow"), ColorTime);
				Dialog.setInsets(5, Shift, 0);
				Dialog.addCheckbox("Add Scale Bar?", AddScaleBar);
				Dialog.setInsets(-3, 214, 0);
				Dialog.addCheckbox("write scale above bar", WriteBarDimensions);
				Dialog.addNumber("width", FractionForBar, 2, 6, "(% of image)");
				Dialog.setInsets(5, Shift, -12);
				Dialog.addCheckbox("Add Reference Depthcoding?", AddScaleBarZ);
				Dialog.setInsets(-10, 190, 0);
				Dialog.addRadioButtonGroup("Left or above ?", newArray("Left", "Top"), 1, 2, PlaceScaleBarZ);

				Dialog.setInsets(20, Shift, 0);
				Dialog.addCheckbox("Define frame rate", DefineFrameRate);
				Dialog.setInsets(-23, 60, 0);
				Dialog.addNumber(" ", FrameRateAvi, 0, 6, " frames/sec");
				Dialog.setInsets(3, Shift, 0);
				Dialog.addCheckbox("Define length of movie", DefineAviLength);
				Dialog.setInsets(-23, 60, 0);
				Dialog.addNumber(" ", AviLength, 0, 6, " seconds");

				Dialog.setInsets(35, Shift, 0);
				Dialog.addCheckbox("CheckLastTimepointBlack", CheckLastTimepointBlack);
				Dialog.setInsets(0, Shift, 0);
				Dialog.addCheckbox("Save Progress to Network?", SaveProgressToNetwork);
				Dialog.setInsets(15, Shift, 0);
				Dialog.addCheckbox("Use orignal colour instead of Glow?", SkipGlow);
				Dialog.setInsets(0, Shift, 0);
				Dialog.addCheckbox("Print text in GlowWindow as White?", TextInGlowIsWhite);
				Dialog.setInsets(0, Shift, 0);
				Dialog.addCheckbox("Window-guiding while Setting B&C", GuidedBC);
				Dialog.setInsets(0, Shift, 0);
				Dialog.addCheckbox("Processing in Upper Left", UpperLeft);
				Dialog.setInsets(0, Shift, 0);
				Dialog.addCheckbox("Hide Windows", Hidewindows);
				Dialog.addChoice("Aspect Ratio of Output Movie ", AspectArray, AspectArray[0]);

			Dialog.show(); // !!!!!!!!!!!!!!! =========== Here We open a window to define all extended settings ===============!!!!!!!!!!!!!

				// !!!!!!!!!!!!!!! =========== Here We retreive all the chosen extended settings ===============!!!!!!!!!!!!!
				NumberOfTPTempStacks = Dialog.getNumber();
				print("Number Of TPoints TempStacks: " + NumberOfTPTempStacks); //bpm blokkie
				SetMultiplyBeforeDepthcoding = Dialog.getCheckbox();
				DefaultGamma = Dialog.getNumber();
				DefaultMultiply = Dialog.getNumber();
				WindowForPause = Dialog.getCheckbox();
				TimeForPause = Dialog.getNumber();
				PauseInterval = Dialog.getNumber();
				GarbageInterval = Dialog.getNumber();
				FractionForText = Dialog.getNumber();
				ColourName = Dialog.getCheckbox();
				AddTime = Dialog.getCheckbox();
				ColorTime = Dialog.getChoice();
				AddScaleBar = Dialog.getCheckbox();
				WriteBarDimensions = Dialog.getCheckbox();
				FractionForBar = Dialog.getNumber();
				AddScaleBarZ = Dialog.getCheckbox();
				PlaceScaleBarZ = Dialog.getRadioButton();

				DefineFrameRate = Dialog.getCheckbox();
				FrameRateAvi = Dialog.getNumber();
				DefineAviLength = Dialog.getCheckbox();
				AviLength = Dialog.getNumber();

				CheckLastTimepointBlack = Dialog.getCheckbox();
				SaveProgressToNetwork = Dialog.getCheckbox();
				SkipGlow = Dialog.getCheckbox();
				TextInGlowIsWhite = Dialog.getCheckbox();
				GuidedBC = Dialog.getCheckbox();
				UpperLeft = Dialog.getCheckbox();
				Hidewindows = Dialog.getCheckbox();
				AspectChoice = Dialog.getChoice();
		} // !!!!!!!!!!!!!!! =========== Here We retreive all the chosen extended settings ===============!!!!!!!!!!!!!
		AddScaleBarZLeft = 0;
		if (AddScaleBarZ && PlaceScaleBarZ == "Left") {
			AddScaleBarZLeft = 1;
		}
		AddScaleBarZTop = 0;
		if (AddScaleBarZ && PlaceScaleBarZ == "Top") {
			AddScaleBarZTop = 1;
		}

		MultiplyBeforeDepthcoding = newArray(AmountOfPositions);
		Array.fill(MultiplyBeforeDepthcoding, DefaultMultiply); //bpm blokkie
		GammaCorr = newArray(AmountOfPositions);
		Array.fill(GammaCorr, DefaultGamma);

		// bpxx
		if (QueueMultiple) {
			StringPreviousRun = "Q_" + Q + " ; Exp_" + WhereToSaveSettings;
			File.saveString(StringPreviousRun, TempDisk + ":\\ANALYSIS DUMP\\PreviousRun-info.txt");
		}

	} // <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< RESTART END >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

	// =========================================That was the general settings through dialog boxes, now lets get the ROI!========================================
	// =========================================That was the general settings through dialog boxes, now lets get the ROI!========================================

	//Need to create Arrays BEFORE the loop otherwise the older positions will be overwritten with NaN
	if (Restart) { // <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< RESTART BEGIN >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		//RESTART, GET SETTINGS FOR ALL POSITIONS
		for (i = StartFromi; i < PositionNumber.length; i++) { //This for loop is to retrieve the data set by user in the previous run
			NumberOfTimepoints[i] = List.get("NumberOfTimepoints" + i);
			SelectionX1[i] = List.get("SelectionX1_" + i);
			SelectionX2[i] = List.get("SelectionX2_" + i);
			SelectionY1[i] = List.get("SelectionY1_" + i);
			SelectionY2[i] = List.get("SelectionY2_" + i);
			ScaleBarYArray[i] = List.get("ScaleBarY_" + i);
			nPixelsScaleBarArray[i] = List.get("nPixelsScaleBar_" + i);
			nMicronsScaleBarArray[i] = List.get("nMicronsScaleBar_" + i);
			ArrayZResolution[i] = List.get("ArrayZResolution_" + i);
			TransmittedMin[i] = List.get("TransmittedMin" + i);
			TransmittedMax[i] = List.get("TransmittedMax" + i);
			TransmittedZslice[i] = List.get("TransmittedZslice" + i);
			LastTimepointBlack[i] = List.get("LastTimepointBlack" + i);
			MultiplyBeforeDepthcoding[i] = List.get("MultiplyBeforeDepthcoding" + i);
			print("NumberOfTimepoints[i]" + NumberOfTimepoints[i]);
			Singletimepoint[i] = List.get("Singletimepoint" + i);
		}
		print("Singletimepoint");
		Array.print(Singletimepoint);
	} else { // <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< RESTART ELSE >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

		//NORMAL, SET ROI, ZPLANE AND B&C 	
		run("Collect Garbage");
		setTool("rectangle");
		ArraynFrames = newArray(); //RO232
		ArraynSlices = newArray(); //RO232
		if (TransmittedChannelPresent) {
			for (i = 0; i < PositionNumber.length; i++) {
				if (TimeProjectTransm == 0) {
					selectWindow("TransmittedVirtual_" + PositionNumber[i]);
					TemporaryString = getTitle();
					getDimensions(dummy, dummy, dummy, ZSLICE, TIMEPOINTS);
					ZSLICE = round(ZSLICE / 2);
					TIMEPOINTS = round(TIMEPOINTS / 2);
					Stack.setPosition(1, ZSLICE, TIMEPOINTS);
					drawROI(TemporaryString);
				}
				if (TimeProjectTransm) {
					selectWindow("TransmittedVirtual_" + PositionNumber[i]);
					run("Select None");
					getDimensions(dummy, dummy, dummy, ZSLICE, TIMEPOINTS);
				} //bp17

				//RO232	
				Stack.getPosition(channel, slice, frame);
				getDimensions(dummy, dummy, dummy, TempnSlices, NumberOfFrames);
				ArraynFrames[i] = NumberOfFrames;
				ArraynSlices[i] = TempnSlices;
			}

		} else { //Needed to add ROI etc to a random fluorescent channel...
			for (i = 0; i < PositionNumber.length; i++) {
				if (CheckPositionName) {
					PositionName[i] = replace(PositionName[i], "--", "/");
					TemporaryString = filename + " - " + PositionName[i] + " - C=0";
				}
				if (tiffFile) {
					TemporaryString = TiffName;
				}
				if (nd2File) {
					TemporaryString = nd2Name;
				}
				getDimensions(dummy, dummy, dummy, ZSLICE, TIMEPOINTS);
				ZSLICE = round(ZSLICE / 2);
				TIMEPOINTS = round(TIMEPOINTS / 2);
				Stack.setPosition(1, ZSLICE, TIMEPOINTS);
				drawROI(TemporaryString);

				//RO232	
				Stack.getPosition(channel, slice, frame);
				getDimensions(dummy, dummy, dummy, TempnSlices, NumberOfFrames);
				ArraynFrames[i] = NumberOfFrames;
				ArraynSlices[i] = TempnSlices;
				//bp17
			}
		}
		run("Brightness/Contrast...");
		run("Tile");

		Array.getStatistics(ArraynFrames, minNofTimePoints, dummy, dummy, dummy); //RO232		exclude single timepoints in 1 step or not...
		Array.getStatistics(ArraynSlices, minNofSlices, dummy, dummy, dummy); //RO232		exclude single z-plane acquisitions... (BP)

		if (minNofTimePoints < 3) {
			Dialog.create("Exclude positions?");
				Dialog.addMessage(" Which ones would you like to exclude from analysis ? ");
				for (i = 0; i < PositionNumber.length; i++) {
					Dialog.setInsets(0, 40, 0);
					Dialog.addCheckbox("Pos#" + i + " --> only " + ArraynFrames[i] + " frame(s)", 0);
				}
				Dialog.addMessage(" ");
				Dialog.addCheckbox(" Ignore this and keep ALL postions anyway ", 0);
			Dialog.show();
				for (i = 0; i < PositionNumber.length; i++) {
					Temp = Dialog.getCheckbox();
					if (Temp) {
						ArraySkipPositions[i] = 1;
					}
				}
				KeepAllPositions = Dialog.getCheckbox();
			if (KeepAllPositions) {
				ArraySkipPositions[i] = 0;
			}

			for (i = 0; i < PositionNumber.length; i++) {
				if (ArraySkipPositions[i]) {
					selectWindow("TransmittedVirtual_" + PositionNumber[i]);
					close();
				} else {
					drawROI("TransmittedVirtual_" + PositionNumber[i]);
				}
			}
		}

		// koppie-peest gedaan van bovenstaande, om zelfde mogelijk te maken voor posities met maar 1 of 2 z-planes
		if (minNofSlices < 3) {
			Dialog.create("Exclude positions?");
				Dialog.addMessage(" Which ones would you like to exclude from analysis ? ");
				for (i = 0; i < PositionNumber.length; i++) {
					Dialog.setInsets(0, 40, 0);
					Dialog.addCheckbox("Pos#" + i + " --> only " + ArraynSlices[i] + " z-plane(s)", 0);
				}
				Dialog.addMessage(" ");
				Dialog.addCheckbox(" Ignore this and keep ALL postions anyway ", 0);
			Dialog.show();
				for (i = 0; i < PositionNumber.length; i++) {
					Temp = Dialog.getCheckbox();
					if (Temp) {
						ArraySkipPositions[i] = 1;
					}
				}
				KeepAllPositions = Dialog.getCheckbox();

				if (KeepAllPositions) {
					ArraySkipPositions[i] = 0;
				}

			for (i = 0; i < PositionNumber.length; i++) {
				if (ArraySkipPositions[i]) {
					if (isOpen("TransmittedVirtual_" + PositionNumber[i])) {
						selectWindow("TransmittedVirtual_" + PositionNumber[i]);
						close();
					}
				} else {
					drawROI("TransmittedVirtual_" + PositionNumber[i]);
				}
			}
		}

		print("");
		print("ArraySkipPositions : ");
		Array.print(ArraySkipPositions);
		print("");

		//RO232		exclude single timepoints in 1 step or not...

		if (minNofTimePoints < 2) {
			TimeProjectTransm = 0;
		} //RO232	set TimeProjectTransm in the case of only 1 timepoint (to prevent hyperstack error)

		if (TransmittedChannelPresent) {
			LastWindow = PositionNumber[PositionNumber.length - 1];
			if (ArraySkipPositions[PositionNumber.length - 1] == 0) { //RO232
				selectWindow("TransmittedVirtual_" + LastWindow);
				run("Out [-]");
				run("In [+]");
				if (TimeProjectTransm == 0) {
					drawROI("TransmittedVirtual_" + LastWindow);
				}
			} //RO232
		}

		TEMPLastWindow = getTitle(); //Put this in because there sometimes was an error if the image last selected was the first to be processed
		if (TransmittedChannelPresent) {
			//bp
			if (TimeProjectTransm) {
				waitForUser(" Set Zplane in all positions BEFORE clicking OK \n \n (cropping comes later)");
			} else {
				waitForUser(" - Set ROI in all positions \n \n - Set Zplane in all positions \n \n - and then click OK");
			}
		} else {
			if (do_autocrop){
				if(do_autotime && lastframe == 0)		lastframe = detectLastTimepoint();
				autoCrop(minOrgaSize, cropBoundary, lastframe); // function defined by ##DB##
			}
		}

		// bp
		run("Collect Garbage");

		if (TimeProjectTransm) { //bp30

			testWait = 1;
			ms = 20;
			if (testWait) {
				wait(ms);
			}

			nTimesProjected = 0;
			for (p = 0; p < PositionNumber.length; p++) {
				if (ArraySkipPositions[p] == 0) { //bp17
					nTimesProjected = nTimesProjected + 1;
					selectWindow("TransmittedVirtual_" + PositionNumber[p]);
					run("Select None");
					Stack.getPosition(dummy, sliceTemp, dummy);
					if (testWait) {
						wait(ms);
					}
					// function
					TimeProjectionOnTransmitted("TransmittedVirtual_" + PositionNumber[p], sliceTemp);
					if (testWait) {
						wait(ms);
					}
					//
					selectWindow("TransmittedVirtual_" + PositionNumber[p]);
					run("Select None");
					if (testWait) {
						wait(ms);
					}
					getLocationAndSize(xx, yy, RealWidth, dummy);
					PixelWidth = getWidth();
					ZoomVirtual = 90 * (RealWidth / PixelWidth);
					run("Set... ", "zoom=" + ZoomVirtual);
					if (testWait) {
						wait(ms);
					}
					selectWindow("TransmittedVirtual_" + PositionNumber[p] + "_Time-Projected");
					getLocationAndSize(dummy, dummy, WidthProj, dummy);
					if (testWait) {
						wait(ms);
					}
					ZoomProjected = RealWidth / WidthProj;
					setLocation(xx + 20, yy - 30);
					run("Set... ", "zoom=" + ZoomProjected * 90);
					if (testWait) {
						wait(ms);
					}
				}

				DoingOtherTests = 0;

				if (nTimesProjected == GarbageEverynTimes) {
					nTimesProjected = 0;
					if (DoingOtherTests == 0) {
						run("Collect Garbage");
					}
				}

			}
			waitForUser("Define ROIs for all positions \n \n (draw either in the time-projected images OR in the Virtual stacks (behind) )");

			for (p = 0; p < PositionNumber.length; p++) {
				if (ArraySkipPositions[p] == 0) { //bp17
					run("ROI Manager...");
					roiManager("reset");
					ProjSelection = 1;
					VirtualStackSelection = 1;
					selectWindow("TransmittedVirtual_" + PositionNumber[p] + "_Time-Projected");
					if (selectionType == -1) {
						ProjSelection = 0;
					} else {
						getSelectionBounds(dummy, dummy, TempWidth, TempHeight);
						ProjSurface = TempWidth * TempHeight;
					}
					selectWindow("TransmittedVirtual_" + PositionNumber[p]);
					if (selectionType == -1) {
						VirtualStackSelection = 0;
					} else {
						getSelectionBounds(dummy, dummy, TempWidth, TempHeight);
						VirtualSurface = TempWidth * TempHeight;
					}

					if (ProjSelection + VirtualStackSelection == 0) {
						selectWindow("TransmittedVirtual_" + PositionNumber[p]);
						run("Select All");
					}
					if (ProjSelection + VirtualStackSelection == 2) {
						if (ProjSurface < VirtualSurface) {
							SwapSelectionToVirtualTransm();
						}
						if (ProjSurface > VirtualSurface) {
							print("do nothing, because it'll be allright anyway");
						}
					}
					if (ProjSelection > VirtualStackSelection) {
						SwapSelectionToVirtualTransm();
					}
					if (VirtualStackSelection > ProjSelection) {
						print("do nothing, because it'll be allright anyway");
					}
					// in all cases
					selectWindow("TransmittedVirtual_" + PositionNumber[p] + "_Time-Projected");
					close();
				}
			}
		}
		run("Collect Garbage");

		//================================================ Now we get the settings from the Transmitted==================================================
		selectWindow(TEMPLastWindow);
		for (i = 0; i < PositionNumber.length; i++) {
			if (ArraySkipPositions[i] == 0) { //bp17
				if (TransmittedChannelPresent) {
					transmHyperstack = "TransmittedVirtual_" + PositionNumber[i];
				} else { // beetje nep natuurlijk, maar gewoon om mogelijk te maken dat we de ROI-coordinaten uitlezen
					if (tiffFile) {
						transmHyperstack = TiffName;
					}
					if (nd2File) {
						transmHyperstack = nd2Name;
					}
					if (tiffFile == 0 && nd2File == 0) {
						transmHyperstack = filename + " - " + PositionName[i] + " - C=0";
					}
				}
				//The above part has been added to be able to work without a transmitted stack (calling the first channel transmHyperstack for historical reasons)
				selectWindow(transmHyperstack);
				Stack.getPosition(channel, slice, frame);
				selectWindow(transmHyperstack); // First check whether there was a selection at all; if not --> Select All					
				getSelectionBounds(x, y, Width, Height);
				TotalSurfaceSelection = Width * Height;
				getDimensions(x, y, ch, z, t);
				TotalSurfaceImage = x * y;
				if (TotalSurfaceSelection < TotalSurfaceImage) {
					ErWasEenSelectie = 1; // onderstaande is om te voorkomen dat je per ongeluk een heel klein selectietje maakt, als je alleen een Window wil selecteren
					if (TotalSurfaceSelection < (0.05 * TotalSurfaceImage)) {
						run("Select All");
						print("TotalSurfaceSelection < (0.05 * TotalSurfaceImage) !!!!!!!!!!! ");
					}
				} else {
					ErWasEenSelectie = 0;
					run("Select All");
				}
				getSelectionBounds(ROIx1, ROIy1, ROIx2, ROIy2); //Here we determine the Selection for cropping

				SelectionX1[i] = ROIx1;
				SelectionX2[i] = ROIx2;
				SelectionY1[i] = ROIy1;
				SelectionY2[i] = ROIy2;
				TransmittedZslice[i] = slice;
				Trans = TransmittedChannelNumber[i];
			}
		}

		if (TransmittedChannelPresent) {
			FirstPos = 0; //bp
			for (a = 0; a < PositionNumber.length; a++) {
				if (ArraySkipPositions[a] == 0) { //bp17
					FirstPos = FirstPos + 1;
					transmHyperstack = "TransmittedVirtual_" + PositionNumber[a];
					selectWindow(transmHyperstack);
					DoSetZ = 0;
					SetTransmittedBrightness(transmHyperstack);
					wait(250); //bp want er kunnen fouten insluipen als er veel positions zijn.... (iets met adjust bla bla)
					if (FirstPos == 1) {
						TitleOfFirstPosition = getTitle();
					}
					run("Select None"); //bp15
				}
			}
			run("Collect Garbage"); //bp
			selectWindow(TitleOfFirstPosition);
			getLocationAndSize(XFirstPos, YFirstPos, WidthFirstPos, HeightFirstPos);
			selectWindow("B&C");

			waitForUser("Set B&C for each position");
			for (a = 0; a < PositionNumber.length; a++) {
				if (ArraySkipPositions[a] == 0) { //bp17
					transmHyperstack = "TransmittedVirtual_" + PositionNumber[a];
					selectWindow(transmHyperstack);
					run("Brightness/Contrast...");
					getMinAndMax(min, max);
					print(min + ", " + max);

					List.set("LUT_Min_" + a + "_" + Trans, min);
					List.set("LUT_Max_" + a + "_" + Trans, max); //RO Cleaning	can not remove as this requires a double array like structure (both channel and position vary)		
				}
			}
		}
		//================================================ Now we have the settings from the Transmitted==================================================

		//NORMAL, CHECK LAST TIMEPOINT BLACK	
		//Lets check whether the last image is black! and determine what the last timepoint is
		//Lets check whether the last image is black! and determine what the last timepoint is
		for (i = 0; i < PositionNumber.length; i++) {
			test = 0;
			DoDummy = 1;
			testWait = 1;
			ms = 30;

			if (ArraySkipPositions[i] == 0) { //bp17
				if (TransmittedChannelPresent) {
					transmHyperstack = "TransmittedVirtual_" + PositionNumber[i];
				} else {
					if (tiffFile) {
						transmHyperstack = TiffName;
					}
					if (nd2File) {
						transmHyperstack = nd2Name;
					}
					if (tiffFile == 0 && nd2File == 0) {
						transmHyperstack = filename + " - " + PositionName[i] + " - C=0";
					}
				}
				selectWindow(transmHyperstack);
				if (testWait) {
					wait(ms);
				}
				Singletimepoint[i] = 2;
				if (testWait) {
					wait(ms);
				}
				Stack.getPosition(channel, slice, frame);
				if (testWait) {
					wait(ms);
				}
				getDimensions(dummy, dummy, dummy, LastSlice, NumberOfFrames);
				if (testWait) {
					wait(ms);
				}
				if (NumberOfFrames < 2) {
					Singletimepoint[i] = 1;
				}
				if (testWait) {
					wait(ms);
				}
				run("Measure");
				if (testWait) {
					wait(ms);
				}
				NumberOfTimepoints[i] = NumberOfFrames;
				if (testWait) {
					wait(ms);
				}
				if (test) {
					waitForUser("_NU BIJNA MIS?__");
				}
				Stack.setPosition(channel, LastSlice, NumberOfTimepoints[i]);
				if (testWait) {
					wait(ms);
				}
				if (test) {
					waitForUser("_NU net MISgegaan?__");
				}
				run("Measure");
				GreyLastImage = getResult("Mean", nResults - 1);
				if (testWait) {
					wait(ms);
				}
				LastImageBlack = 0;
				if (testWait) {
					wait(ms);
				}
				if (GreyLastImage == 0) {
					LastImageBlack = 1;
				}
				print("GreyLastImage " + GreyLastImage);
				print("1e LastImageBlack " + LastImageBlack);
				while (GreyLastImage == 0) {
					LastTimepointTemp = NumberOfTimepoints[i] - LastImageBlack;
					if (testWait) {
						wait(ms);
					}
					Stack.setPosition(channel, LastSlice, LastTimepointTemp);
					if (testWait) {
						wait(ms);
					}
					run("Measure");
					GreyLastImage = getResult("Mean", nResults - 1);
					if (GreyLastImage == 0) {
						LastImageBlack = LastImageBlack + 1;
					}
					print("GreyLastImage " + GreyLastImage);
					print("2e LastImageBlack " + LastImageBlack);
				}

				LastTimepointBlack[i] = LastImageBlack;

				if (SetLastTimepoint) {
					if (testWait) {
						wait(ms);
					}
					NumberOfTimepoints[i] = NumberOfTimepoints[i] - LastTimepointBlack[i];
					if (testWait) {
						wait(ms);
					}
					if (test) {
						waitForUser(i + "_1__LastSlice (= echte hoogte)" + LastSlice + "_slice___" + slice + "_NumberOfTimepoints[i]_" + NumberOfTimepoints[i]);
					}
					print("test SetLastTimepoint 1");
					Stack.setPosition(1, TransmittedZslice[i], NumberOfTimepoints[i]);
					if (testWait) {
						wait(ms);
					}
					if (test) {
						waitForUser("_2_TransmittedZslice[i]__" + TransmittedZslice[i]);
					}
					print("test SetLastTimepoint 2");

					FillFractionX = 0.6;
					FillFractionY = 0.6;
					selectWindow(transmHyperstack);
					run("Select None");
					getLocationAndSize(x0, y0, W, H);
					setLocation(1, 1);
					run("View 100%");
					Continue = 1;
					if (testWait) {
						wait(ms);
					}
					while (Continue) {
						if (W > FillFractionX * screenWidth || H > FillFractionY * screenHeight) {
							Continue = 0;
						} else {
							run("In [+]");
						}
						getLocationAndSize(dummy, dummy, W, H);
					}
					if (testWait) {
						wait(ms);
					}
					if(do_autotime){
						 if (lastframe == 0){
						 	lastframe = detectLastTimepoint();
						 } else{
						 	Stack.getDimensions(width, height, channels, slices, frames);
						 	Stack.setPosition(channels, slices, lastframe);
						 }
					}
					
					if (testWait) {
						wait(ms);
					}
					if (test) {
						waitForUser("_3_slice__" + slice);
					}
					print("test SetLastTimepoint 3");
					if (testWait) {
						wait(ms);
					}
					if (DoDummy) {
						Stack.getPosition(dummy, dummy, frame);
					} else {
						Stack.getPosition(channel, slice, frame);
					}
					setLocation(x0, y0, W, H);
					if (test) {
						waitForUser("_4__slice_" + slice);
					}
					print("test SetLastTimepoint 4");
					NumberOfTimepoints[i] = frame;
					LastTimepointBlack[i] = 0;
					if (testWait) {
						wait(ms);
					}
				}
				close(transmHyperstack);
			}
		}
		selectWindow("Results");
		run("Close");

		//================================== Dialog box with option to remove the last timepoint (is already switched on if detected as black!)==============

		PositionNumberTemp = newArray(PositionNumber.length);
		for (i = 0; i < PositionNumber.length; i++) {
			PositionNumberTemp[i] = toString(PositionNumber[i], 0);
		}

		if (SetLastTimepoint) {} else {
			if (CheckLastTimepointBlack) {
				Dialog.create("Remove Last Timepoints?");
					Dialog.setInsets(10, 20, 0)
					Dialog.addMessage("The number indicates the amount of timepoints");
					Dialog.setInsets(0, 20, 20)
					Dialog.addMessage("that are black according to the macro!");
					Dialog.setInsets(0, 0, 0)
					Dialog.addMessage("Remove timepoints? Position");
					for (i = 0; i < AmountOfPositions; i++) {
						Dialog.setInsets(0, 40, 5)
						Dialog.addNumber(PositionNumberTemp[i], LastTimepointBlack[i]);
					}
				Dialog.show();
					for (i = 0; i < PositionNumber.length; i++) {
						LastTimepointBlack[i] = Dialog.getNumber();
						//RO Cleaning	List.set("LastTimepointBlack"+i,LastTimepointBlack[i]);//List.set("Singletimepoint"+i,Singletimepoint[i]);
						NumberOfTimepoints[i] = NumberOfTimepoints[i] - LastTimepointBlack[i];
						//RO Cleaning	List.set("NumberOfTimepoints"+i,NumberOfTimepoints[i]);
					}
			} else {
				for (i = 0; i < PositionNumber.length; i++) {
					NumberOfTimepoints[i] = NumberOfTimepoints[i] - LastTimepointBlack[i];
					//RO Cleaning	List.set("NumberOfTimepoints"+i,NumberOfTimepoints[i]);
				}
			}
		}
		Array.getStatistics(NumberOfTimepoints, MinNumberOfTimepoints, dummy, dummy, dummy);

		if (MinNumberOfTimepoints == 1) {
			items = newArray("As normal, output is a single jpg", "Switch t for z, output is an avi going through slices"); //RO232 correct spelling 
			Dialog.create("There is only 1 timepoint!");
				Dialog.setInsets(10, 20, 0)
				Dialog.addMessage("There is only 1 timepoint in at least 1 position");
				Dialog.addRadioButtonGroup("Chose how to process z stacks", items, 2, 1, items[1]); //RO232 
			Dialog.show();
				OutcomeSingleTPtoZstack = Dialog.getRadioButton();
				if (OutcomeSingleTPtoZstack == items[1]) SingleTPtoZstack = 1;
			print("SingleTPtoZstack :" + SingleTPtoZstack);
		}

		wait(300);

	} // <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< RESTART END >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

	// =========================================That was the ROI, LastTimepointBlack (Zslice and B&C)! Now we turn our attention to the other channels!========================================
	// =========================================That was the ROI, LastTimepointBlack (Zslice and B&C)! Now we turn our attention to the other channels!========================================

	ResolutionArray = newArray(100);

	if (Restart) {} else { // <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< RESTART BEGIN/ELSE >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		//NORMAL, MAKE TEMPORARY WINDOWS FOR B&C NON-TRANSMITTED CHANNELS
		print("4e test ");
		FirstPos = 0; //bp
		Duration = 1.3; //bp37  ##DB## duration from initiating macro
		for (i = StartFromi; i < PositionNumber.length; i++) {
			if (ArraySkipPositions[i] == 0) { //bp17
				if (tiffFile) {
					run("Bio-Formats Importer", "open=[" + file + "] color_mode=Default split_channels view=Hyperstack stack_order=XYCZT use_virtual_stack");
					setLocation(1,1);
				} else {
					run("Bio-Formats", "open=[" + file + "] color_mode=Default split_channels view=Hyperstack stack_order=XYCZT use_virtual_stack series_" + (PositionNumber[i]));
					print("biof2 - CURRENT TIME -", makeDateOrTimeString("time"));
					setLocation(1,1);
				}
				getDimensions(width, height, channels, slices, frames);
				// for scalebar later
				if (tiffFile == 0) {
					ImageInfoString = getImageInfo();
					print(ImageInfoString);
					StartIndex = indexOf(ImageInfoString, "Resolution:") + 13;
					print("");
					print("StartIndex : " + StartIndex);
					print("");
					RestOfImageInfo = substring(ImageInfoString, StartIndex);
					EndIndex = indexOf(RestOfImageInfo, "pixels per ") - 1;
					ResolutionString = substring(RestOfImageInfo, 0, EndIndex);
					print("");
					print("ResolutionString : " + ResolutionString);
					print("");
					Resolution = parseFloat(ResolutionString);
					print("");
					print("Resolution * 2 : " + 2 * Resolution);
					print("");
					MicronPerPixel = 1 / Resolution; // want staat geschreven in pixels/micron
					ResolutionArray[i] = Resolution; 

					StartIndexX = indexOf(ImageInfoString, "Voxel size:") + 13;
					StartIndexY = indexOf(ImageInfoString, "x", StartIndexX) + 2;
					StartIndexZ = indexOf(ImageInfoString, "x", StartIndexY) + 1;
					EndIndexZ = indexOf(ImageInfoString, "micron", StartIndexZ) - 1;
					ZResolution = parseFloat(substring(ImageInfoString, StartIndexZ, EndIndexZ));
					print("ZResolution: " + ZResolution);
					print("ZResolution/3: " + ZResolution / 3);
					ZRange = ZResolution * slices;
					print("ZRange: " + ZRange);

					ArrayZResolution[i] = ZResolution; //RO corrected mistake in range!
				}
				if (tiffFile) {
					Resolution = 200;
					ZResolution = 1;
					ArrayZResolution[i] = ZResolution;
					ZRange = ZResolution * slices;
				}

				//
				LastTimepointTemp = parseFloat(NumberOfTimepoints[i]);
				FirstPos = FirstPos + 1; //bp
				//For calculations we need to use actual numbers, parseFloat converts the string to a number
				ROIx1 = SelectionX1[i];
				ROIx2 = SelectionX2[i];
				ROIy1 = SelectionY1[i];
				ROIy2 = SelectionY2[i];
				if (tiffFile) {
					rename(TiffName);
				}
				TempTitle = getTitle();
				if (tiffFile == 0) {
					TempTitle = substring(TempTitle, 0, lengthOf(TempTitle) - 1);
				}

				if (TransmittedChannelPresent) {
					for (j = PositionChannelAmount[i] - 1; j >= 0; j--) {
						c = j;
						selectWindow(TempTitle + c);
						rename("Temp_" + ChannelName[c]);
						setBatchMode(false);
						run("Put Behind [tab]");
					}
				} else { //Close the transmitted!
					for (j = PositionChannelAmount[i] - 1; j >= 0; j--) {
						c = j;
						if (tiffFile == 0) {
							// selectWindow(TempTitle + c);	// ##DB##
						}
						if (tiffFile == 1) {
							selectWindow(TempTitle);
						}
						rename("Temp_" + ChannelName[c]);
						print("ok?");
						setBatchMode(false);
						run("Put Behind [tab]");
					}
				}
				print("5.5e test "); //Need these variables for the CropToROI
				FloatT = LastTimepointTemp / NumberOfTPTempStacks;
				FloorT = floor(LastTimepointTemp / NumberOfTPTempStacks);
				if (FloorT == FloatT) {
					JumpT = FloorT;
				} else {
					JumpT = FloorT + 1;
				}
				//if(JumpT<1)JumpT=1;	
				print("JumpT = " + JumpT);
				FloatZ = slices / NumberOfZsTempStacks;
				FloorZ = floor(slices / NumberOfZsTempStacks);
				if (FloorZ == FloatZ) {
					JumpZ = FloorZ;
				} else {
					JumpZ = FloorZ + 1;
				}

				if (DeleteZStacks) JumpZ = 1;
				print("JumpZ = " + JumpZ); // This is to make sure that all Z stackes are included (you need that to be able to properly select the first/last Z)

				one = 0; //Now we make the temp windows for setting B&C etc.
				print("6e test ");
				for (j = 0; j < PositionChannelAmount[i]; j++) {
					c = j;
					if (PauseAfterSettings) {
						wait(1000);
					}
					selectWindow("Temp_" + ChannelName[c]);

					if (TransmittedChannelNumber[i] == c) {
						UseChannel[c] = 0;
					}
					if (UseChannel[c]) {
						one = one + 1;
						setBatchMode(Hidewindows);
						rename(PositionNumber[i] + "_" + ChannelName[c]);
						Title = getTitle();
						print("1.6");
						if (Singletimepoint[i] == 1) {
							print("Singletimepoint!");
							ReOrder = 0;
							print("2");
							DuplicateSingleTimepoint(Title, ChannelColour[c]);
							selectWindow(Title);
							rename(Title + "_Temp");
							Temp_Title = Title + "_Temp";
						} else {
							Temp_Title = splitTimepointTemp(Title, JumpT, JumpZ, 1);
						} // adapted function to include increment, reduction and merge Title, JumpT, JumpZ, Reduce? output=rename("Temp_"+Title);
						selectWindow(Temp_Title);
						run("glow");
						getDimensions(dummy, dummy, dummy, ZSLICE, TIMEPOINTS);
						print("ZSLICE " + ZSLICE + " TIMEPOINTS " + TIMEPOINTS);
						if (Singletimepoint[i] != 1) {
							selectWindow(Title);
							close(Title);
						}
						if (DeleteZStacks && one == 1) {
							Zselection_Title = splitZplaneTemp(Temp_Title, 1); // Makes a projection in time for each n-th timepoint output=ename("Zselection"+Title);
							selectWindow(Temp_Title);
							run("Hyperstack to Stack");
							selectWindow(Zselection_Title);
							run("Hyperstack to Stack");
							run("Combine...", "stack1=[" + Temp_Title + "] stack2=[" + Zselection_Title + "]");
							rename(Title + "_Temp");
							run("Stack to Hyperstack...", "order=xyczt(default) channels=1 slices=" + ZSLICE + " frames=" + TIMEPOINTS + " display=Color");
						}
						setBatchMode(false);
						selectWindow(Temp_Title);
						print("3");
						run("glow");
						getDimensions(dummy, dummy, dummy, ZSLICE, TIMEPOINTS);
						ZlevelOfHighestIntensity(Title + "_Temp");
						run("Enhance Contrast", "saturated=" + GreenEnhanceContrastSaturationFactor);
						getMinAndMax(min, max);
						min = FluoOffset;
						setMinAndMax(min, max);
						print("4");

					} else {
						close();
					}
				}
				print("5");
				if (FirstPos == 1) {
					TitleOfFirstPosition = getTitle();
				}

				// only calculate scalebar parameters
				selectWindow(Title + "_Temp");
				HeightTemp = getHeight();
				WidthTemp = getWidth(); //	a=1;	if(a && i==0){FractionForBar = 0.04;}		if(a && i==1){FractionForBar = 0.15;}	if(a && i==2){FractionForBar = 0.6;}
				ScaleBarArray = newArray(1, 2, 5, 7.5, 10, 15, 20, 25, 40, 50, 60, 75, 100, 125, 150, 200, 250, 500, 750, 1000, 1500, 2000); /// in microns
				Resolution = ResolutionArray[i];
				Continue = 1;
				Test = ScaleBarArray.length - 1;
				while (Continue) { // calculate number of pixels for each tested scalebar
					PixelsTestBar = round(ScaleBarArray[Test] * Resolution); // micron * (pixels/micron) = pixels
					if (PixelsTestBar < round(0.5 * FractionForBar * WidthTemp)) {
						nPixelsScaleBar = PixelsTestBar;
						nMicronsScaleBar = ScaleBarArray[Test];
						Continue = 0;
					}
					Test = Test - 1;
				}
				ScaleBarY = HeightTemp - MarginForScaleBar - ScaleBarLineWidth;
				print("5");

				ScaleBarYArray[i] = ScaleBarY;
				nPixelsScaleBarArray[i] = nPixelsScaleBar;
				nMicronsScaleBarArray[i] = nMicronsScaleBar;

			}
		} // van de for(i=StartFromi
		print("7e test ");

		run("Tile");
		run("Brightness/Contrast...");
		selectWindow(TitleOfFirstPosition);
		getLocationAndSize(XFirstPos, YFirstPos, WidthFirstPos, HeightFirstPos);
		print("6");
		selectWindow("B&C");
	   
		WhiteScreenDimension = 0.89;

		if (RedDeadDye == 0) {
			if (NumberOfChannelsToBeProcessed > 2) {
				GuidedBC = 0;
			}

			if (GuidedBC == 0) {
				selectWindow("B&C");
				resetMinAndMax();
			}
			if (GuidedBC) {
				run("Cascade");
				selectWindow(TitleOfFirstPosition);
				StringFirst = getTitle();
				IndexRest = indexOf(TitleOfFirstPosition, "_");
				Bulk = substring(StringFirst, IndexRest);
				WhiteScreen = Date + " " + NameExperiment;
				newImage(WhiteScreen, "8-bit white", WhiteScreenDimension * screenWidth, WhiteScreenDimension * screenHeight, 1);
				setLocation(1, 1);
				Counter = 0;
				minTemp = FluoOffset;
				for (w = 0; w < PositionNumber.length; w++) {
					if (ArraySkipPositions[w] == 0) { //bp17

						selectWindow(PositionNumber[w] + "_" + ChannelName[0] + "_Temp");
						getMinAndMax(dummy, max);
						min = FluoOffset;
						setMinAndMax(min, max); //bp43
						oldX = newArray(PositionChannelAmount[w]);
						oldY = newArray(PositionChannelAmount[w]);
						oldWidth = newArray(PositionChannelAmount[w]);
						oldHeight = newArray(PositionChannelAmount[w]);
						WidthTemp = newArray(PositionChannelAmount[w]);
						HeightTemp = newArray(PositionChannelAmount[w]);
						oldZoom = newArray(PositionChannelAmount[w]);
						MarginBC = 200;
						selectWindow(WhiteScreen);
						for (c = 0; c < PositionChannelAmount[w]; c++) {
							place = c + 1;
							if (UseChannel[c]) {
								selectWindow(PositionNumber[w] + "_" + ChannelName[c] + "_Temp");
								CurrentImage = getTitle();
								getLocationAndSize(oldX[c], oldY[c], oldWidth[c], oldHeight[c]);
								setLocation(1, 1);
								run("Select None");
								run("View 100%");
								WidthTemp[c] = getWidth();
								HeightTemp[c] = getHeight();
								oldZoom[c] = getZoom();
								//RO2 moved the setLocation in front of setting the zoom, this might prevent the last window giving the weird zoom artefact
								Continue = 1;
								while (Continue) {
									getLocationAndSize(dummy, dummy, testWidth, testHeight);
									if (testWidth < 0.45 * screenWidth && testHeight < 0.7 * screenHeight / (PositionChannelAmount[w] + 1)) {
										run("In [+]");
									} else {
										Continue = 0;
									}
								}
								
								setLocation(screenWidth - testWidth - MarginBC, screenHeight - (testHeight * place) - MarginBC);
								getLocationAndSize(testX, testY, testWidth, testHeight);
								selectWindow("B&C");
							}
						}

						if (minTemp != FluoOffset) {
							Dialog.create(" ");
								Dialog.addCheckbox("Change Fluo Offset for all next positions?", 1);
								Dialog.addNumber("New Fluo Offset ", minTemp);
							Dialog.show();
								ChangeFluoOffset = Dialog.getCheckbox();
								NewOffset = Dialog.getNumber();

							if (ChangeFluoOffset) {
								FluoOffset = NewOffset;
							} else {
								minTemp = FluoOffset;
							}
							selectWindow(CurrentImage);
							setMinAndMax(minTemp, max);
							selectWindow("B&C");
						} //bp43

						// set B&C properly
						resetMinAndMax();
						if (do_autoBC){
							getMinAndMax(min,MaxBC);
							setAutoThreshold(BC_thresh_meth);
							getThreshold(min,maxT);
							setMinAndMax(maxT,MaxBC * maxBrightnessFactor);
						}
						//waitForUser("Set B&C for position " + w + 1 + " (of " + PositionNumber.length + ")"); //bp14 //RO2	// !!##DB test ABC

						for (c = 0; c < PositionChannelAmount[w]; c++) {
							if (UseChannel[c]) {
								selectWindow(PositionNumber[w] + "_" + ChannelName[c] + "_Temp");
								getMinAndMax(minTemp, dummy);
								run("Set... ", "zoom=" + oldZoom[c] * 100);
								setLocation(oldX[c], oldY[c]);
							}
						}
					}
				}
				selectWindow(WhiteScreen);
				close();
				run("Tile");
			}
		}

		if (RedDeadDye) {
			for (i = StartFromi; i < PositionNumber.length; i++) {
				if (ArraySkipPositions[i] == 0) { //bp17
					selectWindow(PositionNumber[i] + "_" + ChannelName[DeadChannel] + "_Temp");
					run("Threshold...");
					setAutoThreshold("Default dark");
				}
			}
			selectWindow("B&C");
			waitForUser("set B&C for nuclei & Threshold for DeadDye channels BEFORE clicking OK");
		}
		if (RedDeadDye) {
			for (i = StartFromi; i < PositionNumber.length; i++) {
				if (ArraySkipPositions[i] == 0) { //bp17
					selectWindow(PositionNumber[i] + "_" + ChannelName[DeadChannel] + "_Temp");
					Title = getTitle();
					getThreshold(cutoff, upper);
					Threshold[i] = cutoff;
					close(Title);
				}
			}
			selectWindow("Threshold");
			run("Close");
		}

		//Here the macro waits until the user clicks OK
		//NORMAL, DELETE Z-planes, CREATE 2 WINDOWS
		DepthChannel = newArray;
		for (i = StartFromi; i < PositionNumber.length; i++) {
			if (ArraySkipPositions[i] == 0) { //bp17
				one = 0;
				for (j = 0; j < PositionChannelAmount[i]; j++) {
					c = j;
					if (DeadChannel != j) {
						if (UseChannel[c]) {
							selectWindow(PositionNumber[i] + "_" + ChannelName[c] + "_Temp");
							Title = getTitle();
							one = one + 1;
							getMinAndMax(min, max);
							if (max != 255 || min != 0) {} else {
								min = FluoOffset;
								max = 254;
							} // mijn favoriete ofset : FluoOffset = 4

							List.set("LUT_Min_" + i + "_" + c, min);
							List.set("LUT_Max_" + i + "_" + c, max); //RO Cleaning, can not move this to end as it is a 'double array' like structure

							selectWindow(Title);
							run("Select None");
							if (DeleteZStacks == 0 || one != 1) {
								close();
							} // Closes the temp hyperstacks when deletestacks=0 (don't need to set stacks) OR not the channel we want
							if (DeleteZStacks == 1 && one == 1) {
								rename(PositionNumber[i] + "_Z_Lowest");
								DepthChannel[i] = c;
							}
						}
					}
				}
			}
		}
		//NORMAL, DELETE Z-planes, GET TOP AND BOTTOM
		AlreadyShown = 0; //RO232 Prevents error when running without depthcoding, DeleteZStacks
		if (DeleteZStacks) { // DeleteZslices!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
			BottomZ = newArray;
			TopZ = newArray; //bp21 eigenlijk raar dat die hier staat, want wodt steeds overschreven ; en gaat dus goed omdat de gegevens in de list terecht komen en daarvanuit gebruikt worden...

			BottomZ_1 = newArray;
			TopZ_1 = newArray; //bp21
			BottomZ_2 = newArray;
			TopZ_2 = newArray; //bp21
			BottomZ_3 = newArray;
			TopZ_3 = newArray; //bp21

			GammaCorr_1 = newArray;
			MultiplyBeforeDepthcoding_1 = newArray; //bp21
			GammaCorr_2 = newArray;
			MultiplyBeforeDepthcoding_2 = newArray; //bp21
			GammaCorr_3 = newArray;
			MultiplyBeforeDepthcoding_3 = newArray; //bp21

			if (i == StartFromi) {
				run("Cascade");
			}
			One = 1;
			GammaCorrFix = GammaCorr[0];
			MultiplyFix = MultiplyBeforeDepthcoding[0];
			for (i = StartFromi; i < PositionNumber.length; i++) {
				if (ArraySkipPositions[i] == 0) { //bp17
					WhiteScreen = Date + " " + NameExperiment;
					newImage(WhiteScreen, "8-bit white", WhiteScreenDimension * screenWidth, WhiteScreenDimension * screenHeight, 1);
					setLocation(1, 1);
					StatusWidth = WriteStatus(); //bp12	//bp38
					selectWindow(PositionNumber[i] + "_Z_Lowest");
					getLocationAndSize(xTemp, yTemp, dummy, dummy);
					if (xTemp < StatusWidth) {
						setLocation(1.5 * StatusWidth, yTemp);
					} //bp38
					Stack.setPosition(1, 1, 1);
					run("Select None");
					c = DepthChannel[i];
					min = List.get("LUT_Min_" + i + "_" + c);
					max = List.get("LUT_Max_" + i + "_" + c);
					setMinAndMax(min, max); //bp
					run("Duplicate...", "title=[" + PositionNumber[i] + "_Z_Highest] duplicate");
					getLocationAndSize(xTemp, yTemp, dummy, dummy);
					if (xTemp < StatusWidth) {
						setLocation(1.5 * StatusWidth, yTemp);
					} //bp38
					getDimensions(dummy, dummy, dummy, slices, dummy);
					Stack.setPosition(1, slices, 1);
					run("Set... ", "zoom=100");
					Zoom = getZoom();
					ActualWidthZselect = getWidth();
					ActualHeightZselect = getHeight();
					TotalWidth = (ActualWidthZselect + 35) * 2;
					TotalHeight = (ActualHeightZselect + 85) * 2;
					XZoom = 4;
					YZoom = 4;
					while (YZoom * TotalHeight + 150 > ScreenHeight) {
						YZoom = YZoom * 0.9;
					}
					while (XZoom * TotalWidth + 100 > ScreenWidth) {
						XZoom = XZoom * 0.9;
					}
					Zoom = minOf(XZoom, YZoom);
					NewWidthZselect = ActualWidthZselect * Zoom;
					NewHeightZselect = ActualHeightZselect * Zoom;
					x1 = 0.5 * ScreenWidth - 0.5 * NewWidthZselect;
					y1 = 1;
					y2 = y1 + NewHeightZselect + 85;
					SetZoom = Zoom * 100;
					print("SetZoom: " + SetZoom); //bp12
					selectWindow(WhiteScreen); //bp12
					selectWindow(PositionNumber[i] + "_Z_Highest");
					run("Set... ", "zoom=100");
					setLocation(x1, y2, NewWidthZselect + 100, NewHeightZselect + 100);
					run("Set... ", "zoom=" + SetZoom);
					selectWindow(PositionNumber[i] + "_Z_Lowest");
					run("Set... ", "zoom=100");
					setLocation(x1, y1, NewWidthZselect + 100, NewHeightZselect + 100);
					run("Set... ", "zoom=" + SetZoom);
					//waitForUser("Choose the lowest and highest Zslice to be included \n (in appropriate windows) \n \n (pos " + i + 1 + " of " + PositionNumber.length + ")");
					// ##DB## plug in auto Z-plane detection
					if (do_autoZ) {
						// !!##DB##!! plug in auto Z detector when ready
						print("autoZ not yet implemented");
					}
					selectWindow(PositionNumber[i] + "_Z_Lowest");
					Stack.getPosition(channel, slice, frame);
					BottomZ[i] = slice;
					close();
					OffsetZ = BottomZ[i] - 1;
					selectWindow(PositionNumber[i] + "_Z_Highest");
					Title = getTitle();
					Stack.getPosition(channel, slice, frame);
					TopZ[i] = slice;
					//NORMAL, DELETE Z-planes, GET MULTIPY FACTOR FOR DEPTHCODING

					if (UseDepthcoding == "With") {
						if (SetMultiplyBeforeDepthcoding) {
							c = DepthChannel[i];
							min = List.get("LUT_Min_" + i + "_" + c);
							max = List.get("LUT_Max_" + i + "_" + c);
							setMinAndMax(min, max);
							if (bitDepth() == 8) {
								run("Apply LUT", "stack");
							} else {
								run("8-bit");
							}
							run("Make Substack...", " slices=" + BottomZ[i] + "-" + TopZ[i]);
							rename("SelectedZstack");
							selectWindow(Title);
							close();
							Title = "SelectedZstack";
							selectWindow(Title);
							getLocationAndSize(x0, y0, WidthZselect, HeightZselect);
							Zoom = getZoom(); //bp22		
							// onderstaande regel ; anders kun je de Status niet lezen....
							getLocationAndSize(xTemp, yTemp, dummy, dummy);
							if (xTemp < StatusWidth) {
								setLocation(1.5 * StatusWidth, yTemp);
							} //bp38
							ActualWidthZselect = WidthZselect / Zoom;
							ActualHeightZselect = HeightZselect / Zoom;
							TotalHeight = (HeightZselect + 20);
							TotalWidth = (WidthZselect + 10) * 2;
							//Zoom=1;
							if (WidthZselect > 0.5 * screenWidth) {
								while (Zoom * ActualWidthZselect > 0.5 * ScreenWidth) {
									Zoom = Zoom * 0.9;
								}
							} //bp22
							else {
								while (Zoom * ActualWidthZselect < 0.5 * ScreenWidth) {
									Zoom = Zoom * 1.1;
								}
							}
							NewWidthZselect = ActualWidthZselect * Zoom;
							NewHeightZselect = ActualHeightZselect * Zoom;
							x1 = 1;
							x2 = NewWidthZselect + 10;
							y1 = 0.5 * ScreenHeight - 0.5 * NewHeightZselect;
							SetZoom = Zoom * 100;
							Loop = 1;
							FirstTime = 1;
							if (Singletimepoint[i] != 1) {
								PlayDepth = 1;
							} else {
								PlayDepth = 0;
							} //bp16 //bp30 //bp37
							FixGammaCorr = 0;
							FixMultiply = 0;

							if (GammaCorrFix == GammaCorr[i]) {
								GammaCorrFill = GammaCorr[i];
							} else {
								GammaCorrFill = GammaCorrFix;
							}
							if (MultiplyFix == MultiplyBeforeDepthcoding[i]) {
								MultiplyFill = MultiplyBeforeDepthcoding[i];
							} else {
								MultiplyFill = MultiplyFix;
							}

							while (Loop) {
								Continue = 1; //bp37
								DecideSplitZ = 0;
								while (Continue) { //bp37
									Continue = 0; //bp37
									TestOrContinue = newArray;
									TestOrContinue[0] = "TEST these settings";
									TestOrContinue[1] = "SAVE these settings and CONTINUE";
									Dialog.create("Set Parameters fo Depthcoding"); //bp37
										Dialog.setInsets(0, 0, 0);
										Dialog.addMessage("Position " + i + 1 + " (of " + PositionNumber.length + ")");
										Dialog.setInsets(10, 0, 0);
										Dialog.addMessage("Which Gamma factor? (bring low and high intensies together)");
										Dialog.setInsets(-3, 0, 0);
										Dialog.addMessage("Which Multiply factor? (for depth-coded channel)");
										Dialog.setInsets(0, 0, 0);
										Dialog.addMessage(" ");

										Dialog.setInsets(2, 0, 2);
										Dialog.addNumber("GAMMA Factor", gamma_factor_import, 2, 8, ""); //bpp
										Dialog.setInsets(-29, 310, 0);
										Dialog.addCheckbox("fix", FixGammaCorr);
										Rounded = round(20 * GammaCorrFill);
										a = Rounded / 20;
										aString = d2s(a, 2);
										GammaSteps = newArray(-0.1, -0.05, 0, 0.05, 0.1);
										ProposeGamma = newArray(GammaSteps.length);
										for (c = 0; c < GammaSteps.length; c++) {
											ProposeGamma[c] = d2s(a + GammaSteps[c], 2);
										}
										Dialog.setInsets(0, 120, 0);
										Dialog.addRadioButtonGroup("", ProposeGamma, 1, 5, ProposeGamma[round((GammaSteps.length + 1) / 2) - 1]); //bp40
										Dialog.setInsets(0, 0, 0);
										Dialog.addMessage(" ");

										Dialog.setInsets(2, 0, 2);
										Dialog.addNumber("MULTIPLY Factor", multiply_factor_import, 2, 8, ""); //bpp
										Dialog.setInsets(-29, 310, 0);
										Dialog.addCheckbox("fix", FixMultiply);
										Rounded = round(20 * MultiplyFill);
										b = Rounded / 20;
										bString = d2s(b, 2);
										MultiplySteps = newArray(-0.15, -0.1, -0.05, 0, 0.05, 0.1, 0.15);
										ProposeMultiply = newArray(MultiplySteps.length);
										for (c = 0; c < MultiplySteps.length; c++) {
											ProposeMultiply[c] = d2s(b + MultiplySteps[c], 2);
										}
										Dialog.setInsets(0, 120, 0);
										Dialog.addRadioButtonGroup("", ProposeMultiply, 1, 5, ProposeMultiply[round((MultiplySteps.length + 1) / 2) - 1]); //bp40
										Dialog.setInsets(0, 0, 0);
										Dialog.addMessage(" ");

										Dialog.setInsets(20, 90, 0);
										Dialog.addRadioButtonGroup("Show Depth projection with above settings?", TestOrContinue, 2, 1, TestOrContinue[1]); //BP37
										Dialog.setInsets(0, 0, 0);
										Dialog.addMessage(" ");

										Dialog.setInsets(-130, 414, 0);
										Dialog.addCheckbox("Play (2x)", PlayDepth); //bp16
										Dialog.setInsets(-72, 200, 5);
										Dialog.addNumber("", Duration, 1, 4, "sec"); //bp16 // bp21
										if (FirstTime == 0) {
											Dialog.setInsets(0, 0, 0);
											Dialog.addMessage(" ***********************************************************");
											SlicesInStack = TopZ[i] - BottomZ[i] + 1;
											HeightChosenZStack = SlicesInStack * ArrayZResolution[i]; //bp38
											Dialog.setInsets(3, 100, 0);
											Dialog.addMessage(SlicesInStack + " z-planes ~~ " + HeightChosenZStack + " " + micron); //bp38
											Dialog.setInsets(2, 100, 0);
											Dialog.addCheckbox("Analyze Z-stack in 2 or 3 parts", 0);
										} //bp21		//bp37
									//Dialog.show();
										GammaCorr[i] = Dialog.getNumber();
										FixGammaCorr = Dialog.getCheckbox();
										ProposedGamma = Dialog.getRadioButton();
										if (ProposedGamma != aString) {
											ProposedGamma = parseFloat(ProposedGamma);
											GammaCorr[i] = ProposedGamma;
										}

										MultiplyBeforeDepthcoding[i] = Dialog.getNumber();
										FixMultiply = Dialog.getCheckbox();
										ProposedMultiply = Dialog.getRadioButton();
										if (ProposedMultiply != bString) {
											ProposedMultiply = parseFloat(ProposedMultiply);
											MultiplyBeforeDepthcoding[i] = ProposedMultiply;
										}

										Loop = Dialog.getRadioButton();
										if (Loop == "TEST these settings") {
											Loop = 1;
										} else {
											Loop = 0;
										}
										print("printloop 1: " + Loop);
										GammaCorrFill = GammaCorr[i]; //bp16 opschuiven		
										MultiplyFill = MultiplyBeforeDepthcoding[i];
										PlayDepth = Dialog.getCheckbox(); //bp16
										Duration = Dialog.getNumber();
										if (FirstTime == 0) {
											DecideSplitZ = Dialog.getCheckbox();
										}

									// SplitZ ?? set default settings anyway
									DialogArraySplitZ = newArray;
									DialogArraySplitZ[0] = "Split in 2 parts";
									DialogArraySplitZ[1] = "Split in 3 parts";
									SplitZ[i] = 0; //bp21
									OutputArray = newArray;
									OutputArray[0] = "save as separate movies";
									OutputArray[1] = "merge in one movie";
									// hereby we set the default
									FillOutputArray = OutputArray[1]; // = merge in one movie
									PileUpChunks[i] = 1; //bp40

									if (DecideSplitZ) {
										Dialog.create("Split Z-stack"); //bp37
											Dialog.setInsets(0, 10, 0);
											Dialog.addMessage(SlicesInStack + " z-planes ~~ " + HeightChosenZStack + " " + micron); //bp38
											Dialog.setInsets(20, 10, 0);
											Dialog.addRadioButtonGroup("", DialogArraySplitZ, 2, 1, DialogArraySplitZ[0]);
											Dialog.setInsets(0, 0, 0);
											Dialog.addMessage(" ");
											Dialog.setInsets(0, 10, 0);
											Dialog.addRadioButtonGroup("... and the output of these partial analyses ? ", OutputArray, 2, 1, FillOutputArray); //bp40
											Dialog.setInsets(30, 20, 0);
											Dialog.addCheckbox("Process BOTH split AND unsplit", SplitAndUnsplitFill); // BP101 niet goed
										Dialog.show();
											ButtonZSplit = Dialog.getRadioButton(); ///bp21
											if (ButtonZSplit == DialogArraySplitZ[0]) {
												nChunks = 2;
												SplitZ[i] = 2;
											} // dus > 0 wil zeggen dat er gechopt wordt en het echte getal zegt in hoeveel delen 
											if (ButtonZSplit == DialogArraySplitZ[1]) {
												nChunks = 3;
												SplitZ[i] = 3;
											}
											OutputButton = Dialog.getRadioButton(); //bp37 en hieronder
											if (OutputButton == OutputArray[0]) {
												PileUpChunks[i] = 0;
											}
											if (OutputButton == OutputArray[1]) {
												PileUpChunks[i] = 1;
											}
											SplitAndUnsplit[i] = Dialog.getCheckbox();
											SplitAndUnsplitFill = SplitAndUnsplit[i]; //bp40
									} // vd if(DecideSplitZ
								} // vd while continue 

								////
								if (FirstTime == 0) {
									selectWindow("Depth" + Title);
									close();
								}
								if (Loop && SplitZ[i] == 0) { //bp21
									selectWindow(Title);
									run("Select None");
									run("Duplicate...", "title=[" + Title + "_temp] duplicate");
									selectWindow(Title + "_temp");
									getLocationAndSize(xTemp, yTemp, dummy, dummy);
									if (xTemp < StatusWidth) {
										setLocation(1.5 * StatusWidth, yTemp);
									} //bp38
									run("Gamma...", "value=" + GammaCorr[i] + " stack");
									run("Re-order Hyperstack ...", "channels=[Channels (c)] slices=[Frames (t)] frames=[Slices (z)]");
									getLocationAndSize(xTemp, yTemp, dummy, dummy);
									if (xTemp < StatusWidth) {
										setLocation(1.5 * StatusWidth, yTemp);
									} //bp38

									run("Multiply...", "value=" + MultiplyBeforeDepthcoding[i] + " stack");
									run("Temporal-Color Code", "lut=[Depth Organoid]");
									rename("Depth" + Title);
									selectWindow(Title + "_temp");
									close();

									//bp14
									selectWindow(Title);
									setLocation(1, 1);
									run("View 100%");
									getLocationAndSize(dummy, dummy, TempWidth, TempHeight);
									selectWindow("Depth" + Title);
									setLocation(1, 1);
									run("View 100%");
									while (TempWidth > 0.5 * screenWidth) {
										selectWindow("Depth" + Title);
										run("Out [-]");
										selectWindow(Title);
										run("Out [-]");
										getLocationAndSize(dummy, dummy, TempWidth, TempHeight);
										SetZoom = getZoom();
									}
									while (TempWidth < 0.5 * screenWidth) {
										selectWindow("Depth" + Title);
										run("In [+]");
										selectWindow(Title);
										run("In [+]");
										getLocationAndSize(dummy, dummy, TempWidth, TempHeight);
										SetZoom = getZoom();
									}
									selectWindow(Title);
									setLocation(0.5 * screenWidth - 0.5 * TempWidth, 0.5 * screenHeight - 0.5 * TempHeight);
									selectWindow("Depth" + Title);
									setLocation(0.5 * screenWidth - 0.5 * TempWidth, 0.5 * screenHeight - 0.5 * TempHeight);
									selectWindow(WhiteScreen);

									// play movie twice
									if (PlayDepth) { //bp16								
										FrameRate = 2 * NumberOfTPTempStacks / (Duration); // in fps 	// so, plays it twice
										wait(80);
										selectWindow("Depth" + Title);
										wait(80);
										setSlice(1);
										run("Animation Options...", "speed=" + FrameRate);
										doCommand("Start Animation [\\]");
										wait(Duration * 1000);
										run("Stop Animation");
										setSlice(1);
									} else {
										selectWindow("Depth" + Title);
										setSlice(1);
									} //RO 0804

									waitForUser("Check out the depthcoding!");
									FirstTime = 0;
								} // vd if(Loop
								if (SplitZ[i] > 0) {
									Loop = 0;
								}
							} // vd while(loop

							if (SplitZ[i] == 0) {
								selectWindow(Title);
								close();
								if (FixGammaCorr) {
									GammaCorrFix = GammaCorr[i];
								} //bpp
								if (FixMultiply) {
									MultiplyFix = MultiplyBeforeDepthcoding[i];
								} //bpp
							}

							//////////////////////////////// so, the above 'default' Settings-loop is operated when NO CHOPPING
							//////////////////////////////// but can be used to indicate that it is necessary to do chopping - can especially be appreciated after seeing the test-depthcoded image
							//////////////////////////////// in that case --> go into the alternative Settings-loop , which is more complicated

							//////////////////////////////// ALTERNATIVE SETTINGS-LOOP	start		//bp2121
							//////////////////////////////// ALTERNATIVE SETTINGS-LOOP	start		//bp2121

							//	PileUpChunks[i]=0; //bp37
							AlreadyShown = 0; //bp37 //RO232 Variable is not used anywhere except in if function on line 1834. Just gives an error when depthcoding or DeleteZStacks is not used... defined it as 0 on line 1476 to prevent this, is it required?
							if (SplitZ[i] > 0) {
								// nu nog open van hieroor : 	SelectedZstack
								ArrayZSplitBorders = newArray(nChunks - 1);
								Extra = "";
								Extra2 = "";
								selectWindow(Title);
								run("Select None");
								run("View 100%");
								setLocation(1, 1);
								run("glow"); //setMinAndMax(min, max); //deze min and max waren in de default settings-gedoe al opgehaald uit de List
								Continue = 1;
								while (Continue) {
									getLocationAndSize(dummy, dummy, testWidth, testHeight);
									if (testWidth < 0.5 * screenWidth && testHeight < 0.7 * screenHeight) {
										run("In [+]");
									} else {
										Continue = 0;
									}
								}
								setLocation(0.5 * screenWidth - 0.5 * testWidth, 0.5 * screenHeight - 0.5 * testHeight);
								RememberZoom = getZoom();

								PlanesDialog = 1;
								while (PlanesDialog) {
									// borders aanwijzen
									for (s = 0; s < (nChunks - 1); s++) {
										selectWindow(Title);
										run("Select None");
										ProposedPlane = round(((s + 1) / nChunks) * (TopZ[i] - BottomZ[i])) + 1;
										Stack.setPosition(1, ProposedPlane, 1); //bp37

										if (nChunks > 2) {
											Extra = "\n \n ( #" + s + 1 + " of " + nChunks - 1 + " borders ; divide in " + nChunks + " parts)";
										}
										if (nChunks == 2) {
											Extra2 = "\n \n (or decide to split it up in 3 parts)";
										}
										waitForUser("Set at z-plane where to split" + Extra + Extra2);
										Stack.getPosition(dummy, slice, dummy);
										ArrayZSplitBorders[s] = slice;
									} // deze 2 sowieso
									BottomZ_1[i] = BottomZ[i] - OffsetZ;
									TopZ_1[i] = ArrayZSplitBorders[0] + 1; //bp30 deze 3 regels
									BottomZ_2[i] = ArrayZSplitBorders[0];
									TopZ_2[i] = TopZ[i] - OffsetZ;
									if (nChunks == 3) {
										TopZ_2[i] = ArrayZSplitBorders[1] + 1;
										BottomZ_3[i] = ArrayZSplitBorders[1];
										TopZ_3[i] = TopZ[i] - OffsetZ;
									}
									Dialog.create(" "); // macro proposes the following, but user can opt for larger overlap
										Dialog.setInsets(5, 20, 0);
										Dialog.addMessage("Z-planes for Split-Analysis Part #1");
										Dialog.setInsets(0, 20, 0);
										Dialog.addNumber("from Z-plane", BottomZ_1[i]);
										Dialog.setInsets(0, 20, 0);
										Dialog.addNumber("to Z-plane", TopZ_1[i]);
										Dialog.setInsets(10, 20, 0);
										Dialog.addMessage("Z-planes for Split-Analysis Part #2");
										Dialog.setInsets(0, 20, 0);
										Dialog.addNumber("from Z-plane", BottomZ_2[i]);
										Dialog.setInsets(0, 20, 0);
										Dialog.addNumber("to Z-plane", TopZ_2[i]);
										if (nChunks == 2) {
											Dialog.setInsets(20, 20, 0);
											Dialog.addCheckbox("Split in 3 parts ...", 0);
										}
										if (nChunks == 3) {
											Dialog.setInsets(10, 20, 0);
											Dialog.addMessage("Z-planes for Split-Analysis Part #3");
											Dialog.setInsets(0, 20, 0);
											Dialog.addNumber("from Z-plane", BottomZ_3[i]);
											Dialog.setInsets(0, 20, 0);
											Dialog.addNumber("to Z-plane", TopZ_3[i]);
										}
									Dialog.show();
										BottomZ_1[i] = Dialog.getNumber();
										BottomZ_1[i] = BottomZ_1[i] + OffsetZ; //bp30
										TopZ_1[i] = Dialog.getNumber();
										TopZ_1[i] = TopZ_1[i] + OffsetZ;
										BottomZ_2[i] = Dialog.getNumber();
										BottomZ_2[i] = BottomZ_2[i] + OffsetZ;
										TopZ_2[i] = Dialog.getNumber();
										TopZ_2[i] = TopZ_2[i] + OffsetZ;
										ChangenChunksTo3 = 0;
										if (nChunks == 2) {
											ChangenChunksTo3 = Dialog.getCheckbox();
										}
										if (nChunks == 3) {
											BottomZ_3[i] = Dialog.getNumber();
											BottomZ_3[i] = BottomZ_3[i] + OffsetZ;
											TopZ_3[i] = Dialog.getNumber();
											TopZ_3[i] = TopZ_3[i] + OffsetZ;
										}
									if (ChangenChunksTo3 == 0) {
										PlanesDialog = 0;
									} else {
										nChunks = 3;
									}
								} // vd while(PlanesDialog){

								// Do the settings for each Chunk
								if (GammaCorrFix == GammaCorr[i]) {
									GammaCorrFill = GammaCorr[i];
								} else {
									GammaCorrFill = GammaCorrFix;
								}
								if (MultiplyFix == MultiplyBeforeDepthcoding[i]) {
									MultiplyFill = MultiplyBeforeDepthcoding[i];
								} else {
									MultiplyFill = MultiplyFix;
								}

								nTimesTest = nChunks + SplitAndUnsplit[i];
								for (s = 0; s < (nTimesTest); s++) { // als geen opdeling dan nChunks =1;
									Loop = 1;
									FirstTime = 1;
									FixGammaCorr = 0;
									FixMultiply = 0;
									ForUnsplit = 0;
									if (SplitAndUnsplit[i] && s + 1 == nTimesTest) {
										ForUnsplit = 1;
									}

									if (s + 1 == 1 && ForUnsplit == 0) {
										selectWindow("SelectedZstack");
										run("Select None");
										run("Duplicate...", "title=[SelectedZstack_1] duplicate slices=" + BottomZ_1[i] + "-" + TopZ_1[i]);
										Title = getTitle();
									} // Title is dus nu de opgedeelde !!!!!
									if (s + 1 == 2 && ForUnsplit == 0) {
										selectWindow("SelectedZstack");
										run("Select None");
										run("Duplicate...", "title=[SelectedZstack_2] duplicate slices=" + BottomZ_2[i] + "-" + TopZ_2[i]);
										Title = getTitle(); 
									}
									if (s + 1 == 3 && ForUnsplit == 0) {
										selectWindow("SelectedZstack");
										run("Select None");
										run("Duplicate...", "title=[SelectedZstack_3] duplicate slices=" + BottomZ_3[i] + "-" + TopZ_3[i]);
										Title = getTitle(); 
									}
									if (ForUnsplit) {
										selectWindow("SelectedZstack");
										run("Select None");
										Title = getTitle();
									}

									selectWindow(Title);
									run("Select None");
									run("View 100%");
									setLocation(1, 1);
									run("Set... ", "zoom=" + 100 * RememberZoom);
									setLocation(0.5 * screenWidth - 0.5 * testWidth, 0.5 * screenHeight - 0.5 * testHeight);
									ChunkString = "\n now : Chunk #" + s + 1;
									if (ForUnsplit) {
										ChunkString = "\n now : for the WHOLE stack ";
									}
									ChunkStringWait = "Settings for Chunk #" + s + 1 + " \n \n ";
									if (ForUnsplit) {
										ChunkStringWait = "Settings for the WHOLE stack \n \n ";
									}
									selectWindow(WhiteScreen);
									waitForUser(ChunkStringWait + " " + ChunkStringWait + " " + ChunkStringWait + " " + ChunkStringWait);
									selectWindow(Title); //bp50
									if (ForUnsplit) { // want dat is logischer
										GammaCorrFill = GammaCorr_1[i];
										MultiplyFill = MultiplyBeforeDepthcoding_1[i];
									}

									while (Loop) {
										Continue = 1; //bp37
										while (Continue) { //bp37
											Continue = 0; //bp37
											TestOrContinue = newArray;
											TestOrContinue[0] = "TEST these settings";
											TestOrContinue[1] = "SAVE these settings and CONTINUE";
											Dialog.create("Set Parameters fo Depthcoding"); //bp37
												Dialog.setInsets(0, 0, 0);
												Dialog.addMessage("SPLITTING THE STACK \n \n " + ChunkString + " " + ChunkString + " " + ChunkString);
												Dialog.setInsets(15, 0, 0);
												Dialog.addMessage("Position " + i + 1 + " (of " + PositionNumber.length + ")");
												Dialog.setInsets(-3, 0, 0);
												Dialog.addMessage("Which Gamma factor? (bring low and high intensies together)");
												Dialog.setInsets(-3, 0, 0);
												Dialog.addMessage("Which Multiply factor? (for depth coded channel)");
												Dialog.setInsets(0, 0, 0);
												Dialog.addMessage(" ");

												Dialog.setInsets(2, 0, 2);
												Dialog.addNumber("GAMMA Factor", gamma_factor_import, 2, 8, ""); //bpp
												Dialog.setInsets(-29, 310, 0);
												Dialog.addCheckbox("fix", FixGammaCorr);
												Rounded = round(20 * GammaCorrFill);
												a = Rounded / 20;
												aString = d2s(a, 2);
												GammaSteps = newArray(-0.1, -0.05, 0, 0.05, 0.1);
												ProposeGamma = newArray(GammaSteps.length);
												for (c = 0; c < GammaSteps.length; c++) {
													ProposeGamma[c] = d2s(a + GammaSteps[c], 2);
												}
												Dialog.setInsets(0, 120, 0);
												Dialog.addRadioButtonGroup("", ProposeGamma, 1, 5, ProposeGamma[round((GammaSteps.length + 1) / 2) - 1]); //bp40
												Dialog.setInsets(0, 0, 0);
												Dialog.addMessage(" ");

												Dialog.setInsets(2, 0, 2);
												Dialog.addNumber("MULTIPLY Factor", multiply_factor_import, 2, 8, ""); //bpp
												Dialog.setInsets(-29, 310, 0);
												Dialog.addCheckbox("fix", FixMultiply);
												Rounded = round(20 * MultiplyFill);
												b = Rounded / 20;
												bString = d2s(b, 2);
												MultiplySteps = newArray(-0.15, -0.1, -0.05, 0, 0.05, 0.1, 0.15);
												ProposeMultiply = newArray(MultiplySteps.length);
												for (c = 0; c < MultiplySteps.length; c++) {
													ProposeMultiply[c] = d2s(b + MultiplySteps[c], 2);
												}
												Dialog.setInsets(0, 120, 0);
												Dialog.addRadioButtonGroup("", ProposeMultiply, 1, 5, ProposeMultiply[round((MultiplySteps.length + 1) / 2) - 1]); //bp40
												Dialog.setInsets(0, 0, 0);
												Dialog.addMessage(" ");

												Dialog.setInsets(20, 90, 0);
												Dialog.addRadioButtonGroup("Show Depth projection with above settings?", TestOrContinue, 2, 1, TestOrContinue[0]); //BP37
												Dialog.setInsets(0, 0, 0);
												Dialog.addMessage(" ");

												Dialog.setInsets(-130, 414, 0);
												Dialog.addCheckbox("Play (2x)", PlayDepth); //bp16
												Dialog.setInsets(-72, 200, 5);
												Dialog.addNumber("", Duration, 1, 4, "sec"); //bp16 // bp21

											//Dialog.show();

												if (s + 1 == 1 && ForUnsplit == 0) {
													GammaCorr_1[i] = Dialog.getNumber();
													FixGammaCorr = Dialog.getCheckbox();
													ProposedGamma = Dialog.getRadioButton();
													if (ProposedGamma != aString) {
														ProposedGamma = parseFloat(ProposedGamma);
														GammaCorr_1[i] = ProposedGamma;
													}
													GammaCorrTest = GammaCorr_1[i];
													GammaCorrFill = GammaCorrTest;
												}
												if (s + 1 == 2 && ForUnsplit == 0) {
													GammaCorr_2[i] = Dialog.getNumber();
													FixGammaCorr = Dialog.getCheckbox();
													ProposedGamma = Dialog.getRadioButton();
													if (ProposedGamma != aString) {
														ProposedGamma = parseFloat(ProposedGamma);
														GammaCorr_2[i] = ProposedGamma;
													}
													GammaCorrTest = GammaCorr_2[i];
													GammaCorrFill = GammaCorrTest;
												}
												if (s + 1 == 3 && ForUnsplit == 0) {
													GammaCorr_3[i] = Dialog.getNumber();
													FixGammaCorr = Dialog.getCheckbox();
													ProposedGamma = Dialog.getRadioButton();
													if (ProposedGamma != aString) {
														ProposedGamma = parseFloat(ProposedGamma);
														GammaCorr_3[i] = ProposedGamma;
													}
													GammaCorrTest = GammaCorr_3[i];
													GammaCorrFill = GammaCorrTest;
												}
												if (ForUnsplit) {
													GammaCorr[i] = Dialog.getNumber();
													FixGammaCorr = Dialog.getCheckbox();
													ProposedGamma = Dialog.getRadioButton();
													if (ProposedGamma != aString) {
														ProposedGamma = parseFloat(ProposedGamma);
														GammaCorr[i] = ProposedGamma;
													}
													GammaCorrTest = GammaCorr[i];
													GammaCorrFill = GammaCorrTest;
												}

												if (s + 1 == 1 && ForUnsplit == 0) {
													MultiplyBeforeDepthcoding_1[i] = Dialog.getNumber();
													FixMultiply = Dialog.getCheckbox();
													ProposedMultiply = Dialog.getRadioButton();
													if (ProposedMultiply != bString) {
														ProposedMultiply = parseFloat(ProposedMultiply);
														MultiplyBeforeDepthcoding_1[i] = ProposedMultiply;
													}
													MultiplyTest = MultiplyBeforeDepthcoding_1[i];
													MultiplyFill = MultiplyTest;
												}
												if (s + 1 == 2 && ForUnsplit == 0) {
													MultiplyBeforeDepthcoding_2[i] = Dialog.getNumber();
													FixMultiply = Dialog.getCheckbox();
													ProposedMultiply = Dialog.getRadioButton();
													if (ProposedMultiply != bString) {
														ProposedMultiply = parseFloat(ProposedMultiply);
														MultiplyBeforeDepthcoding_2[i] = ProposedMultiply;
													}
													MultiplyTest = MultiplyBeforeDepthcoding_2[i];
													MultiplyFill = MultiplyTest;
												}
												if (s + 1 == 3 && ForUnsplit == 0) {
													MultiplyBeforeDepthcoding_3[i] = Dialog.getNumber();
													FixMultiply = Dialog.getCheckbox();
													ProposedMultiply = Dialog.getRadioButton();
													if (ProposedMultiply != bString) {
														ProposedMultiply = parseFloat(ProposedMultiply);
														MultiplyBeforeDepthcoding_3[i] = ProposedMultiply;
													}
													MultiplyTest = MultiplyBeforeDepthcoding_3[i];
													MultiplyFill = MultiplyTest;
												}
												if (ForUnsplit) {
													MultiplyBeforeDepthcoding[i] = Dialog.getNumber();
													FixMultiply = Dialog.getCheckbox();
													ProposedMultiply = Dialog.getRadioButton();
													if (ProposedMultiply != bString) {
														ProposedMultiply = parseFloat(ProposedMultiply);
														MultiplyBeforeDepthcoding[i] = ProposedMultiply;
													}
													MultiplyTest = MultiplyBeforeDepthcoding[i];
													MultiplyFill = MultiplyTest;
												}

												Loop = Dialog.getRadioButton();
												if (Loop == "TEST these settings") {
													Loop = 1;
												} else {
													Loop = 0;
												}
												print("printloop 2: " + Loop);

												PlayDepth = Dialog.getCheckbox();
												Duration = Dialog.getNumber();

											//bp37
											if (GammaCorrFill < 0.1 || GammaCorrFill > 1) {
												Continue = 1;
												Temp = "Gamma";
											}
											if (MultiplyFill < 0.6 || MultiplyFill > 4) {
												Continue = 1;
												Temp = "MultiplyFactor";
											}
											if (Continue) {
												print("");
												waitForUser("The settings for " + Temp + " seem odd; do again ");
												print("");
											}
										}

										if (FirstTime == 0) {
											selectWindow("Depth" + Title);
											close();
										}
										if (Loop) { 
											selectWindow(Title);
											run("Select None");
											run("Duplicate...", "title=[" + Title + "_temp] duplicate");
											selectWindow(Title + "_temp");
											getLocationAndSize(xTemp, yTemp, dummy, dummy);
											if (xTemp < StatusWidth) {
												setLocation(1.5 * StatusWidth, yTemp);
											} //bp38
											run("Gamma...", "value=" + GammaCorrTest + " stack");
											run("Re-order Hyperstack ...", "channels=[Channels (c)] slices=[Frames (t)] frames=[Slices (z)]");
											getLocationAndSize(xTemp, yTemp, dummy, dummy);
											if (xTemp < StatusWidth) {
												setLocation(1.5 * StatusWidth, yTemp);
											} //bp38

											run("Multiply...", "value=" + MultiplyTest + " stack");
											run("Temporal-Color Code", "lut=[Depth Organoid]");
											rename("Depth" + Title);
											selectWindow(Title + "_temp");
											close();

											//bp14
											selectWindow(Title);
											setLocation(1, 1);
											run("View 100%");
											getLocationAndSize(dummy, dummy, TempWidth, TempHeight);
											selectWindow("Depth" + Title);
											setLocation(1, 1);
											run("View 100%");
											selectWindow("SelectedZstack");
											setLocation(1, 1);
											run("View 100%");
											while (TempWidth > 0.5 * screenWidth) {
												selectWindow("SelectedZstack");
												run("Out [-]");
												selectWindow("Depth" + Title);
												run("Out [-]");
												selectWindow(Title);
												run("Out [-]");
												getLocationAndSize(dummy, dummy, TempWidth, TempHeight);
												SetZoom = getZoom();
											}
											while (TempWidth < 0.5 * screenWidth) {
												selectWindow("SelectedZstack");
												run("In [+]");
												selectWindow("Depth" + Title);
												run("In [+]");
												selectWindow(Title);
												run("In [+]");
												getLocationAndSize(dummy, dummy, TempWidth, TempHeight);
												SetZoom = getZoom();
											}
											selectWindow(Title);
											setLocation(0.5 * screenWidth - 0.5 * TempWidth, 0.5 * screenHeight - 0.5 * TempHeight);
											selectWindow("Depth" + Title);
											setLocation(0.5 * screenWidth - 0.5 * TempWidth, 0.5 * screenHeight - 0.5 * TempHeight);
											selectWindow("SelectedZstack");
											setLocation(0.5 * screenWidth - 0.5 * TempWidth, 0.5 * screenHeight - 0.5 * TempHeight);
											selectWindow(WhiteScreen);
											// play movie twice
											if (PlayDepth) { //bp16		
												FrameRate = 2 * NumberOfTPTempStacks / (Duration); // in fps 	// so, plays it twice
												wait(80);
												selectWindow("Depth" + Title);
												wait(80);
												setSlice(1);
												run("Animation Options...", "speed=" + FrameRate);
												doCommand("Start Animation [\\]");
												wait(Duration * 1000);
												run("Stop Animation");
												setSlice(1);
											}

											waitForUser("Check out the depthcoding! \n \n " + s + 1 + " (of " + nTimesTest + ")");
											FirstTime = 0;
										} // vd if(Loop

										if (Loop == 0) {
											selectWindow(Title);
											close();
										} // when user clicked "CONTINUE"

									} // vd while(Loop
								} // vd for(s
								if (isOpen("SelectedZstack")) {
									selectWindow("SelectedZstack");
									close();
								}

							} // vd if(SplitZ[i]>0) // 

							//////////////////////////////// ALTERNATIVE SETTINGS-LOOP	end
							//////////////////////////////// ALTERNATIVE SETTINGS-LOOP	end
							//////////////////////////////// ALTERNATIVE SETTINGS-LOOP	end

						} // vd if(SetMultiplyBeforeDepthcoding
					} // vd if(Use DepthCoding
					else {
						selectWindow(Title);
						close();
					}
					if (isOpen(WhiteScreen)) {
						selectWindow(WhiteScreen);
						close();
					}
				}
			} // vd for(i=StartFromi;i<PositionNumber.length
		} // vd if(DeleteZStacks					

		//Zslice selection !!!!!!!!!!!! DeleteZslices!!!!!!!!!!!!!!

		//NORMAL, SAVE SETTINGS 3	
		SetSettings();
		newImage("Settings", "16-bit white", 10, 10, 1); //Move this to the end of B&C selection when ready?!
		list = List.getList();
		setMetadata("info", list);
		saveAs("Tiff", TempDisk + ":\\ANALYSIS DUMP\\" + Q + "Exp" + WhereToSaveSettings + "\\Settings\\Settings_Exp" + WhereToSaveSettings + ".tif");
		saveAs("Tiff", TempDisk + ":\\ANALYSIS DUMP\\Settings\\Settings_Previous_Exp.tif"); //bp42
		close();

		newImage("Progress", "16-bit white", 800, 300, 1);
		if (PrintLikeCrazy) {
			getDateAndTime(NAV, NAV, NAV, NAV, plcH, plcM, plcS, plcMS);
			print(plcH + "hr " + plcM + "min " + plcS + "sec " + plcMS + "msec COMBINE THE CHANNELS AND TRANS/DEPTHCODING 34");
		}
		setColor("black");
		setFont("SansSerif", 25, "bold antialiased");
		getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec); //Gets time 
		month = month + 1; //for some reason my computer saw august as 7 !?!
		if (hour < 10) hour = "0" + hour;
		if (minute < 10) minute = "0" + minute;
		if (second < 10) second = "0" + second; //Adds a 0 if the number is below 10 (esthetics...)
		drawString("Finished making settins of Exp" + WhereToSaveSettings, 10, 40);
		if (CheckPositionName) drawString("Name: No position was processed yet", 10, 80);
		drawString("Time of day: " + hour + ":" + minute + "," + second + "s " + dayOfMonth + "/" + month + "/" + year, 10, 120);
		List.set("Progress", i);
		list = List.getList();
		setMetadata("info", list);
		saveAs("Tiff", TempDisk + ":\\ANALYSIS DUMP\\" + Q + "Exp" + WhereToSaveSettings + "\\Settings\\Progress.tif");
		close();

		if (QueueMultiple) {
			QueueString = "QueueMultiple_" + QueueMultiple + " ; nQueuedExp_" + nQueuedExp;
			File.saveString(QueueString, TempDisk + ":\\ANALYSIS DUMP\\Queue-info.txt");
			if (isOpen("Results")) {
				selectWindow("Results");
				run("Close");
			}
			if (isOpen("B&C")) {
				selectWindow("B&C");
				run("Close");
			}
			print("movie " + movie_index + " added to queue");
			exit;
		}

		if (QueueMultiple == 0 && AlreadyShown == 0) {
			waitForUser(" OK, those were the settings \n \n now PROCESS !! \n now PROCESS !! \n now PROCESS !! \n now PROCESS !! \n now PROCESS !! \n now PROCESS !! \n now PROCESS !! \n now PROCESS !! ");
		} //bp30

	} // <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< RESTART END >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
	PrintSettings();

	// RESTART ?? --> possibility to change settings
	if (Restart && CheckSettings) {
		Dialog.create("Settings");
			Dialog.addString("Date experiment:", Date);
			Dialog.addString("Name Experiment:", NameExperiment, 30); //Dialog.setInsets(top, left, bottom) 		
			if (Interval == round(Interval)) {
				DecimalPlaces = 0;
			} else {
				DecimalPlaces = 1;
			} // + figure out, whether to use decimals or not. only when interval had a decimal other than 0
			Dialog.setInsets(10, 0, 3);
			Dialog.addNumber("Time Interval", Interval, DecimalPlaces, 5, "min");
			i = 0;
			Shift = (parseFloat(PositionChannelAmount[i]) - 1) * 22 + 22; //Assumes that the positions have the same amount as the first channel
			Dialog.setInsets(22, 0, 5)
			Dialog.addMessage("UseChannel Channel ChannelName ChannelColour");
			for (j = 0; j < PositionChannelAmount[i]; j++) {
				if (TransmittedChannelNumber[i] == j) {
					Dialog.addMessage("This Channel (" + ChannelNumber[j] + ") is the Transmitted! No settings Required!");
				} else {
					Dialog.setInsets(-5, 60, -22)
					Dialog.addCheckbox(" ", UseChannel[j])
					Dialog.setInsets(-20, 100, -40.5);
					Dialog.addChoice(ChannelNumber[j], ChannelColourOriginal, ChannelColour[j]);
					Dialog.setInsets(-20, 120, 0)
					Dialog.addString(" ", ChannelName[j], 10);
				}
			}
			Dialog.addMessage(" ");
			Dialog.setInsets(0, 40, -10);
			Dialog.addRadioButtonGroup("If <=2 Channels: Add depthcoding?", newArray("With", "Without"), 1, 2, UseDepthcoding);
			Dialog.addMessage(" ");
			Dialog.setInsets(0, 40, 0);
			Dialog.addCheckbox("RedDeadDye", RedDeadDye);
			//			Dialog.setInsets(5, 40,0) ;	Dialog.addCheckbox("Limit Z-Stacks to be used?", DeleteZStacks);
			if (CheckPositionName) {
				Dialog.setInsets(5, 40, 0);
				Dialog.addCheckbox("Add Position Name to Filename?", AddPositionName);
			}
		Dialog.show();
			// !!!!!!!!!!!!!!! =========== Here We open a window to define all settings ===============!!!!!!!!!!!!!
			NumberOfChannelsToBeProcessed = 0;
			// !!!!!!!!!!!!!!! =========== Here We retreive all the chosen settings ===============!!!!!!!!!!!!!
			Date = Dialog.getString();
			print("Date experiment: " + Date);
			NameExperiment = Dialog.getString();
			print("Name Experiment: " + NameExperiment);
			Interval = Dialog.getNumber();
			print("Time Interval: " + Interval + " min");
			i = 0;
			for (j = 0; j < PositionChannelAmount[i]; j++) {
				if (TransmittedChannelNumber[i] == j) {
					NumberOfChannelsToBeProcessed = NumberOfChannelsToBeProcessed + 1;
				} else {
					UseChannel[j] = Dialog.getCheckbox();
					if (UseChannel[j]) {
						ChannelColour[j] = Dialog.getChoice();
						NumberOfChannelsToBeProcessed = NumberOfChannelsToBeProcessed + 1;
					} else {
						ChannelColour[j] = "None";
					}
					ChannelName[j] = Dialog.getString();
				}
			}
			UseDepthcoding = Dialog.getRadioButton;
			RedDeadDye = Dialog.getCheckbox();
			//		DeleteZStacks 		= Dialog.getCheckbox();		
			if (CheckPositionName) {
				AddPositionName = Dialog.getCheckbox();
			}
		//bpx
		if (QueueMultiple) {
			nQueuedExp = nQueuedExp + 1;
		}
		if (RedDeadDye) NumberOfChannelsToBeProcessed = NumberOfChannelsToBeProcessed - 1;
		print("NumberOfChannelsToBeProcessed: " + NumberOfChannelsToBeProcessed);
		if (NumberOfChannelsToBeProcessed > 2) {
			UseDepthcoding = "Without";
		}
		if (UseDepthcoding == "Without" && NumberOfChannelsToBeProcessed < 3) {
			waitForUser("UseDepthcoding is now 'WITHOUT'. \n \n you really want that ?? ");
		}
		////////////////////////////////////////////////////////
		///////// EXTENDED SETTINGS ////////////////////////
		////////////////////////////////////////////////////////
		Dialog.create("Extended settings");
			Shift = 130;
			Dialog.setInsets(10, Shift, 0);
			Dialog.addCheckbox("Window to pause macro", WindowForPause);
			Dialog.addNumber("Pause window - duration", TimeForPause, 0, 6, "msec");
			Dialog.addNumber("Pause window - every", PauseInterval, 0, 6, "frames");
			Dialog.addNumber("Collect Garbage - every", GarbageInterval, 0, 6, "frames");
			Dialog.setInsets(15, 0, 3);
			Dialog.addNumber("Fraction For Text (1/x) : ", FractionForText, 0, 3, "");

			Dialog.setInsets(15, Shift, 0);
			Dialog.addCheckbox("Add Channel Name?", ColourName);
			Dialog.setInsets(5, Shift, 0);
			Dialog.addCheckbox("Add Time Stamp?", AddTime);

			Dialog.addChoice("Colour Timestamp:", newArray("White", "Black", "Red", "Green", "Blue", "Cyan", "Magenta", "Yellow"), ColorTime);
			Dialog.setInsets(5, Shift, 0);
			Dialog.addCheckbox("Add Scale Bar?", AddScaleBar);
			Dialog.setInsets(-3, 214, 0);
			Dialog.addCheckbox("write scale above bar", WriteBarDimensions);
			Dialog.addNumber("width", FractionForBar, 2, 6, "(% of image)");

			Dialog.setInsets(5, Shift, -12);
			Dialog.addCheckbox("Add Reference Depthcoding?", AddScaleBarZ);
			Dialog.setInsets(-10, 190, 0);
			Dialog.addRadioButtonGroup("Left or above ?", newArray("Left", "Top"), 1, 2, PlaceScaleBarZ);

			Dialog.setInsets(0, Shift, 0);
			Dialog.addCheckbox("Save Progress to Network?", SaveProgressToNetwork);
			Dialog.setInsets(15, Shift, 0);
			Dialog.addCheckbox("Use orignal colour instead of Glow?", SkipGlow);
			Dialog.setInsets(0, Shift, 0);
			Dialog.addCheckbox("Print text in GlowWindow as White?", TextInGlowIsWhite);
			Dialog.setInsets(0, Shift, 0);
			Dialog.addCheckbox("Processing in Upper Left", UpperLeft);
			Dialog.setInsets(0, Shift, 0);
			Dialog.addCheckbox("Hide Windows", Hidewindows);
		Dialog.show(); // !!!!!!!!!!!!!!! =========== Here We open a window to define all extended settings ===============!!!!!!!!!!!!!

		// !!!!!!!!!!!!!!! =========== Here We retreive all the chosen extended settings ===============!!!!!!!!!!!!!
			WindowForPause = Dialog.getCheckbox();
			TimeForPause = Dialog.getNumber();
			PauseInterval = Dialog.getNumber();
			GarbageInterval = Dialog.getNumber();
			FractionForText = Dialog.getNumber();

			ColourName = Dialog.getCheckbox();
			AddTime = Dialog.getCheckbox();

			ColorTime = Dialog.getChoice();
			AddScaleBar = Dialog.getCheckbox();
			WriteBarDimensions = Dialog.getCheckbox();
			FractionForBar = Dialog.getNumber();

			AddScaleBarZ = Dialog.getCheckbox();
			PlaceScaleBarZ = Dialog.getRadioButton();

			SaveProgressToNetwork = Dialog.getCheckbox();
			SkipGlow = Dialog.getCheckbox();
			TextInGlowIsWhite = Dialog.getCheckbox();
			UpperLeft = Dialog.getCheckbox();
			Hidewindows = Dialog.getCheckbox();
		// !!!!!!!!!!!!!!! =========== Here We retreive all the chosen extended settings ===============!!!!!!!!!!!!!
		AddScaleBarZLeft = 0;
		if (AddScaleBarZ && PlaceScaleBarZ == "Left") {
			AddScaleBarZLeft = 1;
		}
		AddScaleBarZTop = 0;
		if (AddScaleBarZ && PlaceScaleBarZ == "Top") {
			AddScaleBarZTop = 1;
		}

		MultiplyBeforeDepthcoding = newArray(AmountOfPositions);
		Array.fill(MultiplyBeforeDepthcoding, DefaultMultiply); //bpm blokkie
		GammaCorr = newArray(AmountOfPositions);
		Array.fill(GammaCorr, DefaultGamma);
	} // vd if(Restart && CheckSettings)

	if (WindowForPause) {
		newImage("Pause", "RGB black", 0.2 * screenWidth, 0.1 * screenHeight, 1);
		HeightTemp = getHeight();
		getLocationAndSize(dummy, dummy, PauseWidth, PauseHeight);
		VisibleX = screenWidth - PauseWidth - 10;
		VisibleY = screenHeight - PauseHeight - 30;
		setLocation(screenWidth, VisibleY);
		setFont("SansSerif", 0.015 * screenWidth, " antialiased");
		run("Colors...", "foreground=yellow");
		drawString("Select window to pause", 15, HeightTemp - 15);
	}

	//========================================================That was the last of the settings set and saved, now we process the files!=============================
	//========================================================That was the last of the settings set and saved, now we process the files!=============================
	//========================================================That was the last of the settings set and saved, now we process the files!=============================
	//========================================================That was the last of the settings set and saved, now we process the files!=============================
	//========================================================That was the last of the settings set and saved, now we process the files!=============================
	//========================================================That was the last of the settings set and saved, now we process the files!=============================
	//========================================================That was the last of the settings set and saved, now we process the files!=============================

	if (Hidewindows == 1) Hidewindows = true; // Seems odd but list.get retreives a value not recognised as true (sees 1 as text, not as number)

	//ALL, START OF ACTUAL PROCESSING OPEN POSITION
	for (z = StartFromi; z < PositionNumber.length; z++) {
		print("i=z: " + z);
		ArraySkipPositions[z] = List.get("ArraySkipPositions_" + z); //bp17
		if (ArraySkipPositions[z]) {
			waitForUser("ArraySkipPositions mistake");
		}
		if (ArraySkipPositions[z] == 0) { //bp17

			i = z;

			if (RunAllQueued) {
				run("Collect Garbage");
				wait(2000);
			}

			//bp21
			if (SplitZ[i] == 0) {
				nChunks = 1;
			}
			if (SplitZ[i] == 2) {
				nChunks = 2;
			}
			if (SplitZ[i] == 3) {
				nChunks = 3;
			}

			for (Chunk = 1; Chunk < nChunks + 1; Chunk++) {
				if (TransmittedChannelPresent) {
					c = TransmittedChannelNumber[i];
					ChannelName[c] = "Transmitted";
					ChannelColour[c] = "White";
				}
				print("net voor de Bio-Formats");
				print("CURRENT TIME -", makeDateOrTimeString("time"));
				if (RunAllQueued) {
					tiffFile = 0;
					if (endsWith(file, ".tif")) {
						tiffFile = 1;
					}
				}
				if (tiffFile) {
					run("Bio-Formats", "open=[" + file + "] color_mode=Default split_channels view=Hyperstack stack_order=XYCZT");
					setLocation(1,1);
					if (RunAllQueued) {
						TiffName = getTitle();
					}
					rename(TiffName);
					run("The Real Glow");
				} else {
					run("Bio-Formats", "open=[" + file + "] color_mode=Default split_channels view=Hyperstack stack_order=XYCZT use_virtual_stack series_" + (PositionNumber[i]));
					setLocation(1,1);
					loop_number = loop_number + 1;
				}

				print("net na de Bio-Formats");
				if (do_registration)	correctDriftOnStack(lastframe);
				
				getDimensions(width, height, channels, slices, frames);
				LastTimepointTemp = parseFloat(NumberOfTimepoints[i]);

				// This is temporary to make the macro run through faster (for debugging)// This is temporary to make the macro run through faster (for debugging)
				// This is temporary to make the macro run through faster (for debugging)// This is temporary to make the macro run through faster (for debugging)
				// This is temporary to make the macro run through faster (for debugging)// This is temporary to make the macro run through faster (for debugging)
				if (LimitTimepointForDebugging >= 1) LastTimepointTemp = LimitTimepointForDebugging;
				// This is temporary to make the macro run through faster (for debugging)// This is temporary to make the macro run through faster (for debugging)
				// This is temporary to make the macro run through faster (for debugging)// This is temporary to make the macro run through faster (for debugging)								
				// This is temporary to make the macro run through faster (for debugging)// This is temporary to make the macro run through faster (for debugging)
				if (Singletimepoint[i] == 1) {
					LastTimepointTemp = 2;
				} //ro							

				TransmittedZslice[i] = List.get("TransmittedZslice" + i);
				SelectionX1[i] = List.get("SelectionX1_" + i);
				SelectionX2[i] = List.get("SelectionX2_" + i);
				SelectionY1[i] = List.get("SelectionY1_" + i);
				SelectionY2[i] = List.get("SelectionY2_" + i);
				//For calculations we need to use actual numbers, parseFloat converts the string to a number
				ROIx1 = SelectionX1[i];
				ROIx2 = SelectionX2[i];
				ROIy1 = SelectionY1[i];
				ROIy2 = SelectionY2[i];
				Smallest = minOf(ROIx2, ROIy2);
				TextSize = floor(Smallest / FractionForText);
				if (TextSize < MinimalTextSize) {
					TextSize = MinimalTextSize;
				} //waitForUser(TextSize);
				ScaleBarLineWidth = 2;
				if (TextSize < 20) {
					ScaleBarLineWidth = 1;
				} // of is het logischer om m afankelijk te maken van Image-Height ?????
				if (TextSize > 20) {
					ScaleBarLineWidth = 2;
				}
				if (TextSize > 30) {
					ScaleBarLineWidth = 3;
				}
				if (TextSize > 40) {
					ScaleBarLineWidth = 4;
				}

				for (l = 0; l < maxNumberOfChannels; l++) {
					UseChannel[l] = List.get("UseChannel" + l);
				} // Reset these to default as we change it in case of the use of RedDeadDye (line 602)
				// Need these variables for the CropToROI
				// Now rename the virtualstacks

				TempTitle = getTitle();
				if (tiffFile == 0) {
					TempTitle = substring(TempTitle, 0, lengthOf(TempTitle) - 1);
				}

				for (j = 0; j < PositionChannelAmount[i]; j++) {
					if (tiffFile == 0) {
						//selectWindow(TempTitle + j);	// ##DB## DB debug --> commented out. Results in *.nd0
					}
					print("i__" + j + "__TempTitle__" + TempTitle);
					if (tiffFile == 1) {
						selectWindow(TempTitle);
					}
					rename("Temp_" + ChannelName[j]);

					setBatchMode(false);
					print("i__" + j + "__rename...getTitle__" + getTitle);
					run("Put Behind [tab]");
				}
				if (RedDeadDye) {
					UseChannel[DeadChannel] = 0; // No list.Set as I don't want to save this! It would mean having to select the channel each time again you run the macro again
					ChannelColour[DeadChannel] = "None";
				} // It could also confuse the user. It does however need to be set to prevent making projections of the dead stuff	
				//ALL, PROCESS TRANSMITTED	

				// ===========================================================First do Trans====================================
				if (TransmittedChannelPresent) {
					c = TransmittedChannelNumber[i];
					if (PrintLikeCrazy) {
						getDateAndTime(NAV, NAV, NAV, NAV, plcH, plcM, plcS, plcMS);
						print(plcH + "hr " + plcM + "min " + plcS + "sec " + plcMS + "msec First do Trans 2");
					}
					selectWindow("Temp_" + ChannelName[c]);
					Transmitted = getTitle();

					if (PrintLikeCrazy) {
						getDateAndTime(NAV, NAV, NAV, NAV, plcH, plcM, plcS, plcMS);
						print(plcH + "hr " + plcM + "min " + plcS + "sec " + plcMS + "msec First do Trans 3");
					}
					if (Singletimepoint[i] == 1) {
						if (SingleTPtoZstack == 1) {
							ReOrder = 1;
							LastTimepointTemp = slices;
						} else {
							ReOrder = 0;
						}
						DuplicateSingleTimepoint(Transmitted, "Grays");
						selectWindow(Transmitted);
					}
					if (PrintLikeCrazy) {
						getDateAndTime(NAV, NAV, NAV, NAV, plcH, plcM, plcS, plcMS);
						print(plcH + "hr " + plcM + "min " + plcS + "sec " + plcMS + "msec First do Trans 4");
					}
					if (Singletimepoint[i] == 1) {
						run("Collect Garbage");
						selectWindow(Transmitted);
					} //RO 0204 got error when images were too big (tilescans), canged somting in splitZslice instead	

					splitZslice(Transmitted, TransmittedZslice[i]); //This will extract 1 Zslice of all timepoints of (second variable given to function determines which Zslice)	
					//waiForUser("TRANSMITTED? LastTimepointTemp:"+LastTimepointTemp);

					selectWindow(Transmitted);
					getDimensions(x, y, channelTemp, sliceTemp, frameTemp); // waitForUser("___sliceTemp_"+sliceTemp+"___frameTemp_"+frameTemp);print("");
					// Dimension="frames"; if(sliceTemp>frameTemp){Dimension="slices";}

					// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!																	// getDimensions (x,y,channelTemp,sliceTemp,frameTemp); waitForUser("_channelTemp__"+channelTemp+"_sliceTemp__"+sliceTemp+"__frameTemp_"+frameTemp);
					// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!																	// getDimensions (x,y,channelTemp,sliceTemp,frameTemp); waitForUser("_channelTemp__"+channelTemp+"_sliceTemp__"+sliceTemp+"__frameTemp_"+frameTemp);
					// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!																	// getDimensions (x,y,channelTemp,sliceTemp,frameTemp); waitForUser("_channelTemp__"+channelTemp+"_sliceTemp__"+sliceTemp+"__frameTemp_"+frameTemp);
					// hier stond ooit frames=etcetera en deed het toen maanden lang goed !!!!																					// waitForUser("___LastTimepointTemp_"+LastTimepointTemp+"___Dimension_"+Dimension);print("");
					// vanaf mei 2015 moet er slices staan...
					// gevolg van nieuwe acq software? of nieuwe Fiji?
					print("if macro crashes here, without printing HELLO!, then there's a problem again with \n run('Make Substack... slices= \n versus run('Make Substack...frames= ");
					run("Make Substack...", "slices=1-" + LastTimepointTemp);
					print("HELLO !!"); // waitForUser("___BottomZApply_");

					close(Transmitted);
					if (PrintLikeCrazy) {
						getDateAndTime(NAV, NAV, NAV, NAV, plcH, plcM, plcS, plcMS);
						print(plcH + "hr " + plcM + "min " + plcS + "sec " + plcMS + "msec First do Trans 5");
					}
					rename(Transmitted); // waitForUser("A komt i hier ?");print("");			
					//Remove last timepoint 											
					if (PauseAfterSettings) {
						wait(500 + RunAllQueued * 200);
					}

					cropToROI(Transmitted);
					if (PrintLikeCrazy) {
						getDateAndTime(NAV, NAV, NAV, NAV, plcH, plcM, plcS, plcMS);
						print(plcH + "hr " + plcM + "min " + plcS + "sec " + plcMS + "msec First do Trans 7");
					}
					removeNoise(Transmitted);
					if (PrintLikeCrazy) {
						getDateAndTime(NAV, NAV, NAV, NAV, plcH, plcM, plcS, plcMS);
						print(plcH + "hr " + plcM + "min " + plcS + "sec " + plcMS + "msec First do Trans 8");
					}
					min = List.get("LUT_Min_" + i + "_" + c);
					if (PrintLikeCrazy) {
						getDateAndTime(NAV, NAV, NAV, NAV, plcH, plcM, plcS, plcMS);
						print(plcH + "hr " + plcM + "min " + plcS + "sec " + plcMS + "msec First do Trans 9");
					}
					max = List.get("LUT_Max_" + i + "_" + c);
					print(min + " " + max);
					if (PrintLikeCrazy) {
						getDateAndTime(NAV, NAV, NAV, NAV, plcH, plcM, plcS, plcMS);
						print(plcH + "hr " + plcM + "min " + plcS + "sec " + plcMS + "msec First do Trans 10");
					}
					selectWindow(Transmitted);
					run("Select None");
					if (PrintLikeCrazy) {
						getDateAndTime(NAV, NAV, NAV, NAV, plcH, plcM, plcS, plcMS);
						print(plcH + "hr " + plcM + "min " + plcS + "sec " + plcMS + "msec First do Trans 12");
					}
					run("Brightness/Contrast...");
					if (PrintLikeCrazy) {
						getDateAndTime(NAV, NAV, NAV, NAV, plcH, plcM, plcS, plcMS);
						print(plcH + "hr " + plcM + "min " + plcS + "sec " + plcMS + "msec First do Trans 13");
					}
					if (max != 255 || min != 0) {
						setMinAndMax(min, max);
						if (bitDepth() == 8) {
							run("Apply LUT", "stack");
						} else {
							run("8-bit");
						}
						if (PrintLikeCrazy) {
							getDateAndTime(NAV, NAV, NAV, NAV, plcH, plcM, plcS, plcMS);
							print(plcH + "hr " + plcM + "min " + plcS + "sec " + plcMS + "msec First do Trans 14");
						}
					} else {
						DoSetZ = 1;
						SetTransmittedBrightness(Transmitted);
						if (bitDepth() == 8) {
							run("Apply LUT", "stack");
						} else {
							run("8-bit");
						}
						if (PrintLikeCrazy) {
							getDateAndTime(NAV, NAV, NAV, NAV, plcH, plcM, plcS, plcMS);
							print(plcH + "hr " + plcM + "min " + plcS + "sec " + plcMS + "msec First do Trans 15");
						}
					}
					// if you don't adjust the B&C in the trans you get an error when applying LUT	
					selectWindow(Transmitted);
					if (PrintLikeCrazy) {
						getDateAndTime(NAV, NAV, NAV, NAV, plcH, plcM, plcS, plcMS);
						print(plcH + "hr " + plcM + "min " + plcS + "sec " + plcMS + "msec First do Trans 17");
					}
					saveAs(TempDisk + ":\\ANALYSIS DUMP\\TEMP DUMP\\Temp_Trans.tif");
					close(); //bpxy
					if (RunAllQueued) {
						run("Collect Garbage");
					}
				}
				if (PrintLikeCrazy) {
					getDateAndTime(NAV, NAV, NAV, NAV, plcH, plcM, plcS, plcMS);
					print(plcH + "hr " + plcM + "min " + plcS + "sec " + plcMS + "msec First do Trans 19");
				}
				// Do we save or do we keep it open? (Memory management issues versus speed...)
				run("Collect Garbage");
				if (PrintLikeCrazy) {
					getDateAndTime(NAV, NAV, NAV, NAV, plcH, plcM, plcS, plcMS);
					print(plcH + "hr " + plcM + "min " + plcS + "sec " + plcMS + "msec First do Trans 21");
				}

				// ===========================================================That was the Transmitted ====================================
				//ALL, PROCESS CHANNELS
				// ===========================================================Now we do each channel=============================
				if (Singletimepoint[i] != 1) {
					setBatchMode(Hidewindows);
					SingleTPtoZstack = 0;
				}
				if (PrintLikeCrazy) {
					getDateAndTime(NAV, NAV, NAV, NAV, plcH, plcM, plcS, plcMS);
					print(plcH + "hr " + plcM + "min " + plcS + "sec " + plcMS + "msec Now we do each channel 1");
				}
				FirstTimeOnly = 0;
				if (PrintLikeCrazy) {
					getDateAndTime(NAV, NAV, NAV, NAV, plcH, plcM, plcS, plcMS);
					print(plcH + "hr " + plcM + "min " + plcS + "sec " + plcMS + "msec Now we do each channel 2");
				}
				if (SingleTPtoZstack == 1) {
					print("ChannelName: ");
					Array.print(ChannelName);
					waitForUser("4 komt i hier ?");
					print("");
					TransmittedChannel = TransmittedChannelNumber[i];
					for (j = 0; j < PositionChannelAmount[i]; j++) {
						c = j;
						print("a");
						if (TransmittedChannel == c) {
							UseChannel[c] = 0;
							print("TransmittedChannel" + c);
						}
						if (UseChannel[c]) {
							Zstack = nSlices();
							print("b");
							selectWindow("Temp_" + ChannelName[c]);
							print("c");
							run("Duplicate...", "title=[Temp_" + c + "_1] duplicate range=1-" + Zstack);
							print("d");
							min = List.get("LUT_Min_" + i + "_" + c);
							if (PrintLikeCrazy) {
								getDateAndTime(NAV, NAV, NAV, NAV, plcH, plcM, plcS, plcMS);
								print(plcH + "hr " + plcM + "min " + plcS + "sec " + plcMS + "msec Now we do each channel 7a");
							}
							max = List.get("LUT_Max_" + i + "_" + c);
							setMinAndMax(min, max);
							if (bitDepth() == 8) {
								run("Apply LUT", "stack");
							} else {
								run("8-bit");
							} // run("8-bit") command is used instead of //run("Apply LUT", "stack"); if the image is more than 8 bit... to convert it to 8 bit for further processing
							MakeTilesSingleTimepoint("Temp_" + c + "_1");
							selectWindow("Temp_" + ChannelName[c]);
						}
					}
				} else {
					for (frame = 1; frame <= LastTimepointTemp; frame++) {
						if (PrintLikeCrazy) {
							getDateAndTime(NAV, NAV, NAV, NAV, plcH, plcM, plcS, plcMS);
							print(plcH + "hr " + plcM + "min " + plcS + "sec " + plcMS + "msec Now we do each channel 4");
						}
						if (Singletimepoint[i] == 1) {
							FirstTimeOnly = FirstTimeOnly + 1;
							setBatchMode(false);
						}
						for (j = 0; j < PositionChannelAmount[i]; j++) {
							c = j;
							if (PrintLikeCrazy) {
								getDateAndTime(NAV, NAV, NAV, NAV, plcH, plcM, plcS, plcMS);
								print(plcH + "hr " + plcM + "min " + plcS + "sec " + plcMS + "msec Now we do each channel 5");
							}
							if (PauseAfterSettings) {
								wait(100 + RunAllQueued * 50);
							}
							if (TransmittedChannelNumber[i] == c) {
								UseChannel[c] = 0;
							}
							if (PrintLikeCrazy) {
								getDateAndTime(NAV, NAV, NAV, NAV, plcH, plcM, plcS, plcMS);
								print(plcH + "hr " + plcM + "min " + plcS + "sec " + plcMS + "msec Now we do each channel 6");
							}
							if (UseChannel[c]) {

								min = List.get("LUT_Min_" + i + "_" + c);
								if (PrintLikeCrazy) {
									getDateAndTime(NAV, NAV, NAV, NAV, plcH, plcM, plcS, plcMS);
									print(plcH + "hr " + plcM + "min " + plcS + "sec " + plcMS + "msec Now we do each channel 7");
								}
								max = List.get("LUT_Max_" + i + "_" + c);
								if (PrintLikeCrazy) {
									getDateAndTime(NAV, NAV, NAV, NAV, plcH, plcM, plcS, plcMS);
									print(plcH + "hr " + plcM + "min " + plcS + "sec " + plcMS + "msec Now we do each channel 8");
								}
								//setBatchMode(Hidewindows);	
								selectWindow("Temp_" + ChannelName[c]); // If possible remove channelname from tempfile to save diskspace (each channel will overwrite previous channel instead of creating a separeate set of images)

								id = getTitle;
								if (PrintLikeCrazy) {
									getDateAndTime(NAV, NAV, NAV, NAV, plcH, plcM, plcS, plcMS);
									print(plcH + "hr " + plcM + "min " + plcS + "sec " + plcMS + "msec Now we do each channel 9");
								}
								// remember the original hyperstack, this is a unique ID so independent of renaming

								if (Singletimepoint[i] == 1 && FirstTimeOnly == 1) {
									ReOrder = 0;
									DuplicateSingleTimepoint(id, ChannelColour[c]);
									selectWindow(id);
								}
								selectImage(id);
								// select the frame
								Stack.setPosition(1, 1, frame);
								if (PrintLikeCrazy) {
									getDateAndTime(NAV, NAV, NAV, NAV, plcH, plcM, plcS, plcMS);
									print(plcH + "hr " + plcM + "min " + plcS + "sec " + plcMS + "msec Now we do each channel 10");
								}

								if (DeleteZStacks) {
									if (SplitZ[i] == 0) {
										BottomZApply = BottomZ[i];
										TopZApply = TopZ[i];
									}
									if (SplitZ[i] > 0 && Chunk == 1) {
										BottomZApply = BottomZ_1[i];
										TopZApply = TopZ_1[i];
									}
									if (SplitZ[i] > 0 && Chunk == 2) {
										BottomZApply = BottomZ_2[i];
										TopZApply = TopZ_2[i];
									}
									if (SplitZ[i] > 0 && Chunk == 3) {
										BottomZApply = BottomZ_3[i];
										TopZApply = TopZ_3[i];
									}
								} else {
									getDimensions(x, y, ch, nZplanes, NumberOfFrames);
									BottomZApply = 1;
									TopZApply = nZplanes;
								} 
								// !!##DB##!! there's some stupid bug in the next line
								// the bug only appears in the second movie to be opened and only in if drift correction is selected
								run("Make Substack...", "slices=" + BottomZApply + "-" + TopZApply + " frames=" + frame);
								rename("TEMP");
								if (PrintLikeCrazy) {
									getDateAndTime(NAV, NAV, NAV, NAV, plcH, plcM, plcS, plcMS);
									print(plcH + "hr " + plcM + "min " + plcS + "sec " + plcMS + "msec Now we do each channel 11");
								}

								id2 = getTitle;
								if (PrintLikeCrazy) {
									getDateAndTime(NAV, NAV, NAV, NAV, plcH, plcM, plcS, plcMS);
									print(plcH + "hr " + plcM + "min " + plcS + "sec " + plcMS + "msec Now we do each channel 12");
								}
								rename("Temp_" + c + "_");
								id = getTitle;

								rename(id + frame);
								if (PrintLikeCrazy) {
									getDateAndTime(NAV, NAV, NAV, NAV, plcH, plcM, plcS, plcMS);
									print(plcH + "hr " + plcM + "min " + plcS + "sec " + plcMS + "msec Now we do each channel 15");
								}
								cropToROI(id + frame);
								if (PrintLikeCrazy) {
									getDateAndTime(NAV, NAV, NAV, NAV, plcH, plcM, plcS, plcMS);
									print(plcH + "hr " + plcM + "min " + plcS + "sec " + plcMS + "msec Now we do each channel 16");
								}
								removeNoise(id + frame);
								if (PrintLikeCrazy) {
									getDateAndTime(NAV, NAV, NAV, NAV, plcH, plcM, plcS, plcMS);
									print(plcH + "hr " + plcM + "min " + plcS + "sec " + plcMS + "msec Now we do each channel 17");
								}
								if (RedDeadDye) {
									if (PrintLikeCrazy) {
										getDateAndTime(NAV, NAV, NAV, NAV, plcH, plcM, plcS, plcMS);
										print(plcH + "hr " + plcM + "min " + plcS + "sec " + plcMS + "msec Now we do each channel 18");
									}
									if (c == NucleiChannel) { //is true if this is the channel which contains the nuclei (to substract the dead channel from)
										setBatchMode(Hidewindows);
										if (PrintLikeCrazy) {
											getDateAndTime(NAV, NAV, NAV, NAV, plcH, plcM, plcS, plcMS);
											print(plcH + "hr " + plcM + "min " + plcS + "sec " + plcMS + "msec Now we do each channel 19");
										}
										if (Singletimepoint[i] == 1) {
											setBatchMode(false);
										}
										if (PrintLikeCrazy) {
											getDateAndTime(NAV, NAV, NAV, NAV, plcH, plcM, plcS, plcMS);
											print(plcH + "hr " + plcM + "min " + plcS + "sec " + plcMS + "msec Now we do each channel 20");
										}
										selectWindow("Temp_" + ChannelName[DeadChannel]);
										if (PrintLikeCrazy) {
											getDateAndTime(NAV, NAV, NAV, NAV, plcH, plcM, plcS, plcMS);
											print(plcH + "hr " + plcM + "min " + plcS + "sec " + plcMS + "msec Now we do each channel 21");
										}
										Dead = getTitle();
										if (PrintLikeCrazy) {
											getDateAndTime(NAV, NAV, NAV, NAV, plcH, plcM, plcS, plcMS);
											print(plcH + "hr " + plcM + "min " + plcS + "sec " + plcMS + "msec Now we do each channel 22");
										}
										Stack.setPosition(1, 1, frame);
										if (PrintLikeCrazy) {
											getDateAndTime(NAV, NAV, NAV, NAV, plcH, plcM, plcS, plcMS);
											print(plcH + "hr " + plcM + "min " + plcS + "sec " + plcMS + "msec Now we do each channel 23");
										}
										run("Reduce Dimensionality...", "channels slices keep"); // extract one frame										
										if (DeleteZStacks) run("Make Substack...", " slices=" + BottomZApply + "-" + TopZApply);
										if (PrintLikeCrazy) {
											getDateAndTime(NAV, NAV, NAV, NAV, plcH, plcM, plcS, plcMS);
											print(plcH + "hr " + plcM + "min " + plcS + "sec " + plcMS + "msec Now we do each channel 24");
										}
										rename(Dead + frame);
										DeadFrame = getTitle();
										if (PrintLikeCrazy) {
											getDateAndTime(NAV, NAV, NAV, NAV, plcH, plcM, plcS, plcMS);
											print(plcH + "hr " + plcM + "min " + plcS + "sec " + plcMS + "msec Now we do each channel 25");
										}
										cropToROI(DeadFrame);
										if (PrintLikeCrazy) {
											getDateAndTime(NAV, NAV, NAV, NAV, plcH, plcM, plcS, plcMS);
											print(plcH + "hr " + plcM + "min " + plcS + "sec " + plcMS + "msec Now we do each channel 26");
										}
										removeNoise(DeadFrame);
										if (PrintLikeCrazy) {
											getDateAndTime(NAV, NAV, NAV, NAV, plcH, plcM, plcS, plcMS);
											print(plcH + "hr " + plcM + "min " + plcS + "sec " + plcMS + "msec Now we do each channel 27");
										}
										cutoff = parseFloat(List.get("Threshold" + i));
										if (PrintLikeCrazy) {
											getDateAndTime(NAV, NAV, NAV, NAV, plcH, plcM, plcS, plcMS);
											print(plcH + "hr " + plcM + "min " + plcS + "sec " + plcMS + "msec Now we do each channel 28");
										}
										DeadMask(DeadFrame, cutoff);
										if (PrintLikeCrazy) {
											getDateAndTime(NAV, NAV, NAV, NAV, plcH, plcM, plcS, plcMS);
											print(plcH + "hr " + plcM + "min " + plcS + "sec " + plcMS + "msec Now we do each channel 29");
										}
										substractDeadMask(DeadFrame, id + frame);
										if (PrintLikeCrazy) {
											getDateAndTime(NAV, NAV, NAV, NAV, plcH, plcM, plcS, plcMS);
											print(plcH + "hr " + plcM + "min " + plcS + "sec " + plcMS + "msec Now we do each channel 30");
										}
									}
									if (PrintLikeCrazy) {
										getDateAndTime(NAV, NAV, NAV, NAV, plcH, plcM, plcS, plcMS);
										print(plcH + "hr " + plcM + "min " + plcS + "sec " + plcMS + "msec Now we do each channel 31");
									}
								}
								if (PrintLikeCrazy) {
									getDateAndTime(NAV, NAV, NAV, NAV, plcH, plcM, plcS, plcMS);
									print(plcH + "hr " + plcM + "min " + plcS + "sec " + plcMS + "msec Now we do each channel 32");
								}
								selectWindow(id + frame);
								if (PrintLikeCrazy) {
									getDateAndTime(NAV, NAV, NAV, NAV, plcH, plcM, plcS, plcMS);
									print(plcH + "hr " + plcM + "min " + plcS + "sec " + plcMS + "msec Now we do each channel 33");
								}
								run("Select None"); 
								setMinAndMax(min, max);
								if (bitDepth() == 8) {
									run("Apply LUT", "stack");
								} else {
									run("8-bit");
								}
								if (PrintLikeCrazy) {
									getDateAndTime(NAV, NAV, NAV, NAV, plcH, plcM, plcS, plcMS);
									print(plcH + "hr " + plcM + "min " + plcS + "sec " + plcMS + "msec Now we do each channel 34");
								}
								MakeProjections(id + frame); //Files are closed and saved!!!!!!!!!

								IntervalFilter = 0;
								if (frame / PauseInterval == floor(frame / PauseInterval)) {
									IntervalFilter = 1;
								}
								Temp = floor(frame / PauseInterval) + 1;
								FramesUntillPause = Temp * PauseInterval - frame; //bpm

								if (WindowForPause && IntervalFilter) {
									TheOtherWindow = getTitle;
									selectWindow("Pause");
									setLocation(VisibleX, VisibleY);
									selectWindow(TheOtherWindow);
									wait(TimeForPause);										
									if (getTitle == "Pause") {
										waitForUser("You just pressed PAUSE" + "\n" + "\n" + "press OK to continue \n \n \n ((or drag this window to upper left quadrant if you want to change certain settings ");
										// if user drags the pause window to upper left...
										selectWindow("Pause");
										getLocationAndSize(xPauseWindow, yPause, dummy, dummy);
										if (xPauseWindow < 0.3 * screenWidth && yPause < 0.3 * screenHeight) {
											OutputArray = newArray;
											OutputArray[0] = "save as separate movies";
											OutputArray[1] = "merge in one movie"; //bp40
											Dialog.create("Dialog Identifier XX1");
												Spacing = 20;
												Dialog.setInsets(0, 10, 0);
												Dialog.addCheckbox("Processing Windows in upper left", UpperLeft);
												Dialog.setInsets(Spacing, 10, 0);
												Dialog.addCheckbox("SaveProgressToNetwork", SaveProgressToNetwork);
												Dialog.setInsets(Spacing, 10, 0);
												Dialog.addCheckbox("Window For Pause", WindowForPause);
												Dialog.setInsets(0, 10, 0);
												Dialog.addNumber("Time For Pause", TimeForPause);
												Dialog.setInsets(0, 10, 0);
												Dialog.addNumber("Pause Interval", PauseInterval);
												Dialog.setInsets(0, 10, 0);
												Dialog.addNumber("Garbage Interval", GarbageInterval);
												Dialog.setInsets(0, 0, 0);
												Dialog.addMessage(" ");
												Dialog.setInsets(0, 10, 0);
												Dialog.addString("LUT bar left or top ?", PlaceScaleBarZ);
												Dialog.setInsets(Spacing, 10, 0);
												Dialog.addNumber("Correct the Interval ?", Interval);
												if (SplitZ[i] > 0) {
													Dialog.setInsets(20, 0, 0);
													Dialog.addMessage("******************************* ");
													Dialog.setInsets(Spacing, 10, 0);
													Dialog.addRadioButtonGroup("... and the output of these partial analyses ? ", OutputArray, 2, 1, OutputArray[1]); //bp40
													Dialog.setInsets(0, 10, 0);
													Dialog.addCheckbox("analyze BOTH split AND unsplit?", SplitAndUnsplitFill);
												}

											Dialog.show();
												UpperLeft = Dialog.getCheckbox();
												SaveProgressToNetwork = Dialog.getCheckbox();
												WindowForPause = Dialog.getCheckbox();
												TimeForPause = Dialog.getNumber();
												PauseInterval = Dialog.getNumber();
												GarbageInterval = Dialog.getNumber();
												PlaceScaleBarZ = Dialog.getString();
												Interval = Dialog.getNumber();
												if (SplitZ[i] > 0) {
													OutputButton = Dialog.getRadioButton(); //bp37 en hieronder
													if (OutputButton == OutputArray[0]) {
														PileUpChunks[i] = 0;
													}
													if (OutputButton == OutputArray[1]) {
														PileUpChunks[i] = 1;
													}
													SplitAndUnsplitFill = Dialog.getCheckbox();
												}

										}
									}
									selectWindow("Pause");
									setLocation(screenWidth, VisibleY);
								}
								selectWindow("Log");

								close(id + frame);

								GarbageFilter = 0;
								if (frame / GarbageInterval == floor(frame / GarbageInterval)) {
									GarbageFilter = 1;
								}
								if (GarbageFilter) {
									run("Collect Garbage");
								} //RO BP	
								if (PrintLikeCrazy) {
									getDateAndTime(NAV, NAV, NAV, NAV, plcH, plcM, plcS, plcMS);
									print(plcH + "hr " + plcM + "min " + plcS + "sec " + plcMS + "msec Now we do each channel 36");
								}
								//bp34
								QueueText = "";
								if (RunAllQueued) {
									QueueText = "Q : #" + Exp + " of " + nExp + " queued experiments ";
								}
								SplitZPrintText = "";
								if (SplitZ[i] > 0) {
									SplitZPrintText = "\n SplitZ : chunk #" + Chunk + " (of " + nChunks + " ) ";
								} //bp30 en hieronder natuurlijk
								if (NowDoTheUnsplit) {
									SplitZPrintText = "\n just done SplitZ : now whole Z-stack";
								}
								PauseText = "";
								if (WindowForPause) {
									PauseText = " \n \n until next pause window : " + FramesUntillPause;
								}
								print(" \n \n \n " + QueueText + " \n Position:" + PositionNumber[i] + " ( " + i + 1 + " of " + PositionNumber.length + " ) " + SplitZPrintText + " \n --> frame " + frame + " -van- " + LastTimepointTemp + "" + PauseText);
								print("");
								print(""); //bp		if(PrintLikeCrazy){getDateAndTime(NAV, NAV, NAV, NAV, plcH, plcM, plcS, plcMS); print(plcH+"hr "+plcM+"min "+plcS+"sec "+plcMS+"msec Now we do each channel 37");}
							} //End of usechannel
						} //End of channel loop

						//ALL, SAV PROGRESS TO NETWORK
						if (SaveProgressToNetwork) {
							if (PrintLikeCrazy) {
								getDateAndTime(NAV, NAV, NAV, NAV, plcH, plcM, plcS, plcMS);
								print(plcH + "hr " + plcM + "min " + plcS + "sec " + plcMS + "msec SAV PROGRESS TO NETWORK 1");
							}
							newImage("Progress", "16-bit white", 800, 300, 1);
							setColor("black");
							setFont("SansSerif", 25, "bold antialiased");
							getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec); //Gets time 
							month = month + 1; //for some reason my computer saw august as 7 !?!
							if (hour < 10) hour = "0" + hour;
							if (minute < 10) minute = "0" + minute;
							if (second < 10) second = "0" + second; //Adds a 0 if the number is below 10 (esthetics...)
							drawString("That was: Position " + i + " of: " + AmountOfPositions, 10, 40);
							drawString("Position number in LIF file :" + PositionNumber[i], 10, 80);
							// ##DB## in above line I cleared a plus from the following line, cause it probably would result in an error (even though it was present in old version): 
							// drawString("Position number in LIF file :" + PositionNumber[i] + , 10, 80);
							if (CheckPositionName) drawString("Name: " + PositionName[i], 10, 80);
							drawString("Timepoint: " + frame + " of:" + LastTimepointTemp, 10, 120);
							drawString("Time of day: " + hour + ":" + minute + "," + second + "s " + dayOfMonth + "/" + month + "/" + year, 10, 160);
							drawString("Previous Timepoint was at: " + oldhour + ":" + oldminute + "," + oldsecond + "s " + olddayOfMonth + "/" + oldmonth + "/" + oldyear, 10, 200);
							saveAs("Tiff", NetworkDirectory + "Progress.tif");
							oldhour = hour;
							oldminute = minute;
							oldsecond = second;
							olddayOfMonth = dayOfMonth;
							oldmonth = month;
							oldyear = year;
							close();
							if (PrintLikeCrazy) {
								getDateAndTime(NAV, NAV, NAV, NAV, plcH, plcM, plcS, plcMS);
								print(plcH + "hr " + plcM + "min " + plcS + "sec " + plcMS + "msec SAV PROGRESS TO NETWORK 2");
							}
						} //End of SaveProgressToNetwork
						//if(RunAllQueued){run("Collect Garbage");}
					}

				} //End of timepoints loop	

				for (j = 0; j < PositionChannelAmount[i]; j++) {
					c = j;
					if (TransmittedChannelNumber[i] == c) {
						UseChannel[c] = 1;
					}
					if (UseChannel[c]) {} else {
						selectWindow("Temp_" + ChannelName[c]);
						close();
						if (PrintLikeCrazy) {
							getDateAndTime(NAV, NAV, NAV, NAV, plcH, plcM, plcS, plcMS);
							print(plcH + "hr " + plcM + "min " + plcS + "sec " + plcMS + "msec SAV PROGRESS TO NETWORK 3");
						}
					}
				}
				print("10e test");
				//ALL, MERGE TIMEPOINTS 	//bp37

				for (j = 0; j < PositionChannelAmount[i]; j++) {
					c = j;
					if (TransmittedChannelNumber[i] == c) {
						UseChannel[c] = 0;
					}
					if (PrintLikeCrazy) {
						getDateAndTime(NAV, NAV, NAV, NAV, plcH, plcM, plcS, plcMS);
						print(plcH + "hr " + plcM + "min " + plcS + "sec " + plcMS + "msec MERGE TIMEPOINTS 1");
					}
					if (UseChannel[c]) {
						if (PrintLikeCrazy) {
							getDateAndTime(NAV, NAV, NAV, NAV, plcH, plcM, plcS, plcMS);
							print(plcH + "hr " + plcM + "min " + plcS + "sec " + plcMS + "msec MERGE TIMEPOINTS 2");
						}
						selectWindow("Temp_" + ChannelName[c]);
						close(); //Close Hyperstack for each channel
						run("Image Sequence...", "open=[" + TempDisk + ":\\ANALYSIS DUMP\\TEMP DUMP\\MaxProjectTemp_1.tif] number=" + LastTimepointTemp + " file=MaxProjectTemp_" + c + " convert_to_rgb sort");
						if (PrintLikeCrazy) {
							getDateAndTime(NAV, NAV, NAV, NAV, plcH, plcM, plcS, plcMS);
							print(plcH + "hr " + plcM + "min " + plcS + "sec " + plcMS + "msec MERGE TIMEPOINTS 3");
						}
						run("RGB Color");
						rename(ChannelName[c]);
						run("Image Sequence...", "open=[" + TempDisk + ":\\ANALYSIS DUMP\\TEMP DUMP\\GlowTemp_1.tif] number=" + LastTimepointTemp + " file=GlowTemp_" + c + " convert_to_rgb sort");
						if (PrintLikeCrazy) {
							getDateAndTime(NAV, NAV, NAV, NAV, plcH, plcM, plcS, plcMS);
							print(plcH + "hr " + plcM + "min " + plcS + "sec " + plcMS + "msec MERGE TIMEPOINTS 4");
						}
						rename(ChannelName[c] + "Glow");
						GLOW = getTitle();
						if (ColourName) {
							DrawText(GLOW, ChannelName[c], TextSize, ChannelColour[c]);
						} //bp37							if(PrintLikeCrazy){getDateAndTime(NAV, NAV, NAV, NAV, plcH, plcM, plcS, plcMS); print(plcH+"hr "+plcM+"min "+plcS+"sec "+plcMS+"msec MERGE TIMEPOINTS 5");}

						if (UseDepthcoding == "With") {
							if (PrintLikeCrazy) {
								getDateAndTime(NAV, NAV, NAV, NAV, plcH, plcM, plcS, plcMS);
								print(plcH + "hr " + plcM + "min " + plcS + "sec " + plcMS + "msec MERGE TIMEPOINTS 6");
							}
							run("Image Sequence...", "open=[" + TempDisk + ":\\ANALYSIS DUMP\\TEMP DUMP\\DepthTemp_0.tif] number=" + LastTimepointTemp + " file=DepthTemp_" + c + " convert_to_rgb sort");
							if (PrintLikeCrazy) {
								getDateAndTime(NAV, NAV, NAV, NAV, plcH, plcM, plcS, plcMS);
								print(plcH + "hr " + plcM + "min " + plcS + "sec " + plcMS + "msec MERGE TIMEPOINTS 7");
							}
							rename(ChannelName[c] + "Depth");
							DEPTH = getTitle();
							if (ColourName) {
								DrawText(DEPTH, "Depth", TextSize, "White");
							}
							if (PrintLikeCrazy) {
								getDateAndTime(NAV, NAV, NAV, NAV, plcH, plcM, plcS, plcMS);
								print(plcH + "hr " + plcM + "min " + plcS + "sec " + plcMS + "msec MERGE TIMEPOINTS 8");
							}
							if (AddScaleBar) {
								DrawScaleBar(DEPTH, ColorTime, TextSize);
							}
						}
						run("Collect Garbage");
						if (PrintLikeCrazy) {
							getDateAndTime(NAV, NAV, NAV, NAV, plcH, plcM, plcS, plcMS);
							print(plcH + "hr " + plcM + "min " + plcS + "sec " + plcMS + "msec MERGE TIMEPOINTS 9");
						}
					} //End of usechannel
					if (PrintLikeCrazy) {
						getDateAndTime(NAV, NAV, NAV, NAV, plcH, plcM, plcS, plcMS);
						print(plcH + "hr " + plcM + "min " + plcS + "sec " + plcMS + "msec MERGE TIMEPOINTS 10");
					}
				} //End of channel loop

				print("11e test");
				//bp3737

				if (nChunks > 1 && PileUpChunks[i] == 1) {
					for (j = 0; j < PositionChannelAmount[i]; j++) {
						c = j;
						if (TransmittedChannelNumber[i] == c) {
							UseChannel[c] = 0;
						} //waitForUser("1287");														if(PrintLikeCrazy){getDateAndTime(NAV, NAV, NAV, NAV, plcH, plcM, plcS, plcMS); print(plcH+"hr "+plcM+"min "+plcS+"sec "+plcMS+"msec MERGE TIMEPOINTS 1");}
						if (UseChannel[c]) {
							selectWindow(ChannelName[c]);
							run("Duplicate...", "title=[BackupChunkProjection" + Chunk + "] duplicate");
							if (Chunk < nChunks) {
								Shift = (Chunk + 1) * 70;
								setLocation(screenWidth - Shift, 0.5 * screenHeight + Shift);
							} //	waitForUser("chunk<nChunks... ne GLOW veilig gezet... 8bit? \n \n en is de GLOW ook RGB ?");
							if (Chunk == nChunks) {
								getDimensions(dummy, dummy, dummy, slicesTemp, framesTemp);
								framesTempOriginal = framesTemp;
								if (slicesTemp > framesTemp) {
									framesTemp = slicesTemp;
								} //	waitForUser("framesTemp corrected : "+framesTemp+"__framesTempOriginal__"+framesTempOriginal);
								ConcatString = " title=Concatenated";
								for (n = 0; n < nChunks; n++) {
									ConcatString = ConcatString + " image" + n + 1 + "=BackupChunkProjection" + n + 1;
								}
								ConcatString = ConcatString + " image" + n + 1 + "=[-- None --]"; //waitForUser(ConcatString);
								run("Concatenate...", ConcatString); //	waitForUser("recorder !??");
								selectWindow("Concatenated");
								run("Stack to Hyperstack...", "order=xyctz channels=1 slices=" + nChunks + " frames=" + framesTemp + " display=Color");
								selectWindow("Concatenated");
								run("Z Project...", "projection=[Max Intensity] all");
								rename("Projected Chunks"); //	waitForUser("z-projected??");
								selectWindow("Concatenated");
								close();
								selectWindow(ChannelName[c]);
								close();
								selectWindow("Projected Chunks");
								rename(ChannelName[c]);

								//////////////////////////////////
								//	TO SOLVE THE RIDICULOUS PROBLEM OF THE MERGING (RESULTED IN JUST 1 FRAME instead of whole timelapse)
								selectWindow(ChannelName[c]);
								run("Duplicate...", "title=[Tester4] duplicate range=" + framesTemp + "-" + framesTemp);
								selectWindow(ChannelName[c]);
								setSlice(framesTemp);
								run("Delete Slice");
								run("Concatenate...", " title=[VeryTemp] image1=[" + ChannelName[c] + "] image2=[Tester4] image3=[-- None --]");
								selectWindow("VeryTemp");
								rename(ChannelName[c]);
							}
						}
					}
				}
				//bp37

				print("12e test");

				// ===========================================================That was all channels=============================
				// ===========================================================That was all channels=============================

				//==============================================Now we make the combined window an save as AVI===============================

				//ALL, COMBINE THE CHANNELS AND TRANS/DEPTHCODING

				if (SplitZ[i] == 0) {
					Offset = parseFloat(BottomZ[i]);
				} // offset defined as plane, below which ALL is deleted anyhow
				if (SplitZ[i] > 0) {
					Offset = parseFloat(BottomZ_1[i]);
				}

				StartZ = (parseFloat(BottomZApply) - Offset) * ArrayZResolution[i];
				EndZ = (parseFloat(TopZApply) - Offset) * ArrayZResolution[i];

				if (TransmittedChannelPresent) {
					c = TransmittedChannelNumber[i];
					open(TempDisk + ":\\ANALYSIS DUMP\\TEMP DUMP\\Temp_Trans.tif");
					rename(ChannelName[c]);
				}
				if (PrintLikeCrazy) {
					getDateAndTime(NAV, NAV, NAV, NAV, plcH, plcM, plcS, plcMS);
					print(plcH + "hr " + plcM + "min " + plcS + "sec " + plcMS + "msec COMBINE THE CHANNELS AND TRANS/DEPTHCODING 1");
				}

				T = newArray("blank");
				if (TransmittedChannelPresent) {
					c = TransmittedChannelNumber[i];
					T = Array.concat(T, ChannelName[c]);
					UseChannel[c] = 0;
				}
				if (PrintLikeCrazy) {
					getDateAndTime(NAV, NAV, NAV, NAV, plcH, plcM, plcS, plcMS);
					print(plcH + "hr " + plcM + "min " + plcS + "sec " + plcMS + "msec COMBINE THE CHANNELS AND TRANS/DEPTHCODING 2");
				}
				for (array = 0; array < UseChannel.length; array++) {

					if (UseChannel[array]) {
						T = Array.concat(T, ChannelName[array]);
					}
					if (PrintLikeCrazy) {
						getDateAndTime(NAV, NAV, NAV, NAV, plcH, plcM, plcS, plcMS);
						print(plcH + "hr " + plcM + "min " + plcS + "sec " + plcMS + "msec COMBINE THE CHANNELS AND TRANS/DEPTHCODING 3");
					}
				}
				// this makes an array with the different imagenames (makes it easier to call in the next part.
				print("arrayT: ");
				Array.print(T);
				NumberOfCh = T.length - 1;
				if (TransmittedChannelPresent) {
					c = TransmittedChannelNumber[i];
					UseChannel[c] = 1;
				}
				if (PrintLikeCrazy) {
					getDateAndTime(NAV, NAV, NAV, NAV, plcH, plcM, plcS, plcMS);
					print(plcH + "hr " + plcM + "min " + plcS + "sec " + plcMS + "msec COMBINE THE CHANNELS AND TRANS/DEPTHCODING 4");
				}

				// the merging !!
				if (NumberOfCh != 1) {
					MergeTrans_BGYR(ChannelName);
				}

				if (isOpen("Projected Chunks")) {
					selectWindow("Projected Chunks");
					close();
				} // die is alleen open bij als Chunk==nChunks
				print("NumberOfCh: " + NumberOfCh);
				if (PrintLikeCrazy) {
					getDateAndTime(NAV, NAV, NAV, NAV, plcH, plcM, plcS, plcMS);
					print(plcH + "hr " + plcM + "min " + plcS + "sec " + plcMS + "msec COMBINE THE CHANNELS AND TRANS/DEPTHCODING 5");
				}
				if (PauseAfterSettings) {
					wait(1000 + RunAllQueued * 1000);
				}
				if (Singletimepoint[i] == 1) AddTime = false;
				print(AddTime);

				print("NumberOfCh " + NumberOfCh);
				print("nChunks " + nChunks);
				print("UseDepthcoding " + UseDepthcoding);
				print("PileUpChunks[i] " + PileUpChunks[i]);

				// waitForUser("{kijk effe (voor kritieke stuk))");
				print("160225-TEST 01");

				if (RunAllQueued) {
					run("Collect Garbage");
				}

				if (NumberOfCh == 1 && nChunks == 1) {
					print("160225-TEST 02");
					selectWindow(T[1]);
					close();
					if (UseDepthcoding == "With") {
						if (PrintLikeCrazy) {
							getDateAndTime(NAV, NAV, NAV, NAV, plcH, plcM, plcS, plcMS);
							print(plcH + "hr " + plcM + "min " + plcS + "sec " + plcMS + "msec COMBINE THE CHANNELS AND TRANS/DEPTHCODING 6");
						}
						if (AddTime) {
							TimeWindow = T[1] + "Glow";
							DrawTime(TimeWindow, Interval, TextSize, ColorTime);
						}
						if (PrintLikeCrazy) {
							getDateAndTime(NAV, NAV, NAV, NAV, plcH, plcM, plcS, plcMS);
							print(plcH + "hr " + plcM + "min " + plcS + "sec " + plcMS + "msec COMBINE THE CHANNELS AND TRANS/DEPTHCODING 7");
						}
						run("Combine...", "stack1=[" + T[1] + "Depth] stack2=[" + T[1] + "Glow]");
						if (PrintLikeCrazy) {
							getDateAndTime(NAV, NAV, NAV, NAV, plcH, plcM, plcS, plcMS);
							print(plcH + "hr " + plcM + "min " + plcS + "sec " + plcMS + "msec COMBINE THE CHANNELS AND TRANS/DEPTHCODING 8");
						}
						rename("END");
						if (AddScaleBarZLeft) {
							selectWindow("END");
							DrawScaleZLeft("END", StartZ, EndZ, TextSize, "White");
						} //RO corrected mistake in EndZ!
						if (AddScaleBarZTop) {
							selectWindow("END");
							DrawScaleZTop("END", StartZ, EndZ, TextSize, "White");
						}
						print("160225-TEST 03");

					} else {
						print("160225-TEST 04");
						if (AddTime) {
							TimeWindow = T[1] + "Glow";
							DrawTime(TimeWindow, Interval, TextSize, ColorTime);
						}
						if (PrintLikeCrazy) {
							getDateAndTime(NAV, NAV, NAV, NAV, plcH, plcM, plcS, plcMS);
							print(plcH + "hr " + plcM + "min " + plcS + "sec " + plcMS + "msec COMBINE THE CHANNELS AND TRANS/DEPTHCODING 9");
						}
						run("Combine...", "stack1=[" + T[1] + "Glow] stack2=MergedRGBTY");
						rename("END");
						if (PrintLikeCrazy) {
							getDateAndTime(NAV, NAV, NAV, NAV, plcH, plcM, plcS, plcMS);
							print(plcH + "hr " + plcM + "min " + plcS + "sec " + plcMS + "msec COMBINE THE CHANNELS AND TRANS/DEPTHCODING 10");
						}
					}
				}
				print("160225-TEST 05");

				//////////////////////////////////////////////////////////////
				//bp37 dit hele stuk gekoppiepeest en aangepast
				if (NumberOfCh == 1 && nChunks > 1 && PileUpChunks[i] && UseDepthcoding == "With") {
					print("160225-TEST 06");
					if (AddTime) {
						TimeWindow = T[1] + "Glow";
						DrawTime(TimeWindow, Interval, TextSize, ColorTime);
					}
					if (PrintLikeCrazy) {
						getDateAndTime(NAV, NAV, NAV, NAV, plcH, plcM, plcS, plcMS);
						print(plcH + "hr " + plcM + "min " + plcS + "sec " + plcMS + "msec COMBINE THE CHANNELS AND TRANS/DEPTHCODING 7");
					}
					run("Combine...", "stack1=[" + T[1] + "Depth] stack2=[" + T[1] + "Glow]");
					rename("END");
					if (PrintLikeCrazy) {
						getDateAndTime(NAV, NAV, NAV, NAV, plcH, plcM, plcS, plcMS);
						print(plcH + "hr " + plcM + "min " + plcS + "sec " + plcMS + "msec COMBINE THE CHANNELS AND TRANS/DEPTHCODING 8");
					}
					if (AddScaleBarZLeft) {
						selectWindow("END");
						SidebarSize = DrawScaleZLeft("END", StartZ, EndZ, TextSize, "White");
					} //RO corrected mistake in EndZ!
					if (AddScaleBarZTop) {
						selectWindow("END");
						DrawScaleZTop("END", StartZ, EndZ, TextSize, "White");
					}
					rename("END_chunk_" + Chunk);
					print("160225-TEST 07");
					if (Chunk < nChunks) {
						selectWindow("END_chunk_" + Chunk);
						run("Select None");
						Shift = 70 * (Chunk + 1);
						setLocation(screenWidth - Shift, Shift);
						wait(700);
						run("Collect Garbage");
						if (isOpen(T[1])) {
							selectWindow(T[1]);
							close();
						}
						print("160225-TEST 08 getTitle = " + getTitle);
					}
					if (Chunk == nChunks) {
						print("160225-TEST 09 getTitle = " + getTitle);
						if (nChunks == 2) {
							run("Combine...", "stack1=[END_chunk_2] stack2=[END_chunk_1] combine");
							rename("All Depths");
						}
						if (nChunks == 3) {
							run("Combine...", "stack1=[END_chunk_3] stack2=[END_chunk_2] combine");
							rename("TempTop");
							run("Combine...", "stack1=[TempTop] stack2=[END_chunk_1] combine");
							rename("All Depths");
						}
						rename("All Depths");
						rename("END");
						print("160225-TEST 10 getTitle = " + getTitle);
					}
					if (isOpen(T[1])) {
						selectWindow(T[1]);
						close();
					}
					if (isOpen(T[1] + "Glow")) {
						selectWindow(T[1] + "Glow");
						close();
					}
					if (isOpen(T[1] + "Depth")) {
						selectWindow(T[1] + "Depth");
						close();
					}
					print("160225-TEST 11 getTitle = " + getTitle);
				}

				if (NumberOfCh == 1 && nChunks > 1 && PileUpChunks[i] == 0 && UseDepthcoding == "With") {
					// in dit geval die 2 aan elkaar lassen en wegsaven ; ongeacht welke Chunk																											print("160225-TEST 06");
					if (AddTime) {
						TimeWindow = T[1] + "Glow";
						DrawTime(TimeWindow, Interval, TextSize, ColorTime);
					}
					if (PrintLikeCrazy) {
						getDateAndTime(NAV, NAV, NAV, NAV, plcH, plcM, plcS, plcMS);
						print(plcH + "hr " + plcM + "min " + plcS + "sec " + plcMS + "msec COMBINE THE CHANNELS AND TRANS/DEPTHCODING 7");
					}
					run("Combine...", "stack1=[" + T[1] + "Depth] stack2=[" + T[1] + "Glow]");
					rename("END");
					if (PrintLikeCrazy) {
						getDateAndTime(NAV, NAV, NAV, NAV, plcH, plcM, plcS, plcMS);
						print(plcH + "hr " + plcM + "min " + plcS + "sec " + plcMS + "msec COMBINE THE CHANNELS AND TRANS/DEPTHCODING 8");
					}
					if (AddScaleBarZLeft) {
						selectWindow("END");
						SidebarSize = DrawScaleZLeft("END", StartZ, EndZ, TextSize, "White");
					} //RO corrected mistake in EndZ!
					if (AddScaleBarZTop) {
						selectWindow("END");
						DrawScaleZTop("END", StartZ, EndZ, TextSize, "White");
					}
					rename("END");
					if (isOpen(T[1])) {
						selectWindow(T[1]);
						close();
					}
					if (isOpen(T[1] + "Glow")) {
						selectWindow(T[1] + "Glow");
						close();
					}
					if (isOpen(T[1] + "Depth")) {
						selectWindow(T[1] + "Depth");
						close();
					}
				}

				//bp37	
				FourQuadrants = 0;
				if (NumberOfCh == 2 && nChunks == 1) {
					FourQuadrants = 1;
					print("160225-TEST 12 getTitle = " + getTitle);
				}
				if (NumberOfCh == 2 && nChunks > 1 && PileUpChunks[i] == 0 && UseDepthcoding == "With") {
					FourQuadrants = 1;
					print("160225-TEST 13 getTitle = " + getTitle);
				}
				print("FourQuadrants " + FourQuadrants);

				//bp37	

				if (FourQuadrants) { //bp37			
					print("160225-TEST 14 getTitle = " + getTitle);
					if (UseDepthcoding == "With") {
						if (TransmittedChannelPresent) {
							open(TempDisk + ":\\ANALYSIS DUMP\\TEMP DUMP\\Temp_Trans.tif");
							run("RGB Color");
							rename(T[1]);
							TimeChannel = T[1];
						} else {
							T[1] = T[1] + "Glow";
							TimeChannel = "MergedRGBTY";
						}

						if (AddTime) {
							DrawTime(TimeChannel, Interval, TextSize, ColorTime);
						}
						run("Combine...", "stack1=[" + T[2] + "Depth] stack2=[" + T[2] + "Glow]");
						rename("top");
						if (AddScaleBarZLeft) {
							selectWindow("top");
							SidebarSize = DrawScaleZLeft("top", StartZ, EndZ, TextSize, "White");
						} //RO corrected mistake in range!
						if (AddScaleBarZTop) {
							selectWindow("top");
							DrawScaleZTop("top", StartZ, EndZ, TextSize, "White");
						} //RO corrected mistake in range!
						run("Combine...", "stack1=[" + T[1] + "] stack2=MergedRGBTY");
						rename("bottom");
						if (AddScaleBarZLeft) {
							selectWindow("bottom");
							AddSideBar("bottom", SidebarSize);
						}
						run("Combine...", "stack1=top stack2=bottom combine");
						rename("END");
					} else {
						if (AddTime) {
							DrawTime("MergedRGBTY", Interval, TextSize, ColorTime);
						}
						run("Combine...", "stack1=[" + T[2] + "Glow] stack2=MergedRGBTY");
						rename("END");
					}
				}

				//bp37 dit hele stuk gekoppiepeest en aangepast
				if (NumberOfCh == 2 && nChunks > 1 && PileUpChunks[i] && UseDepthcoding == "With") {
					print("160225-TEST 15 getTitle = " + getTitle);
					if (TransmittedChannelPresent) {
						open(TempDisk + ":\\ANALYSIS DUMP\\TEMP DUMP\\Temp_Trans.tif");
						run("RGB Color");
						rename(T[1]);
						TimeChannel = T[1];
					} else {
						T[1] = T[1] + "Glow";
						TimeChannel = "MergedRGBTY";
					}

					if (AddTime) {
						DrawTime(TimeChannel, Interval, TextSize, ColorTime);
					}
					run("Combine...", "stack1=[" + T[2] + "Depth] stack2=[" + T[2] + "Glow]");
					rename("top");
					if (AddScaleBarZLeft) {
						selectWindow("top");
						SidebarSize = DrawScaleZLeft("top", StartZ, EndZ, TextSize, "White");
					}
					if (AddScaleBarZTop) {
						selectWindow("top");
						DrawScaleZTop("top", StartZ, EndZ, TextSize, "White");
					}
					rename("top_chunk_" + Chunk);
					if (Chunk < nChunks) {
						selectWindow("top_chunk_" + Chunk);
						run("Select None");
						Shift = 70 * (Chunk + 1);
						setLocation(screenWidth - Shift, Shift);
						wait(700);
						run("Collect Garbage");
						if (isOpen(T[1])) {
							selectWindow(T[1]);
							close();
						}
						if (isOpen("MergedRGBTY")) {
							selectWindow("MergedRGBTY");
							close();
						}
					}
					if (Chunk == nChunks) {
						run("Combine...", "stack1=[" + T[1] + "] stack2=MergedRGBTY");
						rename("bottom");
						if (AddScaleBarZLeft) {
							selectWindow("bottom");
							AddSideBar("bottom", SidebarSize);
						} // gaat wsl nog mis met ScaleBarLeft...
						if (nChunks == 2) {
							run("Combine...", "stack1=[top_chunk_2] stack2=[top_chunk_1] combine");
							rename("All Depths");
						}
						if (nChunks == 3) {
							run("Combine...", "stack1=[top_chunk_3] stack2=[top_chunk_2] combine");
							rename("TempTop");
							run("Combine...", "stack1=[TempTop] stack2=[top_chunk_1] combine");
							rename("All Depths");
						}
						run("Combine...", "stack1=[All Depths] stack2=bottom combine");
						rename("END");
					}
				}
				print("160225-TEST 16 getTitle = " + getTitle);

				////////////////////////////////////////////////////////////////////////////////////////////////////////
				////////////////////////////////////////////////////////////////////////////////////////////////////////No depthcoding with more than 2 channels so no scalebar!
				////////////////////////////////////////////////////////////////////////////////////////////////////////

				if (NumberOfCh == 3) {
					if (TransmittedChannelPresent) {
						open(TempDisk + ":\\ANALYSIS DUMP\\TEMP DUMP\\Temp_Trans.tif");
						run("RGB Color");
						rename(T[1]);
						TimeChannel = T[1];
					} else {
						T[1] = T[1] + "Glow";
						TimeChannel = "MergedRGBTY";
					}
					print("160225-TEST 17 getTitle = " + getTitle);
					if (AddTime) {
						DrawTime(TimeChannel, Interval, TextSize, ColorTime);
					}
					run("Combine...", "stack1=[" + T[2] + "Glow] stack2=[" + T[3] + "Glow]");
					rename("top");
					run("Combine...", "stack1=[" + T[1] + "] stack2=MergedRGBTY");
					rename("bottom");
					run("Combine...", "stack1=top stack2=bottom combine");
					rename("END");
				}
				if (NumberOfCh == 4) {
					if (AddTime) {
						DrawTime("MergedRGBTY", Interval, TextSize, ColorTime);
					}
					print("160225-TEST 18 ");
					run("Combine...", "stack1=[" + T[2] + "Glow] stack2=[" + T[3] + "Glow]");
					rename("top");
					run("Combine...", "stack1=[" + T[4] + "Glow] stack2=MergedRGBTY");
					rename("bottom");
					run("Combine...", "stack1=top stack2=bottom combine");
					rename("END");
				}
				if (NumberOfCh == 5) {
					if (TransmittedChannelPresent) {
						open(TempDisk + ":\\ANALYSIS DUMP\\TEMP DUMP\\Temp_Trans.tif");
						run("RGB Color");
						rename(T[1]);
						TimeChannel = T[1];
					} else {
						T[1] = T[1] + "Glow";
						TimeChannel = "MergedRGBTY";
					}

					if (AddTime) {
						DrawTime(TimeChannel, Interval, TextSize, ColorTime);
					}
					run("Combine...", "stack1=[" + T[5] + "Glow] stack2=[" + T[4] + "Glow]");
					rename("topTemp");
					run("Combine...", "stack1=topTemp stack2=[" + T[1] + "]");
					rename("top");
					run("Combine...", "stack1=[" + T[3] + "Glow] stack2=[" + T[2] + "Glow]");
					rename("bottomTemp");
					run("Combine...", "stack1=bottomTemp stack2=MergedRGBTY");
					rename("bottom");
					run("Combine...", "stack1=top stack2=bottom combine");
					rename("END");
				}
				if (NumberOfCh == 6) {
					if (AddTime) {
						DrawTime("MergedRGBTY", Interval, TextSize, ColorTime);
					}
					run("Combine...", "stack1=[" + T[6] + "Glow] stack2=[" + T[5] + "Glow]");
					rename("topTemp");
					run("Combine...", "stack1=topTemp stack2=[" + T[4] + "Glow]");
					rename("top");
					run("Combine...", "stack1=[" + T[3] + "Glow] stack2=[" + T[2] + "Glow]");
					rename("bottomTemp");
					run("Combine...", "stack1=bottomTemp stack2=MergedRGBTY");
					rename("bottom");
					run("Combine...", "stack1=top stack2=bottom combine");
					rename("END");
				}
				//waitForUser("NumberOfCh: "+NumberOfCh); 
				if (NumberOfCh == 7) {
					if (TransmittedChannelPresent) {
						open(TempDisk + ":\\ANALYSIS DUMP\\TEMP DUMP\\Temp_Trans.tif");
						run("RGB Color");
						rename(T[1]);
						TimeChannel = T[1];
					} else {
						T[1] = T[1] + "Glow";
						TimeChannel = "MergedRGBTY";
					}

					if (AddTime) {
						DrawTime("MergedRGBTY", Interval, TextSize, ColorTime);
					}
					run("Combine...", "stack1=[" + T[7] + "Glow] stack2=[" + T[6] + "Glow]");
					rename("topTemp");
					run("Combine...", "stack1=topTemp stack2=[" + T[5] + "Glow]");
					rename("top");
					run("Combine...", "stack1=[" + T[4] + "Glow] stack2=[" + T[3] + "Glow]");
					rename("middleTemp");
					run("Combine...", "stack1=middleTemp stack2=[" + T[2] + "Glow]");
					rename("middle");
					run("Combine...", "stack1=[" + T[1] + "] stack2=Merged-T");
					rename("bottomTemp");
					run("Combine...", "stack1=bottomTemp stack2=MergedRGBTY");
					rename("bottom");
					run("Combine...", "stack1=top stack2=middle combine");
					rename("ENDtemp");
					run("Combine...", "stack1=ENDtemp stack2=bottom combine");
					rename("END");
				}

				print("160225-TEST 19 ");
				// adapt ASPECT RATIO
				if (AspectChoice != AspectArray[0]) {
					selectWindow("END");
					getDimensions(xTemp, yTemp, dummy, dummy, dummy);
					Larger = maxOf(xTemp, yTemp);
					Smaller = minOf(xTemp, yTemp);
					if (AspectChoice == AspectArray[1]) {
						run("Canvas Size...", "width=" + Larger + " height=" + Larger + " position=Center");
					}
					if (AspectChoice == AspectArray[2]) {
						if ((4 / 3) * yTemp >= xTemp) {
							AspectHeight = yTemp;
							AspectWidth = (4 / 3 * yTemp);
						}
						if ((4 / 3) * yTemp < xTemp) {
							AspectWidth = xTemp;
							AspectHeight = (3 / 4 * xTemp);
						}
						run("Canvas Size...", "width=" + AspectWidth + " height=" + AspectHeight + " position=Center");
					}
					if (AspectChoice == AspectArray[3]) {
						if ((16 / 9) * yTemp >= xTemp) {
							AspectHeight = yTemp;
							AspectWidth = (16 / 9 * yTemp);
						}
						if ((16 / 9) * yTemp < xTemp) {
							AspectWidth = xTemp;
							AspectHeight = (9 / 16 * xTemp);
						}
						run("Canvas Size...", "width=" + AspectWidth + " height=" + AspectHeight + " position=Center");
					}
				}

				// additions to the File Name
				ScaleBarText = "";
				if (AddScaleBar && WriteBarDimensions == 0) {
					ScaleBarText = " (Scalebar_" + nMicronsScaleBarArray[i] + "_mu)";
				}

				SplitZText = ""; //bp37
				if (SplitZ[i] > 0 && PileUpChunks[i] == 1) {
					SplitZText = "_(Z-stack split up in " + nChunks + " parts)";
				}
				if (SplitZ[i] > 0 && PileUpChunks[i] == 0) {
					ArraySplitIn2 = newArray("_(Lowest of 2 chunks)", "_(Highest of 2 chunks)");
					ArraySplitIn3 = newArray("_(Lowest of 3 chunks)", "_(Middle of 3 chunks)", "_(Highest of 3 chunks)");
					if (SplitZ[i] == 2) {
						SplitZText = ArraySplitIn2[Chunk - 1];
					}
					if (SplitZ[i] == 3) {
						SplitZText = ArraySplitIn3[Chunk - 1];
					}
				}
				if (NowDoTheUnsplit) {
					SplitZText = "_(whole Z-stack)";
				} // this ocurs only when ... etc

				print("160225-TEST 20");
				//bp37
				SaveAvi = 0;
				if (SplitZ[i] == 0) {
					SaveAvi = 1;
				}
				if (SplitZ[i] > 0 && PileUpChunks[i] == 0) {
					SaveAvi = 1;
				}
				if (SplitZ[i] > 0 && PileUpChunks[i] == 1 && Chunk == nChunks) {
					SaveAvi = 1;
				} //	waitForUser("saving??? "+SaveAvi+"___SplitZ[i]__"+SplitZ[i]+"___PileUpChunks[i]__"+PileUpChunks[i]+"___Chunk__"+Chunk+"__nChunks___"+nChunks);

				if (Singletimepoint[i] != 1) {
					if (DefineFrameRate) {}
					if (DefineAviLength) {
						FrameRateAvi = round(LastTimepointTemp / AviLength);
					}
				}

				print("160225-TEST 21 ");
				if (SaveAvi) {
					selectWindow("END"); //bp37
					print("160225-TEST 22 ");
					if (CheckPositionName == 0) {
						AddPositionName = 0;
					}
					if (AddPositionName) {
						if (PrintLikeCrazy) {
							getDateAndTime(NAV, NAV, NAV, NAV, plcH, plcM, plcS, plcMS);
							print(plcH + "hr " + plcM + "min " + plcS + "sec " + plcMS + "msec COMBINE THE CHANNELS AND TRANS/DEPTHCODING 30");
						}
						if (Singletimepoint[i] == 1 && SingleTPtoZstack != 1) {
							run("Delete Slice");
							saveAs("Jpeg", "" + OutputDisk + ":\\ANALYSIS DUMP\\" + Q + "Exp" + Exp + "\\" + Date + " " + NameExperiment + " Position " + PositionNumber[i] + " - " + PositionName[i] + SplitZText + ScaleBarText + ".jpg");
							PRINT = getTitle();
							rename("END");
						} else {
							exportFinalProduct();
						}
						if (PrintLikeCrazy) {
							getDateAndTime(NAV, NAV, NAV, NAV, plcH, plcM, plcS, plcMS);
							print(plcH + "hr " + plcM + "min " + plcS + "sec " + plcMS + "msec COMBINE THE CHANNELS AND TRANS/DEPTHCODING 31");
						}
					} else {
						if (Singletimepoint[i] == 1 && SingleTPtoZstack != 1) {
							run("Delete Slice");
							saveAs("Jpeg", "" + OutputDisk + ":\\ANALYSIS DUMP\\" + Q + "Exp" + Exp + "\\" + Date + " " + NameExperiment + " Position " + PositionNumber[i] + " - " + PositionName[i] + SplitZText + ScaleBarText + ".jpg");
							PRINT = getTitle();
							rename("END");
						} else {
							exportFinalProduct();
						}
						if (PrintLikeCrazy) {
							getDateAndTime(NAV, NAV, NAV, NAV, plcH, plcM, plcS, plcMS);
							print(plcH + "hr " + plcM + "min " + plcS + "sec " + plcMS + "msec COMBINE THE CHANNELS AND TRANS/DEPTHCODING 32");
						}
					}
					//bp37 
					//selectWindow("END");
					//print("Saved: [" + OutputDisk + ":\\ANALYSIS DUMP\\" + Q + "Exp" + Exp + "\\" + PRINT + "]");
					if (PrintLikeCrazy) {
						getDateAndTime(NAV, NAV, NAV, NAV, plcH, plcM, plcS, plcMS);
						print(plcH + "hr " + plcM + "min " + plcS + "sec " + plcMS + "msec COMBINE THE CHANNELS AND TRANS/DEPTHCODING 33");
					}
					CloseIndeed = 1;
					if (CloseIndeed) {
						close();
					}
					run("Collect Garbage");

					//ALL, SAVE PROGRESS FILE FOR RESTART
					newImage("Progress", "16-bit white", 800, 300, 1);
					if (PrintLikeCrazy) {
						getDateAndTime(NAV, NAV, NAV, NAV, plcH, plcM, plcS, plcMS);
						print(plcH + "hr " + plcM + "min " + plcS + "sec " + plcMS + "msec COMBINE THE CHANNELS AND TRANS/DEPTHCODING 34");
					}
					setColor("black");
					setFont("SansSerif", 25, "bold antialiased");
					getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec); //Gets time 
					month = month + 1; //for some reason my computer saw august as 7 !?!
					if (hour < 10) hour = "0" + hour;
					if (minute < 10) minute = "0" + minute;
					if (second < 10) second = "0" + second; //Adds a 0 if the number is below 10 (esthetics...)
					drawString("That was: Position " + PositionNumber[i], 10, 40);
					if (CheckPositionName) drawString("Name:" + PositionName[i], 10, 80);
					drawString("Time of day: " + hour + ":" + minute + "," + second + "s " + dayOfMonth + "/" + month + "/" + year, 10, 120);
					List.set("Progress", i);
					list = List.getList();
					setMetadata("info", list);
					saveAs("Tiff", TempDisk + ":\\ANALYSIS DUMP\\" + Q + "Exp" + WhereToSaveSettings + "\\Settings\\Progress.tif");
					close();
					if (PrintLikeCrazy) {
						getDateAndTime(NAV, NAV, NAV, NAV, plcH, plcM, plcS, plcMS);
						print(plcH + "hr " + plcM + "min " + plcS + "sec " + plcMS + "msec COMBINE THE CHANNELS AND TRANS/DEPTHCODING 35");
					}

				} // vd if(SaveAvi //bp37
				// waitForUser("{kijk effe (na kritieke stuk))");
			} // vd for(Chunk=0
		} // vd if(Skip

		if (SplitZ[i] > 0 && SplitAndUnsplit[i] == 1 && UnsplitStillToDo) {
			UnsplitStillToDo = 0;
			NowDoTheUnsplit = 1;
			RememberSplitZ = SplitZ[i];
			SplitZ[i] = 0; // en hierdoor gaat-i de volgende ronde de boel niet opdelen
			i = i - 1;
			z = z - 1; // en deze organoid nog een keer herhalen, dus i 1 omlaag halen
		} //bp37
		else {
			//bp37			// hier kom je alleen binnen als je eerst de chunks en daarna de hele Z-stack ook hebt gedaan (agv SplitAndUnsplit)
			if (SplitAndUnsplit[i] == 1 && UnsplitStillToDo == 0) {
				SplitZ[i] = RememberSplitZ;
				UnsplitStillToDo = 1;
				NowDoTheUnsplit = 0;
			}
		} //waitForUser("__NowDoTheUnsplit_"+NowDoTheUnsplit+"__UnsplitStillToDo_"+UnsplitStillToDo);

	} // vd for(z=StartFromi									//End of position loop

	//ALL, SAVE PROGRESS TO NETWORK
	if (SaveProgressToNetwork) {
		if (PrintLikeCrazy) {
			getDateAndTime(NAV, NAV, NAV, NAV, plcH, plcM, plcS, plcMS);
			print(plcH + "hr " + plcM + "min " + plcS + "sec " + plcMS + "msec COMBINE THE CHANNELS AND TRANS/DEPTHCODING 36");
		}
		newImage("Progress", "16-bit white", 800, 300, 1);
		setColor("black");
		setFont("SansSerif", 25, "bold antialiased");
		getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec); //Gets time 
		month = month + 1; //for some reason my computer saw august as 7 !?!
		if (hour < 10) hour = "0" + hour;
		if (minute < 10) minute = "0" + minute;
		if (second < 10) second = "0" + second; //Adds a 0 if the number is below 10 (esthetics...)
		drawString("That was it! Macro suddesfully completed!", 10, 40);
		drawString("Positions completed: " + AmountOfPositions, 10, 80);
		drawString("Time of day finished: " + hour + ":" + minute + "," + second + "s " + dayOfMonth + "/" + month + "/" + year, 10, 160);
		saveAs("Tiff", NetworkDirectory + "Progress.tif");
		oldhour = hour;
		oldminute = minute;
		oldsecond = second;
		olddayOfMonth = dayOfMonth;
		oldmonth = month;
		oldyear = year;
		close();
	} //										End of SaveProgressToNetwork				

	if (isOpen("Pause")) {
		selectWindow("Pause");
		close();
	}

	//bp41		//TempDisk="F";Date=150223;NameExperiment="jaja";Q="";Exp=1;
	if (File.exists(TempDisk + ":\\ANALYSIS DUMP\\Settings\\Settings Archive\\")) {
		ArchivePath = ":\\ANALYSIS DUMP\\Settings\\Settings Archive\\" + Date + "_" + NameExperiment + "\\";
		if (File.exists(TempDisk + ArchivePath)) {
			MakeExtraFolder = 1;
		} else {
			MakeExtraFolder = 0;
		}

		Counter = 1;
		while (MakeExtraFolder) {
			Counter = Counter + 1;
			ArchivePath = ":\\ANALYSIS DUMP\\Settings\\Settings Archive\\" + Date + "_" + NameExperiment + "_(#" + d2s(Counter, 0) + ")\\";
			if (File.exists(TempDisk + ArchivePath)) {} else {
				MakeExtraFolder = 0;
			}
		}
		File.makeDirectory(TempDisk + ArchivePath);

		ArchiveFileName = "Settings_of_" + Date + "_" + NameExperiment + ".tif";
		open(TempDisk + ":\\ANALYSIS DUMP\\" + Q + "Exp" + Exp + "\\Settings\\Settings_Exp" + Exp + ".tif");
		saveAs("Tiff", TempDisk + ArchivePath + ArchiveFileName);
		close();
	}

	//if(RunAllQueued){
	QueueFinished = 0;
	if (Exp == nExp) {
		QueueFinished = 1;
	}
	RunAllQueuedString = "RunAllQueued_" + RunAllQueued + " current_Exp_" + Exp + " ; nExp_" + nExp + " ; QueueFinished_" + QueueFinished;
	File.saveString(RunAllQueuedString, TempDisk + ":\\ANALYSIS DUMP\\RunAllQueue-info.txt");
	//}

	if (QueueMultiple == 0) {
		waitForUser(" Klaar! ");
		FinalJoke();
		exit(" Klaar! ");
	}
	//bpx
	if (RunAllQueued) {
		run("Collect Garbage");
	}

} // vd for(Exp=1 ; Exp<nExp+1 ; Exp++){		// deze for-loop gaat over de GEHELE macro !!!

if (RunAllQueued) {
	//TempDisk="F";
	QueueString = "QueueMultiple_0 ; nQueuedExp_0";
	File.saveString(QueueString, TempDisk + ":\\ANALYSIS DUMP\\Queue-info.txt");
	print("*****************process mode finished");
	print("CURRENT TIME -", makeDateOrTimeString("time"));

	// close macro
	closeTheseWindows = newArray("ROI Manager","Results");
	for(i = 0; i < closeTheseWindows.length; i++){
		current_check = closeTheseWindows[i];
		if (isOpen (current_check) ){
			selectWindow(current_check);
			run("Close");
		}
	}
	while (isOpen("Exception")){
		selectWindow("Exception");
		run("Close");
	}
	print("input arguments used for experiment: ");
	for(i = 0; i < input_arguments.length; i++){
		print("input argument " + i + ": " + input_arguments[i]);
	}

	// print settings and save Log for future reference
	selectWindow("Log");
	currdate = makeDateOrTimeString("D");
	currtime = makeDateOrTimeString("T");
	print("CURRENT TIME -", currtime);
	currtime = replace(currtime,":","");
	savetextfile = image_output_location + prefix + "_" + currdate + "_" + currtime + "_Settings.txt";
	savetextfile = replace(savetextfile,"__","_");
	saveAs("Text", savetextfile);	
	
	waitForUser(" Klaar! \n \n All (Cute) Queued Experiments Processed !! ");
	FinalJoke();
	//exit(" Klaar! \n \n All (Cute) Queued Experiments Processed !! ");
}

//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++END OF MACRO!!!!!!!!!!!!!!!!!!!++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++END OF MACRO!!!!!!!!!!!!!!!!!!!++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++END OF MACRO!!!!!!!!!!!!!!!!!!!++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++END OF MACRO!!!!!!!!!!!!!!!!!!!++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++END OF MACRO!!!!!!!!!!!!!!!!!!!++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++END OF MACRO!!!!!!!!!!!!!!!!!!!++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++END OF MACRO!!!!!!!!!!!!!!!!!!!++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++END OF MACRO!!!!!!!!!!!!!!!!!!!++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++END OF MACRO!!!!!!!!!!!!!!!!!!!++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++END OF MACRO!!!!!!!!!!!!!!!!!!!++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++END OF MACRO!!!!!!!!!!!!!!!!!!!++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++END OF MACRO!!!!!!!!!!!!!!!!!!!++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++END OF MACRO!!!!!!!!!!!!!!!!!!!++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++END OF MACRO!!!!!!!!!!!!!!!!!!!++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++END OF MACRO!!!!!!!!!!!!!!!!!!!++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++END OF MACRO!!!!!!!!!!!!!!!!!!!++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

// ==================== The Macro has already stopped! Everything below this line is to define functions (which are required for the macro to function!===================
// =======================================================================================================================================================================

// =======================================================================================================================================================================
// =======================================================================================================================================================================
// =======================================================================================================================================================================
// =======================================================================================================================================================================
// =======================================================================================================================================================================
// =======================================================================================================================================================================
// =======================================================================================================================================================================
// =======================================================================================================================================================================
// =======================================================================================================================================================================
// =======================================================================================================================================================================
// =======================================================================================================================================================================
// =======================================================================================================================================================================
// =======================================================================================================================================================================
// =======================================================================================================================================================================
// =======================================================================================================================================================================
// =======================================================================================================================================================================
// =======================================================================================================================================================================
// =======================================================================================================================================================================
// =======================================================================================================================================================================
// =======================================================================================================================================================================
// =======================================================================================================================================================================

// define splitZslice		
function splitZslice(title, UitgekozenZplaneVoorTransmitted) {
	selectWindow(title);
	Stack.setPosition(1, UitgekozenZplaneVoorTransmitted, 1);
	run("Reduce Dimensionality...", " frames");
}

// define cropToROI		
function cropToROI(title) {
	selectWindow(title);
	makeRectangle(ROIx1, ROIy1, ROIx2, ROIy2);
	run("Crop");
}

//define make rectangle and select halfway Z
//define make rectangle and select halfway Z
function drawROI(title) {
	selectWindow(title);
	run("Select None");
	getDimensions(x, y, ch, nZplanes, NumberOfFrames);
	ZHalfwayStack = round(0.5 * nZplanes);
	print("ZHalfwayStack : " + ZHalfwayStack);
	// make rectangle 
	XCoordinate = round(0.1 * x);
	YCoordinate = round(0.1 * y);
	Width = round(0.8 * x);
	Height = round(0.8 * y);
	makeRectangle(XCoordinate, YCoordinate, Width, Height);
}

function TimeProjectionOnTransmitted(title, slice) {

	test1 = 0;
	if (test1) {
		waitForUser("start function");
	}
	test2 = 0;
	if (test2) {
		wait(400);
	}
	test3 = 0;
	if (test3) {
		run("Collect Garbage");
	}
	test4 = 0;
	if (test4) {
		wait(500);
		run("Collect Garbage");
	}

	selectWindow(title);
	run("Select None");
	if (testWait) {
		wait(ms);
	}
	getDimensions(dummy, dummy, dummy, nZplanes, nTimepoints);
	if (testWait) {
		wait(ms);
	}
	//RO 0704	waitForUser("slice : "+slice+"___nZplanes___"+nZplanes);
	Step = floor(nTimepoints / nFramesForTimeProject);
	SubstackString = "";
	Comma = ",";
	for (i = 0; i < nFramesForTimeProject; i++) {
		NextFrame = 1 + i * Step;
		if (i == nFramesForTimeProject - 1) {
			Comma = "";
		}
		SubstackString = SubstackString + d2s(NextFrame, 0) + Comma;
	}
	wait(200);
	selectWindow(title);
	run("Make Substack...", "slices=" + slice + " frames=" + SubstackString);
	rename("Substack");
	if (testWait) {
		wait(ms);
	}
	run("Z Project...", "projection=[Sum Slices]");
	rename(title + "_Time-Projected");
	selectWindow("Substack");
	close();
	if (testWait) {
		wait(ms);
	}
	selectWindow(title);
	Stack.setPosition(1, slice, TIMEPOINTS);
	if (testWait) {
		wait(ms);
	}
	if (test1) {
		waitForUser("END function");
	}

}

//define subtract background function
//define subtract background function
function substractDeadMask(TitleDead, TitleNuclei) {
	setBatchMode(Hidewindows);
	selectWindow(TitleNuclei);
	Zstack = nSlices();
	for (i = 1; i < Zstack; i++) {
		selectWindow(TitleDead);
		setSlice(i);
		run("Create Selection");
		selectWindow(TitleNuclei);
		setSlice(i);
		run("Restore Selection");
		run("Clear", "slice");
	}
	close(TitleDead);
	setBatchMode(false);
}

// define removeNoise
// define removeNoise		Median Blur removes some noise, without blurring too much.
function removeNoise(Title) {
	setBatchMode(Hidewindows);
	setBatchMode(Hidewindows);
	selectWindow(Title);
	run("Median...", "radius=0.7 stack");
	setBatchMode(false);
}

// define Ch2Mask	
// define Ch2Mask	Thresholding Ch2 Image for substraction		//first get, save and load cutoff	DeadMask(TitleDead)		substractDeadMask(TitleDead,TitleNuclei)
function DeadMask(TitleDead, cutoff) {
	setBatchMode(Hidewindows);
	selectWindow(TitleDead);
	setThreshold(cutoff, 255);
	run("Convert to Mask", "method=Default background=Dark");
	setBatchMode(false);
}

// define splitTimepoints
// define splitTimepoints
function splitTimepoint(Title, Start, End) {
	setBatchMode(Hidewindows);
	selectWindow(Title);
	id = getTitle(); // remember the original hyperstack

	for (frame = Start; frame <= End; frame++) { // for each frame...
		selectImage(id); // select the frame
		Stack.setPosition(1, 1, frame);
		run("Reduce Dimensionality...", "channels slices keep"); // extract one frame
		rename(Title + "_" + frame);
		cropToROI(Title + "_" + frame);
		print(Title + "_" + frame + " -van- " + End);
		setBatchMode(false);
	}
}

//	Delete slices first x for Ch2 last x for Ch4 not used at the moment
function CorrectZ(ChromaticAberration) {
	setBatchMode(Hidewindows);
	for (amount = 1; amount <= ChromaticAberration; amount++) {
		selectWindow(TitleCh2);
		setSlice(1);
		run("Delete Slice");
		selectWindow(TitleCh4);
		getDimensions(dummy, dummy, dummy, Z, dummy);
		setSlice(Z);
		run("Delete Slice");
	}
	setBatchMode(false);
}

function RemoveBottomZ(Title) {
	setBatchMode(Hidewindows);
	for (amount = 1; amount <= DeleteBottomZ; amount++) {
		selectWindow(Title);
		setSlice(1);
		run("Delete Slice");
	}
	setBatchMode(false);
}

function RemoveTopZ(Title) {
	setBatchMode(Hidewindows);
	for (amount = 1; amount <= DeleteTopZ; amount++) {
		selectWindow(Title);

		getDimensions(dummy, dummy, dummy, Z, dummy);
		setSlice(Z);
		run("Delete Slice");
	}
	setBatchMode(false);
}

// Define Make projections// Define Make projections
// Define Make projections
function MakeProjections(Title) {
	setBatchMode(Hidewindows);
	selectWindow(Title);
	Zstack = nSlices();
	selectWindow(Title);
	run("Select None");

	//bp21
	if (SplitZ[i] == 0) {
		GammaCorrApply = GammaCorr[i];
		MultiplyApply = MultiplyBeforeDepthcoding[i];
	}
	if (SplitZ[i] > 0 && Chunk == 1) {
		GammaCorrApply = GammaCorr_1[i];
		MultiplyApply = MultiplyBeforeDepthcoding_1[i];
	}
	if (SplitZ[i] > 0 && Chunk == 2) {
		GammaCorrApply = GammaCorr_2[i];
		MultiplyApply = MultiplyBeforeDepthcoding_2[i];
	}
	if (SplitZ[i] > 0 && Chunk == 3) {
		GammaCorrApply = GammaCorr_3[i];
		MultiplyApply = MultiplyBeforeDepthcoding_3[i];
	}

	run("Gamma...", "value=" + GammaCorrApply + " stack");
	run("Duplicate...", "title=[glow] duplicate range=1-" + Zstack);
	//}
	if (SkipGlow) {} else {
		run("The Real Glow");
	}

	run("Z Project...", "start=1 stop=" + Zstack + " projection=[Max Intensity]");
	run("RGB Color");

	rename("Glow" + Title);
	saveAs(TempDisk + ":\\ANALYSIS DUMP\\TEMP DUMP\\" + getTitle() + ".tif");
	close();
	selectWindow("glow");
	close();
	if (UseDepthcoding == "With") {
		selectWindow(Title);
		run("Select None");
		run("Duplicate...", "title=[" + Title + "_temp] duplicate");
		selectWindow(Title + "_temp");
		run("Multiply...", "value=" + MultiplyApply + " stack");
		run("Temporal-Color Code", "lut=[Depth Organoid]");
		rename("Depth" + Title);
		saveAs(TempDisk + ":\\ANALYSIS DUMP\\TEMP DUMP\\" + getTitle() + ".tif");
		close();
		selectWindow(Title + "_temp");
		close();
	}
	selectWindow(Title);
	run("Select None");
	run("RGB Color");
	run("Z Project...", "start=1 stop=" + Zstack + " projection=[Max Intensity]");
	rename("MaxProject" + Title);

	saveAs(TempDisk + ":\\ANALYSIS DUMP\\TEMP DUMP\\" + getTitle() + ".tif");
	close();
	selectWindow(Title);
	close();
	setBatchMode(false);
}

// Define MergeTimepoint// Define MergeTimepoint
// Define MergeTimepoint
function MergeTimepoint(title, start, end) {
	//setBatchMode(Hidewindows);
	open(TempDisk + ":\\ANALYSIS DUMP\\TEMP DUMP\\[" + title + "_" + start + ".tif]");
	selectImage(title + "_" + start + ".tif");
	rename(title + "_" + start);
	getDimensions(width, height, channelCount, sliceCount, frameCount);
	for (image = 1; image < (end); image++) {
		open(TempDisk + ":\\ANALYSIS DUMP\\TEMP DUMP\\[" + title + "_" + (image + start) + ".tif]");
		run("Concatenate...", "stack1=[" + title + "_" + (image + start - 1) + "] stack2=[" + title + "_" + (image + start) + ".tif]" + " title=[" + title + "_" + start + image + "]");
		print("en dat was" + image + start + "van" + end);
	}
	rename(title);
	run("Stack to Hyperstack...", "order=xyczt(default) channels=" + channelCount + " slices=" + sliceCount + " frames=" + end + " display=Color");
	print(title + " frames=" + end);
	setBatchMode(false);
	saveAs(TempDisk + ":\\ANALYSIS DUMP\\TEMP DUMP\\" + getTitle() + ".tif");
}

// Define splitTimepoint with jump in Z and T this is part to reduce the dimensionality (for brightness and threshold purposes...// this is part to reduce the dimensionality (for brightness and threshold purposes...
function splitZplaneTemp(Title, JumpZ) {
	setBatchMode(Hidewindows);
	selectWindow(Title);
	id = getImageID(); // remember the original hyperstack
	getDimensions(dummy, dummy, dummy, Slices, Timepoints); // we need to know only how many frames there are
	run("Collect Garbage");
	toclose = 0;
	ConcatenateString = " title=[ConcatenatedStacks] ";
	for (frame = 1; frame <= Slices; frame++) { // for each frame...
		selectImage(id); // select the frame
		Stack.setPosition(1, frame, 1);
		run("Reduce Dimensionality...", "channels frames keep");
		rename(Title + frame);
		run("Z Project...", "start=1 stop=" + Timepoints + " projection=[Max Intensity]");
		rename("Temp_" + frame);
		selectWindow(Title + frame);
		rename("ToClose");
		close();
		ConcatenateString = ConcatenateString + " image" + frame + "=Temp_" + frame;
	}
	ConcatenateString = ConcatenateString + " image" + frame + 1 + "=[-- None --]"; //print(ConcatenateString);
	run("Concatenate...", ConcatenateString);

	rename("TEMP_0");
	ConcatenateString = "image1=TEMP_0";
	//setBatchMode(false);
	for (i = 1; i < Timepoints; i++) {
		selectWindow("TEMP_0");
		run("Duplicate...", "title=[TEMP_" + i + "] duplicate");
		ConcatenateString = ConcatenateString + " image" + i + 1 + "=TEMP_" + i;
	}
	ConcatenateString = ConcatenateString + " image" + i + 1 + "=[-- None --]"; //print(ConcatenateString);
	run("Concatenate...", " title=[ConcatenatedStacks] " + ConcatenateString);
	// and make it Hyperstack
	run("Stack to Hyperstack...", "order=xyczt(default) channels=1 slices=" + Slices + " frames=" + Timepoints + " display=Color");
	selectWindow("ConcatenatedStacks");
	rename("Zselection" + Title); //exit();
	RETURN = getTitle();
	return RETURN;
	setBatchMode(false);
}

function splitTimepointTemp(Title, JumpT, JumpZ, Reduce) {
	setBatchMode(Hidewindows);
	selectWindow(Title);
	id = getImageID(); // remember the original hyperstack
	getDimensions(dummy, dummy, dummy, Slices, nFrames); // we need to know only how many frames there are
	ConcatenateString = " title=[" + Title + "_Temp] ";
	image = 1; //rename(Title+"_Temp");
	if (Singletimepoint[i] == 1) {
		LastTimepointTemp = nFrames;
	} //waitForUser(" ");
	for (frame = 1; frame <= LastTimepointTemp; frame += JumpT) { // for each frame...

		selectImage(id); // select the frame
		Stack.setPosition(1, 1, frame);
		run("Reduce Dimensionality...", "channels slices keep"); // extract one frame

		run("Reduce...", "reduction=" + JumpZ);
		ReducedTP = 0; //ReducedTP+1;
		rename(Title + "_" + frame);
		getDimensions(dummy, dummy, dummy, Slices, dummy);
		cropToROI(Title + "_" + frame);
		print(Title + "_" + frame + " -van- " + LastTimepointTemp);

		ConcatenateString = ConcatenateString + " image" + image + "=[" + Title + "_" + frame + "]";
		image = image + 1;
		//
	}
	ConcatenateString = ConcatenateString + " image" + image + "=[-- None --]"; //print(ConcatenateString);

	run("Concatenate...", ConcatenateString);
	run("Stack to Hyperstack...", "order=xyczt(default) channels=1 slices=" + Slices + " frames=" + image - 1 + " display=Color");
	selectWindow(Title + "_Temp");
	setBatchMode(false);
	RETURN = getTitle();
	return RETURN;
	close();
}
// this is part to reduce the dimensionality (for brightness and threshold purposes...

// Define MergeTimepoint temp blocks For reduction purposes
function MergeTimepointTemp(title, JumpT) {
	setBatchMode(Hidewindows);

	open(TempDisk + ":\\ANALYSIS DUMP\\" + Q + "Exp" + Exp + "\\Settings\\NumberOfTempblocks.tif");
	run("Brightness/Contrast...");
	getMinAndMax(ReducedTP, dummy);
	close();
	print("ReducedTP=" + ReducedTP);
	selectImage(title + "_" + 1);
	getDimensions(width, height, channelCount, sliceCount, frameCount);
	for (image = JumpT; image < LastTimepointTemp; image += JumpT) {
		run("Concatenate...", "stack1=[" + title + "_" + 1 + "] stack2=[" + title + "_" + (image + 1) + "] title=[" + title + "_" + 1 + "]");
		print("en dat was" + image + "van" + LastTimepointTemp);
	}
	rename("temp" + title);
	run("Stack to Hyperstack...", "order=xyczt(default) channels=" + channelCount + " slices=" + sliceCount + " frames=" + (ReducedTP) + " display=Color");
	print(title + "frames=" + (LastTimepointTemp));
	setBatchMode(false);
}

function MergeTrans_BGYR(ChannelName) { //bp30
	setBatchMode(Hidewindows);
	if (TransmittedChannelPresent) {
		c = TransmittedChannelNumber[i];
		selectWindow(ChannelName[c]); //run("RGB Color");
		getDimensions(width, height, channelCount, sliceCount, frameCount);
		setMinAndMax(0, 400);
		StartChannel = 1;
		//rename("White");
	} else {
		StartChannel = 0;
	}
	print("ChannelName:");
	Array.print(ChannelName);
	print("ChannelColour:");
	Array.print(ChannelColour);

	for (Merge = 0; Merge < UseChannel.length; Merge++) {
		if (UseChannel[Merge]) {
			selectWindow(ChannelName[Merge]);
			run("8-bit"); //run("Divide...", "value=1.4 stack");
			rename(ChannelColour[Merge]);
		}
	}

	setBatchMode(false);

	Red = "*None*";
	Green = "*None*";
	Blue = "*None*";
	Cyan = "*None*";
	Magenta = "*None*";
	Yellow = "*None*";
	White = "*None*";
	for (j = 0; j < UseChannel.length; j++) {
		if (ChannelColour[j] == "White") {
			White = "White";
		}
		if (ChannelColour[j] == "Blue") {
			Blue = "Blue";
		}
		if (ChannelColour[j] == "Red") {
			Red = "Red";
		}
		if (ChannelColour[j] == "Green") {
			Green = "Green";
		}
		if (ChannelColour[j] == "Cyan") {
			Cyan = "Cyan";
		}
		if (ChannelColour[j] == "Magenta") {
			Magenta = "Magenta";
		}
		if (ChannelColour[j] == "Yellow") {
			Yellow = "Yellow";
		}
	}

	if (NumberOfCh == 7) {
		run("Merge Channels...", "c1=[" + Red + "] c2=[" + Green + "] c3=[" + Blue + "] c4=[" + White + "] c5=[" + Cyan + "] c6=[" + Magenta + "] c7=[" + Yellow + "] create keep ignore ");
		run("Stack to RGB", "slices");
		rename("MergedRGBTY");
		saveAs(TempDisk + ":\\ANALYSIS DUMP\\TEMP DUMP\\" + getTitle() + ".tif");
		White = "*None*";
	}

	run("Merge Channels...", "c1=[" + Red + "] c2=[" + Green + "] c3=[" + Blue + "] c4=[" + White + "] c5=[" + Cyan + "] c6=[" + Magenta + "] c7=[" + Yellow + "] create ignore ");
	run("Stack to RGB", "slices");
	selectWindow("Composite"); //As of may 2015 this is needed. Apparently the new formed image is no longer automatically selected!
	if (NumberOfCh == 7) {
		rename("Merged-T");
	} else {
		rename("MergedRGBTY");
	}

	saveAs(TempDisk + ":\\ANALYSIS DUMP\\TEMP DUMP\\" + getTitle() + ".tif");

	setBatchMode(false);
}

// The PUREDENOISE Plugin is very good!! So in principle we use this one; if not, then we do the good-old MEDIAN Filtering
// Plugin-file required : PureDenoise_.class
function PureDenoise(Title) {
	setBatchMode(Hidewindows);
	selectWindow(Title);
	getDimensions(x, y, ch, z, t);
	setMinAndMax(0, 255);
	run("PureDenoise ", "parameters='" + DenoiseFrameNumber + " " + DenoiseCycleNumber + "' estimation='Auto Global' ");
	rename(Title + "Denoised");
	selectWindow(Title);
	close();
	selectWindow(Title + "Denoised");
	rename(Title);
	// Denoise-Plugin Automatically converted the Hyperstack into a normal Stack, therefore...
	run("Stack to Hyperstack...", "order=xyczt(default) channels=1 slices=" + z + " frames=" + t + " display=Color");
	selectWindow("Nieuwste GroenBlokje");
	run("8-bit");
	setBatchMode(false);
}

function PureDenoiseStack(Title) {
	setBatchMode(Hidewindows);
	selectWindow(Title);
	getDimensions(x, y, ch, z, t);
	setMinAndMax(0, 255);
	run("PureDenoise ", "parameters='" + DenoiseFactor + " " + DenoiseCycleNumber + "' estimation='Auto Global' ");
	rename(Title + "Denoised");
	selectWindow(Title);
	close();
	selectWindow(Title + "Denoised");
	rename(Title);
	selectWindow(Title);
	run("8-bit");
	run("Re-order Hyperstack ...", "channels=[Channels (c)] slices=[Frames (t)] frames=[Slices (z)]");
	getDimensions(x, y, ch, z, t);
	print("ch :" + ch);
	print("z :" + z);
	print("t :" + t);
	setBatchMode(false);
}

function DrawText(Title, Text, Size, Colour) {
	if (TextInGlowIsWhite) Colour = "White";
	setBatchMode(Hidewindows);
	selectWindow(Title);
	setFont("SansSerif", Size, " antialiased");
	setColor(Colour);
	getDimensions(x, y, ch, z, t);
	print("DrawText___" + x + "_" + y + "_" + ch + "_" + t + "_" + z);
	for (i = 0; z > i; i++) {
		setSlice(i + 1);
		drawString(Text, 1, Size + 2);
	}
	setBatchMode(false);
}
// setFont("SansSerif", Size, " antialiased");
// drawString(Text, Xposition, Yposition); 
// Xposition 1=textbox starts at first pixel, text starts later! Should be fine!
// Yposition = bottom of textbox, so 1024 in a 1024x1024 image the text is above the bottom Should be fine!
// Yposition2 to do top shift the textbox down by the Size, this puts the text ~2 pixels below top
// So 1, 35 is top left; 1,512 is bottom left for 512x512 image; 
// work with getDimensions for anything other than top left
// if working on 4-luik 1, ydimension/2 is bottom left top image and 1, ydimension/2 + Size is top bottom image
// both were left image, right image is xdimension/2 (going to the right is tricky due to text size)
// Courier size 50 means 30 pixel per character (independent of which)

function DrawTime(Title, Interval, Size, Colour) {
	setBatchMode(Hidewindows);
	Size = parseFloat(Size);
	selectWindow(Title);
	getDimensions(x, y, ch, t, z);
	print("DrawTime___" + x + "_" + y + "_" + ch + "_" + t + "_" + z);
	if (Interval == round(Interval)) {
		DecimalPlaces = 0;
	} else {
		DecimalPlaces = 1;
	} //bp + figure out, whether to use decimals or not. only when interval had a decimal other than 0
	if (NumberOfCh == 1 && ColourName == 1) {
		yPosition = 2 * Size + 4;
	} else {
		yPosition = Size + 2;
	}
	for (i = 0; t > i; i++) {
		Totaltime = (i) * Interval;
		Hours = floor(Totaltime / 60);
		if (Hours < 10) {
			Hours = "0" + toString(Hours);
		} else {
			Hours = toString(Hours);
		}
		Minutes = Totaltime - Hours * 60;
		if (Minutes < 10) {
			Minutes = "0" + toString(Minutes, DecimalPlaces);
		} else {
			Minutes = toString(Minutes, DecimalPlaces);
		}
		print(Hours + "h " + Minutes + "m");
		Stamp = Hours + "h " + Minutes + "m";

		setSlice(i + 1);
		setFont("SansSerif", Size, " antialiased");
		setColor(Colour);
		drawString(Stamp, 1, yPosition);
	}
	setBatchMode(false);
}

function DrawScaleBar(Title, Colour, Size) {
	setBatchMode(Hidewindows);
	run("Colors...", "foreground=" + Colour); //	waitForUser("Colour_"+Colour);
	selectWindow(Title);
	getDimensions(x, y, ch, z, t);
	tTemp = t;
	zTemp = z;
	if (z > t) {
		t = zTemp;
		z = tTemp;
	}
	print("DrawText___" + x + "_" + y + "_" + ch + "_" + t + "_" + z);
	Y = ScaleBarYArray[i];
	makeLine(MarginForScaleBar, Y, MarginForScaleBar + nPixelsScaleBarArray[i], Y, ScaleBarLineWidth);
	run("Fill", "stack");
	run("Select None");
	if (WriteBarDimensions) {
		Decimals = 0;
		if (nMicronsScaleBarArray[i] != floor(nMicronsScaleBarArray[i])) {
			Decimals = 1;
		}
		Text = d2s(nMicronsScaleBarArray[i], Decimals) + " " + micron;
		print(Text);
		setFont("SansSerif", Size, " antialiased");
		for (h = 0; h < t; h++) {
			setSlice(h + 1);
			drawString(Text, MarginForScaleBar, Y - 1);
		}
	}
	setBatchMode(false);
}

function SetTransmittedBrightness(CurrentWindow) {
	SetBrightness = 150;
	selectWindow(CurrentWindow);
	getDimensions(x, y, ch, z, t);
	Stack.getPosition(channel, slice, frame);
	if (DoSetZ) {
		SetZ = floor(0.7 * z);
		SetFrame = floor(0.5 * t);
		Stack.setPosition(1, SetZ, SetFrame);
	} else {
		Stack.setPosition(1, slice, 0.5 * frame);
	}

	run("Select All");
	run("Duplicate...", "title=temp");
	selectWindow("temp");
	run("Brightness/Contrast...");
	setMinAndMax(1, 255);
	if (bitDepth() == 8) {
		run("Apply LUT", "stack");
	} else {
		run("8-bit");
	} // Appy LUT does not work with 12 bit images?! is you use //run("8-bit"); the image is converted to an 8 bit using the current B&C settings 

	// new april 0215
	Saturated = 0.35;
	resetMinAndMax();
	run("Enhance Contrast", "saturated=" + Saturated);

	run("Measure");
	Mean = getResult("Mean", nResults - 1);
	print("Mean:" + Mean);
	TooDark = SetBrightness - Mean;
	StepsBrightnessCorrection = floor(TooDark / 18);
	print("");
	print("StepsBrightnessCorrection: " + StepsBrightnessCorrection);

	for (i = 0; i < StepsBrightnessCorrection; i++) {
		selectWindow(CurrentWindow);
		getMinAndMax(TempMin, TempMax);
		TempMin = TempMin - 10;
		TempMax = TempMax - 10;
		setMinAndMax(TempMin, TempMax);
	}

	Rest = (TooDark / 18) - StepsBrightnessCorrection;
	print("Rest: " + Rest);
	if (Rest > 0.25) {
		selectWindow(CurrentWindow);
		getMinAndMax(TempMin, TempMax);
		TempMin = TempMin - 5;
		TempMax = TempMax - 5;
		setMinAndMax(TempMin, TempMax);
	}

	for (i = 0; i > StepsBrightnessCorrection; i--) {
		selectWindow(CurrentWindow);
		getMinAndMax(TempMin, TempMax);
		TempMin = TempMin + 10;
		TempMax = TempMax + 10;
		setMinAndMax(TempMin, TempMax);
	}

	Rest = (TooDark / 18) - StepsBrightnessCorrection;
	print("Rest: " + Rest);
	if (Rest < 0.25) {
		selectWindow(CurrentWindow);
		getMinAndMax(TempMin, TempMax);
		TempMin = TempMin + 5;
		TempMax = TempMax + 5;
		setMinAndMax(TempMin, TempMax);
	}

	selectWindow("temp");
	close();
	selectWindow("Results");
	run("Close");
	selectWindow(CurrentWindow);
	setMinAndMax(TempMin, TempMax);
	run("Select All");

	wait(150);
}

function GetLUTColour(Title) {

	selectWindow(Title);
	getLut(r, g, b);
	print("RGB");

	if (r[1]) {
		if (g[1]) {
			if (b[1]) {
				Colour = 0;
			} else {
				Colour = 6;
			}
		} else {
			if (b[1]) {
				Colour = 5;
			} else {
				Colour = 2;
			}
		}
	} else {
		if (g[1]) {
			if (b[1]) {
				Colour = 4;
			} else {
				Colour = 1;
			}
		} else {
			if (b[1]) {
				Colour = 3;
			}
		}
	}

	return (Colour)
}

function DuplicateSingleTimepoint(Title, Colour) {
	getDimensions(w, h, c, z, t);
	selectWindow(Title);
	run("Duplicate...", "title=[" + Title + "0] duplicate range=1-" + z);
	run(Colour);
	wait(100); //RO 0204
	run("Duplicate...", "title=[" + Title + "1] duplicate range=1-" + z);
	run(Colour);
	wait(100);
	selectWindow(Title);
	close();
	run("Concatenate...", " title=[" + Title + "] image1=[" + Title + "0] image2=[" + Title + "1] image3=[-- None --]");
	run("Stack to Hyperstack...", "order=xyczt(default) channels=1 slices=" + z + " frames=2 display=Color");
	selectWindow(Title);
	if (ReOrder) {
		run("Re-order Hyperstack ...", "channels=[Channels (c)] slices=[Frames (t)] frames=[Slices (z)]");
	}
}

function ZlevelOfHighestIntensity(Title) {
	selectWindow(Title);
	Width = getWidth;
	Height = getHeight;
	if (DeleteZStacks && one == 1) {
		makeRectangle(0.5 * Width, 0, 0.5 * Width, Height);
	} else {
		makeRectangle(0, 0, Width, Height);
	}
	Highest = 0;
	for (i = 0; i < ZSLICE; i++) {
		Stack.setPosition(1, i, 0.5 * TIMEPOINTS); // Stack.setPosition(channel, slice, frame) 
		run("Measure");
		Mean = getResult("Mean", nResults - 1);
		if (Mean > Highest) {
			Highest = Mean;
			SliceOfHighestIntensity = i + 1;
		}
	}
	Stack.setPosition(1, SliceOfHighestIntensity, 0.5 * TIMEPOINTS);
	run("Select None");
}

function MakeTilesSingleTimepoint(Title) {
	setBatchMode(Hidewindows);
	selectWindow(Title);
	cropToROI(Title);
	run("Select None");
	Zstack = nSlices();
	selectWindow(Title);
	//waitForUser("1870");
	run("Duplicate...", "title=[glow] duplicate range=1-" + Zstack); //waitForUser("1871");
	run("Gamma...", "value=0.45 stack");
	//waitForUser("1873");
	if (SkipGlow) {} else {
		run("The Real Glow");
	}

	run("RGB Color");
	rename("Glow" + Title);
	saveAs(TempDisk + ":\\ANALYSIS DUMP\\TEMP DUMP\\" + getTitle() + ".tif");
	close();
	//selectWindow("glow");
	//close();

	selectWindow(Title);
	run("Select None");
	run("RGB Color");
	run("Duplicate...", "title=[MaxProject] duplicate range=1-" + Zstack);
	run("Gamma...", "value=0.45 stack");
	rename("MaxProject" + Title); //print("MaxProject"+Title);
	saveAs(TempDisk + ":\\ANALYSIS DUMP\\TEMP DUMP\\" + getTitle() + ".tif");
	close();
	selectWindow(Title);
	close();
	setBatchMode(false);
}

function SwapSelectionToVirtualTransm() {
	selectWindow("TransmittedVirtual_" + PositionNumber[p] + "_Time-Projected");
	run("ROI Manager...");
	roiManager("Add");
	roiManager("Add");
	selectWindow("TransmittedVirtual_" + PositionNumber[p]);
	roiManager("Select", 1);
	roiManager("Select", 1);
	roiManager("Select", 0);
	roiManager("Select", 0);
}

function DrawScaleZLeft(Title, StartZ, EndZ, Size, Colour) {

	setBatchMode(Hidewindows);
	selectWindow(Title);
	getDimensions(x, y, ch, t, z);
	print("DrawText___" + x + "_" + y + "_" + ch + "_" + t + "_" + z);
	Y = ScaleBarYArray[i];
	StartZString = d2s(StartZ, 0) + " " + micron;
	EndZString = d2s(EndZ, 0) + " " + micron;
	TEMPSize = getStringWidth(EndZString);
	SideBar = TEMPSize + 10;
	WIDTH = x + SideBar;
	HeigthLUT = y - (3 * Size + 2) - (y - Y);
	run("Canvas Size...", "width=" + WIDTH + " height=" + y + " position=Top-Right");

	OK = 0;
	ImageJDirectory = getDirectory("imagej");
	if (File.exists(TempDisk + ":\\ANALYSIS DUMP\\Settings\\Depth_Organoid_magenta.tif")) {
		open(TempDisk + ":\\ANALYSIS DUMP\\Settings\\Depth_Organoid_magenta.tif");
		NameLUT = getTitle();
		OK = 1;
	} // print(""); waitForUser("1e OK ? "+OK);
	if (OK == 0 && File.exists(ImageJDirectory + "Depth_Organoid_magenta.tif")) {
		open(ImageJDirectory + "Depth_Organoid_magenta.tif");
		NameLUT = getTitle();
		OK = 1;
	} // print(""); waitForUser("2e OK ? "+OK);

	selectWindow(NameLUT);

	run("Size...", "width=" + Size + " height=" + HeigthLUT + " average interpolation=Bilinear");
	getDimensions(widthSideBar, heightSideBar, dummy, dummy, dummy); //}
	TopLUTBar = (y - heightSideBar) / 2;
	LeftSideBar = (SideBar - widthSideBar) / 2;
	PositionText = (SideBar - TEMPSize) / 2;
	selectWindow(Title);

	for (h = 0; t > h; h++) {
		selectWindow(NameLUT);
		run("Copy");
		selectWindow(Title);
		setSlice(h + 1);
		makeRectangle(LeftSideBar, TopLUTBar, widthSideBar, heightSideBar);
		run("Paste");
		setFont("SansSerif", Size, " antialiased");
		setColor(Colour);
		drawString(EndZString, PositionText, Size + 2);
		drawString(StartZString, PositionText, Y - 1);
	}
	close(NameLUT);
	setBatchMode(false);
	return (WIDTH);
}

function DrawScaleZTop(Title, StartZ, EndZ, Size, Colour) {
	TopBarMargin = 10;
	FractionOfText = 0.7;

	setBatchMode(Hidewindows);
	selectWindow(Title);
	getDimensions(x, y, ch, t, z);
	print("DrawText___" + x + "_" + y + "_" + ch + "_" + t + "_" + z);
	Decimals = 1;
	if (StartZ == 0) {
		Decimals = 0;
	}
	StartZString = d2s(StartZ, Decimals) + " " + micron;
	EndZString = d2s(EndZ, 1) + " " + micron;
	TEMPSize = getStringWidth(EndZString);
	HeightTopBar = Size + TopBarMargin;
	HEIGHT = y + HeightTopBar;
	WidthLUT = 0.5 * x - TEMPSize - getStringWidth(StartZString) - 2 * Size; // Size bij wijze van Marge
	run("Colors...", "background=black");
	run("Canvas Size...", "width=" + x + " height=" + HEIGHT + " position=Bottom-Right zero");

	OK = 0;
	ImageJDirectory = getDirectory("imagej");
	if (File.exists(TempDisk + ":\\ANALYSIS DUMP\\Settings\\Depth_Organoid_magenta.tif")) {
		open(TempDisk + ":\\ANALYSIS DUMP\\Settings\\Depth_Organoid_magenta.tif");
		NameLUT = getTitle();
		OK = 1;
	} //	print(""); waitForUser("1e OK ? "+OK);
	if (OK == 0 && File.exists(ImageJDirectory + "Depth_Organoid_magenta.tif")) {
		open(ImageJDirectory + "Depth_Organoid_magenta.tif");
		NameLUT = getTitle();
	} //	print(""); waitForUser("1e OK ? "+OK);

	run("Rotate 90 Degrees Right");
	selectWindow(NameLUT);

	run("Size...", "width=" + WidthLUT + " height=" + Size * FractionOfText + " average interpolation=Bilinear");
	getDimensions(widthLUTBar, heightLUTBar, dummy, dummy, dummy); //}

	TopLUTBar = 0.5 * HeightTopBar - 0.5 * Size * FractionOfText;
	LeftLUTBar = getStringWidth(StartZString) + Size;
	PositionText = 0.5 * x - TEMPSize - 1;
	YText = 0.5 * HeightTopBar + 0.5 * Size;

	selectWindow(Title);
	for (h = 0; t > h; h++) {
		selectWindow(NameLUT);
		run("Copy");
		selectWindow(Title);
		setSlice(h + 1);
		makeRectangle(LeftLUTBar, TopLUTBar, widthLUTBar, heightLUTBar);
		run("Paste");
		setFont("SansSerif", Size, " antialiased");
		setColor(Colour);
		drawString(StartZString, 1, YText);
		drawString(EndZString, PositionText, YText);
	}
	close(NameLUT);
	setBatchMode(false);
}

function AddSideBar(Title, Size) {
	setBatchMode(Hidewindows);
	selectWindow(Title);
	getDimensions(x, y, ch, z, t);
	print("DrawText___" + x + "_" + y + "_" + ch + "_" + t + "_" + z);
	WIDTH = Size;
	run("Canvas Size...", "width=" + WIDTH + " height=" + y + " position=Top-Right");

	setBatchMode(false);
}

function FinalJoke() {
	print("CURRENT TIME -", makeDateOrTimeString("time"));
	run("Close All");
	JokeInterval = 15;
	nCircleIntervals = 25; // aantal jumps om 1 ronde te maken
	UitwaaierSpeed = 200; // pixels opzij per ronde
	ColorArray = newArray("Grays", "Red", "Green", "Cyan", "Blue", "Yellow", "Magenta");

	newImage("Joke", "8-bit white", 100, 100, 1);
	getDimensions(xJoke, yJoke, dummy, dummy, dummy);
	middleX = 0.5 * screenWidth;
	middleY = 0.5 * screenHeight;
	setLocation(middleX - xJoke, middleY - yJoke);

	Continue = 1;
	Count = 0;
	ColorArrayNumber = 0;
	while (Continue) {
		Count = Count + 1;

		Angle = Count * (2 * PI / nCircleIntervals);
		Radius = Count * (UitwaaierSpeed / nCircleIntervals);
		xLocation = middleX + Radius * cos(Angle);
		yLocation = middleY + Radius * sin(Angle);
		setLocation(xLocation - xJoke, yLocation - yJoke);

		Color = ColorArray[ColorArrayNumber];
		ColorArrayNumber = ColorArrayNumber + 1;
		if (ColorArrayNumber > ColorArray.length - 1) {
			ColorArrayNumber = 0;
		}
		run(Color);

		if (xLocation > 1.1 * screenWidth) {
			Continue = 0;
		}
		wait(JokeInterval);
	}
	selectWindow("Joke");
	close();
}

//bp12
function WriteStatus() {
	StatusString = "Position " + i + 1 + " (of " + PositionNumber.length + ")";
	setFont("SansSerif", 20, " antialiased");
	run("Colors...", "foreground=magenta");
	selectWindow(WhiteScreen);
	drawString(StatusString, 10, 50 + (0.3 * i) * 50);
	StatusWidth = getStringWidth(StatusString);
	return StatusWidth;
}

function SetSettings() {

	List.set("TransmittedChannelPresent", TransmittedChannelPresent);
	List.set("CheckPositionNumber", CheckPositionNumber);
	List.set("CheckPositionName", CheckPositionName);
	List.set("nQueuedExp", nQueuedExp);
	List.set("file", file);
	List.set("CodedFile", CodedFile);
	List.set("ReadFileName", ReadFileName); //bp33
	List.set("maxNumberOfChannels", maxNumberOfChannels);
	List.set("ArraySizeForChannelUseandColour", ArraySizeForChannelUseandColour);
	List.set("Date", Date);
	List.set("NameExperiment", NameExperiment);
	List.set("Interval", Interval);
	List.set("RedDeadDye", RedDeadDye);
	List.set("DeleteZStacks", DeleteZStacks);
	List.set("SetLastTimepoint", SetLastTimepoint);
	List.set("TimeProjectTransm", TimeProjectTransm);
	List.set("ExtendedSettings", ExtendedSettings);
	List.set("UseDepthcoding", UseDepthcoding);
	List.set("NumberOfTPTempStacks", NumberOfTPTempStacks);
	List.set("NumberOfZsTempStacks", NumberOfZsTempStacks);
	List.set("SetMultiplyBeforeDepthcoding", SetMultiplyBeforeDepthcoding);
	List.set("ColourName", ColourName);
	List.set("AddTime", AddTime);
	List.set("AddScaleBar", AddScaleBar);
	List.set("AddScaleBarZ", AddScaleBarZ);
	List.set("PlaceScaleBarZ", PlaceScaleBarZ);
	List.set("FractionForBar", FractionForBar);
	List.set("WriteBarDimensions", WriteBarDimensions);
	List.set("ScaleBarLineWidth", ScaleBarLineWidth);
	List.set("FractionForText", FractionForText);
	List.set("ColorTime", ColorTime);
	List.set("GuidedBC", GuidedBC);
	List.set("UpperLeft", UpperLeft);
	List.set("Hidewindows", Hidewindows);
	List.set("TransmittedChannelPresent", TransmittedChannelPresent);
	List.set("DefaultGamma", DefaultGamma);
	List.set("DefaultMultiply", DefaultMultiply);
	List.set("CheckLastTimepointBlack", CheckLastTimepointBlack);
	List.set("TimeForPause", TimeForPause);
	List.set("PauseInterval", PauseInterval);
	List.set("GarbageInterval", GarbageInterval);
	List.set("SaveProgressToNetwork", SaveProgressToNetwork);
	List.set("TextInGlowIsWhite", TextInGlowIsWhite);
	List.set("WindowForPause", WindowForPause);
	List.set("AmountOfPositions", AmountOfPositions);
	List.set("NucleiChannel", NucleiChannel);
	List.set("DeadChannel", DeadChannel);
	List.set("AspectChoice", AspectChoice);
	List.set("DefineFrameRate", DefineFrameRate);
	List.set("DefineAviLength", DefineAviLength);
	List.set("FrameRateAvi", FrameRateAvi);
	List.set("AviLength", AviLength);

	if (CheckPositionName) {
		List.set("AddPositionName", AddPositionName);
	}
	if (SaveProgressToNetwork) {
		List.set("NetworkDirectory", NetworkDirectory);
		List.set("CodedNetworkDirectory", CodedNetworkDirectory);
	}
	Position = 0;
	for (Channel = 0; Channel < PositionChannelAmount[Position]; Channel++) {
		if (TransmittedChannelNumber[Position] != Channel) {
			List.set("UseChannel" + Channel, UseChannel[Channel]);
			List.set("ChannelColour" + Channel, ChannelColour[Channel]);
			List.set("ChannelName" + Channel, ChannelName[Channel]);

			if (UseChannel[Channel]) {
				List.set("RedDeadChannelUse" + Channel, RedDeadChannelUse[Channel]);
			} else {
				List.set("RedDeadChannelUse" + Channel, "Other");
			}
		} else {
			List.set("UseChannel" + Channel, 0);
			List.set("ChannelColour" + Channel, "White");
			List.set("ChannelName" + Channel, "Trans");
		}
	}
	for (Position = 0; Position < PositionNumber.length; Position++) {
		List.set("PositionNumber" + Position, PositionNumber[Position]);
		List.set("PositionChannelAmount" + Position, PositionChannelAmount[Position]);
		List.set("TransmittedChannelNumber" + Position, TransmittedChannelNumber[Position]);
		List.set("LastTimepointBlack" + Position, LastTimepointBlack[Position]);
		List.set("NumberOfTimepoints" + Position, NumberOfTimepoints[Position]);

		if (CheckPositionName) {
			List.set("PositionName" + Position, PositionName[Position]);
		}

		if (ArraySkipPositions[Position] == 0) {
			List.set("SelectionX1_" + Position, SelectionX1[Position]);
			List.set("SelectionX2_" + Position, SelectionX2[Position]);
			List.set("SelectionY1_" + Position, SelectionY1[Position]);
			List.set("SelectionY2_" + Position, SelectionY2[Position]);
			List.set("TransmittedZslice" + Position, TransmittedZslice[Position]);
			List.set("Singletimepoint" + Position, Singletimepoint[Position]);
			List.set("ArrayZResolution_" + Position, ArrayZResolution[Position]); //RO corrected mistake in range!
			List.set("ScaleBarY_" + Position, ScaleBarYArray[Position]);
			List.set("nPixelsScaleBar_" + Position, nPixelsScaleBarArray[Position]);
			List.set("nMicronsScaleBar_" + Position, nMicronsScaleBarArray[Position]);
			List.set("ArraySkipPositions_" + Position, ArraySkipPositions[Position]);
			List.set("PileUpChunks_" + Position, PileUpChunks[Position]); //bp37
			List.set("SplitAndUnsplit_" + Position, SplitAndUnsplit[Position]); //bp37

			if (SetLastTimepoint) {
				List.set("NumberOfTimepoints" + Position, NumberOfTimepoints[Position]);
			}

			if (RedDeadDye) {
				List.set("Threshold" + Position, Threshold[Position]);
			}

			if (DeleteZStacks) {
				List.set("BottomZ_" + Position, BottomZ[Position]);
				List.set("TopZ_" + Position, TopZ[Position]);
				List.set("SplitZ" + Position, SplitZ[Position]);
				if (SplitZ[Position] > 0) {
					List.set("BottomZ_1_" + Position, BottomZ_1[Position]);
					List.set("TopZ_1_" + Position, TopZ_1[Position]);
					List.set("BottomZ_2_" + Position, BottomZ_2[Position]);
					List.set("TopZ_2_" + Position, TopZ_2[Position]);
				}
				if (SplitZ[Position] == 3) {
					List.set("BottomZ_3_" + Position, BottomZ_3[Position]);
					List.set("TopZ_3_" + Position, TopZ_3[Position]);
				}

				if (UseDepthcoding == "With") {
					List.set("GammaCorr" + Position, GammaCorr[Position]);
					List.set("MultiplyBeforeDepthcoding" + Position, MultiplyBeforeDepthcoding[Position]);
					if (SplitZ[Position] > 0) {
						List.set("GammaCorr_1_" + Position, GammaCorr_1[Position]);
						List.set("MultiplyBeforeDepthcoding_1_" + Position, MultiplyBeforeDepthcoding_1[Position]);
						List.set("GammaCorr_2_" + Position, GammaCorr_2[Position]);
						List.set("MultiplyBeforeDepthcoding_2_" + Position, MultiplyBeforeDepthcoding_2[Position]);
					}
					if (SplitZ[Position] == 3) {
						List.set("GammaCorr_3_" + Position, GammaCorr_3[Position]);
						List.set("MultiplyBeforeDepthcoding_3_" + Position, MultiplyBeforeDepthcoding_3[Position]);
					}
				}

			}
		}
	}
}

function PrintSettings() {
	print("TransmittedChannelPresent: " + TransmittedChannelPresent);
	print("CheckPositionNumber: " + CheckPositionNumber);
	print("CheckPositionName: " + CheckPositionName);
	print("nQueuedExp: " + nQueuedExp);
	print("file: " + file);
	print("CodedFile: " + CodedFile);
	print("ReadFileName: " + ReadFileName); //bp33
	print("maxNumberOfChannels: " + maxNumberOfChannels);
	print("ArraySizeForChannelUseandColour: " + ArraySizeForChannelUseandColour);
	print("Date: " + Date);
	print("NameExperiment: " + NameExperiment);
	print("Interval: " + Interval);
	print("RedDeadDye: " + RedDeadDye);
	print("DeleteZStacks: " + DeleteZStacks);
	print("SetLastTimepoint: " + SetLastTimepoint);
	print("TimeProjectTransm: " + TimeProjectTransm);
	print("ExtendedSettings: " + ExtendedSettings);
	print("UseDepthcoding: " + UseDepthcoding);
	print("NumberOfTPTempStacks: " + NumberOfTPTempStacks);
	print("NumberOfZsTempStacks: " + NumberOfZsTempStacks);
	print("SetMultiplyBeforeDepthcoding: " + SetMultiplyBeforeDepthcoding);
	print("ColourName: " + ColourName);
	print("AddTime: " + AddTime);
	print("AddScaleBar: " + AddScaleBar);
	print("AddScaleBarZ: " + AddScaleBarZ);
	print("PlaceScaleBarZ: " + PlaceScaleBarZ);
	print("FractionForBar: " + FractionForBar);
	print("WriteBarDimensions: " + WriteBarDimensions);
	print("ScaleBarLineWidth: " + ScaleBarLineWidth);
	print("FractionForText: " + FractionForText);
	print("ColorTime: " + ColorTime);
	print("GuidedBC: " + GuidedBC);
	print("UpperLeft: " + UpperLeft);
	print("Hidewindows: " + Hidewindows);
	print("TransmittedChannelPresent: " + TransmittedChannelPresent);
	print("DefaultGamma: " + DefaultGamma);
	print("DefaultMultiply: " + DefaultMultiply);
	print("CheckLastTimepointBlack: " + CheckLastTimepointBlack);
	print("TimeForPause: " + TimeForPause);
	print("PauseInterval: " + PauseInterval);
	print("GarbageInterval: " + GarbageInterval);
	print("SaveProgressToNetwork: " + SaveProgressToNetwork);
	print("TextInGlowIsWhite: " + TextInGlowIsWhite);
	print("WindowForPause: " + WindowForPause);
	print("AmountOfPositions: " + AmountOfPositions);
	print("NucleiChannel: " + NucleiChannel);
	print("DeadChannel: " + DeadChannel);
	print("AspectChoice: " + AspectChoice);
	print("DefineFrameRate: " + DefineFrameRate);
	print("DefineAviLength: " + DefineAviLength);
	print("FrameRateAvi: " + FrameRateAvi);
	print("AviLength: " + AviLength);

	if (CheckPositionName) {
		print("AddPositionName: " + AddPositionName);
	}
	if (SaveProgressToNetwork) {
		print("NetworkDirectory: " + NetworkDirectory);
		print("CodedNetworkDirectory: " + CodedNetworkDirectory);
	}
	Position = 0;
	for (Channel = 0; Channel < PositionChannelAmount[Position]; Channel++) {

		print("UseChannel" + Channel + " : " + UseChannel[Channel]);
		print("ChannelColour" + Channel + " : " + ChannelColour[Channel]);
		print("ChannelName" + Channel + " : " + ChannelName[Channel]);

		print("RedDeadChannelUse" + Channel + " : " + RedDeadChannelUse[Channel]);

	}
	for (Position = 0; Position < PositionNumber.length; Position++) {
		print("PositionNumber" + Position + " : " + PositionNumber[Position]);
		print("PositionChannelAmount" + Position + " : " + PositionChannelAmount[Position]);
		print("TransmittedChannelNumber" + Position + " : " + TransmittedChannelNumber[Position]);
		print("LastTimepointBlack" + Position + " : " + LastTimepointBlack[Position]);
		print("NumberOfTimepoints" + Position + " : " + NumberOfTimepoints[Position]);

		if (CheckPositionName) {
			print("PositionName" + Position + " : " + PositionName[Position]);
		}

		if (ArraySkipPositions[Position] == 0) {
			print("SelectionX1_" + Position + " : " + SelectionX1[Position]);
			print("SelectionX2_" + Position + " : " + SelectionX2[Position]);
			print("SelectionY1_" + Position + " : " + SelectionY1[Position]);
			print("SelectionY2_" + Position + " : " + SelectionY2[Position]);
			print("TransmittedZslice" + Position + " : " + TransmittedZslice[Position]);
			print("Singletimepoint" + Position + " : " + Singletimepoint[Position]);
			print("ArrayZResolution_" + Position + " : " + ArrayZResolution[Position]); //RO corrected mistake in range!
			print("ScaleBarY_" + Position + " : " + ScaleBarYArray[Position]);
			print("nPixelsScaleBar_" + Position + " : " + nPixelsScaleBarArray[Position]);
			print("nMicronsScaleBar_" + Position + " : " + nMicronsScaleBarArray[Position]);
			print("ArraySkipPositions_" + Position + " : " + ArraySkipPositions[Position]);
			print("PileUpChunks_" + Position + " : " + PileUpChunks[Position]); //bp37
			print("SplitAndUnsplit_" + Position + " : " + SplitAndUnsplit[Position]); //bp37

			if (SetLastTimepoint) {
				print("NumberOfTimepoints" + Position + " : " + NumberOfTimepoints[Position]);
			}

			if (RedDeadDye) {
				print("Threshold" + Position + " : " + Threshold[Position]);
			}

			if (DeleteZStacks) {
				print("BottomZ_" + Position + " : " + BottomZ[Position]);
				print("TopZ_" + Position + " : " + TopZ[Position]);
				print("SplitZ" + Position + " : " + SplitZ[Position]);
				if (SplitZ[Position] > 0) {
					print("BottomZ_1_" + Position + " : " + BottomZ_1[Position]);
					print("TopZ_1_" + Position + " : " + TopZ_1[Position]);
					print("BottomZ_2_" + Position + " : " + BottomZ_2[Position]);
					print("TopZ_2_" + Position + " : " + TopZ_2[Position]);
				}
				if (SplitZ[Position] == 3) {
					print("BottomZ_3_" + Position + " : " + BottomZ_3[Position]);
					print("TopZ_3_" + Position + " : " + TopZ_3[Position]);
				}

				if (UseDepthcoding == "With") {
					print("GammaCorr" + Position + " : " + GammaCorr[Position]);
					print("MultiplyBeforeDepthcoding" + Position + " : " + MultiplyBeforeDepthcoding[Position]);
					if (SplitZ[Position] > 0) {
						print("GammaCorr_1_" + Position + " : " + GammaCorr_1[Position]);
						print("MultiplyBeforeDepthcoding_1_" + Position + " : " + MultiplyBeforeDepthcoding_1[Position]);
						print("GammaCorr_2_" + Position + " : " + GammaCorr_2[Position]);
						print("MultiplyBeforeDepthcoding_2_" + Position + " : " + MultiplyBeforeDepthcoding_2[Position]);
					}
					if (SplitZ[Position] == 3) {
						print("GammaCorr_3_" + Position + " : " + GammaCorr_3[Position]);
						print("MultiplyBeforeDepthcoding_3_" + Position + " : " + MultiplyBeforeDepthcoding_3[Position]);
					}
				}

			}
		}
	}
}



///// **************** DB FUNCTIONS BELOW ************************
///// **************** DB FUNCTIONS BELOW ************************
///// **************** DB FUNCTIONS BELOW ************************

function autoCrop(minSize, boundary, endframe) { // DB
	run("Select None");
	// convert minSize (um) to pixel units
	getPixelSize(unit, pixelWidth, pixelHeight);
	minPixSize = minSize / (pixelWidth * pixelHeight);

	// project 4D image into 2D (all slices, all timepoints)
	ori = getTitle();	

	if(endframe > 0){
		Stack.getDimensions(width, height, channels, slices, frames);
		run("Duplicate...", "title=substack duplicate slices=1-" + slices +" frames=1-" + endframe);
	}

	run("Z Project...", "projection=[Max Intensity] all"); // z-projection on all timepoints
	zprj = getTitle();
	if(isOpen("substack"))		close("substack");
	
	if (do_registration){
		makeRegistrationFile(0);
	}
	pre_tprj = getTitle();
	
	run("Z Project...", "projection=[Max Intensity]"); // project all timepoints into single image
	tprj = getTitle();

	// convert units of final projection for identifying region in pixel units (original movie will retain unit info) 
	run("Properties...", "unit=px pixel_width=1 pixel_height=1");
	setAutoThreshold("Triangle dark");
	run("Analyze Particles...", "size=" + minPixSize + "-Infinity display clear include add");

	// select the first ROI found (probably the biggest one)
	if (roiManager("count") > 0) {
		largest = -1;

		// the following loop selects only the largest ROI found
		for(r = 0; r < roiManager("count"); r++){
			roiManager("select", r);
			getStatistics(area);
			if (area > largest){
				largest = area;
				roi_selector = r;
			}
		}
		roiManager("select", roi_selector);
		
		// this makes a box around that largest loop
		run("Measure");
		x = getResult("BX") - boundary;
		y = getResult("BY") - boundary;
		width = getResult("Width") + boundary * 2;
		height = getResult("Height") + boundary * 2;
		makeRectangle(x, y, width, height);
	}
	// in case no region is found use entire image
	else {
		run("Select All");
	}

	// recreate ROI on original movie and close projections
	selectImage(ori);
	run("Restore Selection");

	close(zprj);
	close(tprj);
	if (isOpen(pre_tprj))	close(pre_tprj);
}


function makeRegistrationFile(Z_project){
	Registration_save_location = TempDisk + ":\\ANALYSIS DUMP\\" + Q + "Exp" + loop_number + "\\Settings\\TransfMatrix.txt";
	
	// make Z projection
	if(Z_project)	run("Z Project...", "projection=[Max Intensity] all");
	
	prj_reg = getTitle();
	print(prj_reg);

	// register projection
	run("MultiStackReg", "stack_1=[" + prj_reg + "] action_1=Align file_1=[" + Registration_save_location + "] stack_2=None action_2=Ignore file_2=[] transformation=[Rigid Body] save");
}



function correctDriftOnStack(endframe){
	Registration_save_location = TempDisk + ":\\ANALYSIS DUMP\\" + Q + "Exp" + loop_number + "\\Settings\\TransfMatrix.txt"; // !!##DB#!! I hope this is the right place!
	
	// import stack info
	ori = getTitle();
	Stack.getDimensions(width, height, channels, slices, frames);

	// if auto_crop was used, then reg file has already been created
	// otherwise, do so now
	if (File.exists( Registration_save_location ) == 0)	makeRegistrationFile(1);

	// register individual Z-slices
	concat_arg = "  title=" + ori + "_registered open";
	print("correct drift on stack");
	print("CURRENT TIME -", makeDateOrTimeString("time"));
	for (z = 1; z < slices+1; z++) {
		selectImage(ori);
		
		run("Duplicate...", "title=[" + ori + "_slice" + z +"] duplicate slices="+z);
		curr_IM = getTitle();
		run("MultiStackReg", "stack_1=[" + curr_IM + "] action_1=[Load Transformation File] file_1=[" + Registration_save_location + "] stack_2=None action_2=Ignore file_2=[] transformation=[Rigid Body]");
		concat_arg = concat_arg + " image" + z + "=" + ori + "_slice" + z;
	}
	print("drift correction done");
	print("CURRENT TIME -", makeDateOrTimeString("time"));
	print(concat_arg);
	close(ori);
	
	// concatenate slices back together
	concat_arg = concat_arg + " image" + z + "=[-- None --]";
	selectWindow("Log");	// DB: I don't know why, but this statement fixes a bug that crashes the macro if auto-crop is not selected
	run("Concatenate...", concat_arg);
	run("Stack to Hyperstack...", "order=xyctz channels=1 slices="+slices+" frames="+frames+" display=Grayscale");
	rename(ori);
}


function exportFinalProduct(){
	curr_movie = movie_index_list [loop_number-1];	// loop number - 1 because loop numbers 1-indexed rather than 0-indexed
	savename = image_output_location + prefix + "_" + curr_movie;
	savename = replace(savename,"__","_");

	// avoid overwriting files in case of duplicate filenames
	test = savename;
	counter = 0;
	while (File.exists (test + ".avi") || File.exists (test + ".tif") ){
		counter ++;
		test = savename + "_" + counter;
	}
	savename = test;

	// save files as AVI and/or TIF
	run("Select None");
	if (makeAVI){
		run("AVI... ", "compression=JPEG frame=" + FrameRateAvi + " save=[" + savename + ".avi]" );
		print("saved: " + savename + ".avi");
	}
	if (makeTIF){
		saveAs("Tiff", savename + ".tif");
		print("saved: " + savename + ".tif");
	}
}


function makeDateOrTimeString(DorT){
	getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);

	if(DorT == "date" || DorT == "Date" || DorT == "DATE" || DorT == "D" || DorT == "d"){
		// year
		y = substring (d2s(year,0),2);
		// month
		if (month > 8)	m = d2s(month+1,0);
		else			m = "0" + d2s(month+1,0);
		// day
		if (dayOfMonth > 9)		d = d2s(dayOfMonth,0);
		else					d = "0" + d2s(dayOfMonth,0);
		// return string
		string = y + m + d;
	}

	if(DorT == "time" || DorT == "Time" || DorT == "TIME" || DorT == "T" || DorT == "t"){
		// hour
		if (hour > 9)	h = d2s(hour,0);
		else			h = "0" + d2s(hour,0);
		// minute
		if (minute > 9)	m = d2s(minute+1,0);
		else			m = "0" + d2s(minute+1,0);
		// day
		if (second > 9)	s = d2s(second,0);
		else			s = "0" + d2s(second,0);
		// return string
		string = h + ":" + m + ":" + s;
	}
	
	return string;
}

function detectLastTimepoint(){
	run("Select None");
	ori_im = getTitle();
	run("Z Project...", "projection=[Max Intensity] all");
	prj = getTitle();
	selectImage(prj);
	for (i = 0; i < nSlices; i++){
		setSlice(i + 1);
		run("Measure");
		CV = getResult("Mean")/getResult("StdDev");
		if (CV > covCutoff){
			lastframe = i+1;
			i += nSlices;	// ends current for loop.
		}
	}
	
	if(lastframe == 0)	lastframe = nSlices;
	else if(lastframe < minMovieLength)	lastframe = minOf(minMovieLength,nSlices);
	print("last timepoint " + lastframe);
	setSlice(lastframe);
	print("CURRENT TIME -", makeDateOrTimeString("time"));

	selectImage(prj);
	close();

	selectImage(ori_im);
	Stack.setPosition(1, 1, lastframe);
	return lastframe;
	
}


//BP37

//FUNCTIONS
/*
function splitZslice(title,UitgekozenZplaneVoorTransmitted) 
function cropToROI(title) 
function drawROI(title) 
function substractDeadMask(TitleDead,TitleNuclei) 
function removeNoise(Title) 
function DeadMask(TitleDead,cutoff) 
function splitTimepoint(Title,Start,End)
function CorrectZ(ChromaticAberration)
function RemoveBottomZ(Title)
function RemoveTopZ(Title)
function MakeProjections(Title)
function MergeTimepoint(title,start,end)
function splitZplaneTemp(Title, JumpZ)
function splitTimepointTemp(Title,JumpT,JumpZ,Reduce)
function MergeTimepointTemp(title,JumpT)
function MergeTrans_BGYR(ChannelName) 
function PureDenoise(Title)
function PureDenoiseStack(Title)
function DrawText(Title,Text, Size, Colour)
function DrawTime(Title,Interval, Size, Colour)
function SetTransmittedBrightness(CurrentWindow)
function GetLUTColour(Title)
*/
