//Macro_location = "C:\\Users\\dani\\Documents\\MyCodes\\OrgaMovie" + File.separator;
Macro_location = getDirectory("plugins") + "OrgaMovie" + File.separator;
if (File.exists(Macro_location) == 0)	exit("main macro not found at location\n" + Macro_location);


underscore_only = false;
// if true, only analyze files starting with underscore
// if false, skips files starting with underscore


// Dialog options settings
IndexingOptions = newArray("linear","input filename","input file index (until 1st '_')");
InputFileTypeList = newArray(".nd2");
OutputFormatOptions = newArray("*.avi AND *.tif", "*.avi only", "*.tif only");
T_options = getList("threshold.methods");
micron = getInfo("micrometer.abbreviation");
currdate = makeDateOrTimeString("date");
curr_user = getCurrUser();

// Startup
print("\\Clear");
print("start OrgaMovie macro");
print("CURRENT TIME -", makeDateOrTimeString("time"));
run("Close All");
run("Collect Garbage");
run("Set Measurements...", "area mean standard min bounding stack limit redirect=None decimal=1");
crash_test = "";


// Make dialog window for input settings
Dialog.create("OrgaMovie Settings");
	Dialog.addHelp("https://github.com/DaniBodor/OrgaMovie#readme");
	Dialog.addMessage("SETTING UP YOUR DATA STRUCTURE:");
	Dialog.addMessage("Put all your analysis data in a single folder.\nIf you wish to skip any movies, add an underscore (i.e. _ ) in front of the filename.");
	Dialog.setInsets(-5,20,0);
	Dialog.addMessage("Avoid confusion with previous experiments by deleting all 'Queued Exp' folders and the \nOutput_Movies folder and all *.txt files from D:\\ANALYSIS DUMP before proceeding.");

	Dialog.addMessage("Press 'Help' (next to Cancel) to open the ReadMe containing extensive information on all settings below.");
	Dialog.addMessage("");
	Dialog.addMessage("GENERAL SETTINGS");											Dialog.setInsets(0,0,5);
	Dialog.addChoice("Input filetype", InputFileTypeList, InputFileTypeList[0]);	Dialog.setInsets(0,0,5);
	Dialog.addNumber("Channel to display", 1, 0, 2, "(Nth channel)");				Dialog.setInsets(0,0,5);
	Dialog.addNumber("Time interval", 3, 0, 2, "min");								Dialog.setInsets(0,0,5);
	//Dialog.addString("Date experiment", date);		// DB: removed this because all it did was add unnece complexity to filename
	Dialog.addString("Experiment name:", curr_user + "_" + currdate, 20);
	Dialog.addMessage("");

	Dialog.addMessage("MOVIE OUTPUT SETTINGS");
	Dialog.addChoice("Output format", OutputFormatOptions, OutputFormatOptions[0]);
	Dialog.addNumber("Frame rate", 1.3, 1, 4,"sec / frame");
	Dialog.addChoice("Output naming ", IndexingOptions, IndexingOptions[2]);
	Dialog.addMessage("");

	Dialog.addMessage("AUTOMATION SETTINGS");
	Dialog.setInsets(0,20,0);
	Dialog.addCheckbox("Use drift correction", 1);
	Dialog.addCheckbox("Use auto-cropping?", 1);
	Dialog.addCheckbox("Use auto-contrasting?", 1);
	Dialog.addCheckbox("Use auto-detection of last timepoint?", 1);
	// Dialog.addCheckbox("Use auto-detection of Z planes? (not implemented)", 0);		// DB: decided not to implement this (for now)
	Dialog.addMessage("");
	Dialog.addCheckbox("Change default automation settings?", 0);
	Dialog.addMessage(" ");
	Dialog.addMessage(" ");
	Dialog.addCheckbox("Skip straight to processing mode?", 0);


Dialog.show();
	// DATA INPUT SETTINGS
	input_filetype = Dialog.getChoice();
	channel_number = Dialog.getNumber() - 1;
	t_step = Dialog.getNumber();	// min
	date = "obsolete";	// date = Dialog.getString();
	prefix = Dialog.getString() + "_";
		prefix = replace(prefix,"\\.","-");
	// MOVIE OUTPUT SETTINGS
	output_format = Dialog.getChoice();
	sec_p_frame = Dialog.getNumber();
	indexing = Dialog.getChoice();
		movie_index = 0;
		movie_index_list = newArray(0);
	// AUTOMATION SETTINGS
	do_registration = Dialog.getCheckbox();
	do_autocrop = Dialog.getCheckbox();
	do_autoBC = Dialog.getCheckbox();
	do_autotime = Dialog.getCheckbox();
	do_autoZ = "obsolete";	//do_autoZ = Dialog.getCheckbox();		// DB: decided not to implement this (for now)
	changeSettings = Dialog.getCheckbox();
	skip_step_1 = Dialog.getCheckbox();

def = 0.5;
if (do_autocrop && do_registration)		def_percile = def;
else if (do_registration)				def_percile = def /  2;
else if (do_autocrop)					def_percile = def / 10;
else									def_percile = def /  5;

// Second dialog in case of non-default automation settings
Dialog.create("Automation Settings");
	Dialog.addHelp("https://github.com/DaniBodor/OrgaMovie#readme");
	Dialog.addMessage("Auto-crop Settings:");
	Dialog.addNumber("Minimum organoid size:", 350, 0, 4, micron+"^2");
	Dialog.addNumber("Boundary around organoid:", 30, 0, 4, "pixels");

	Dialog.addMessage("Contrast Automation Settings:");
	Dialog.addChoice("Minimum threshold method:", T_options, "Percentile");
	Dialog.addNumber("Minimum brightness multiplier", 1.00, 2, 4, "(increases lowest pixel value; dimmer background; larger cutoff)");
	Dialog.addNumber("Percentile overexposed pixels", def_percile, 2, 4, "(decreases highest pixel value; brighter foreground; more overexposure)");
	Dialog.addNumber("Gamma factor", 0.7, 1, 4,"(brings low and high intensity together)" );
	Dialog.addNumber("Multiply factor", 1.0, 1, 4,"(for depth coded channel)" );

	Dialog.addMessage("Time-crop Settings:")
	Dialog.addNumber("CoV cutoff:", 5, 1, 4, "(higher values leads to a higher inclusion)");
	Dialog.addNumber("Minimum length:", 20, 0, 4, "time points");

	Dialog.addMessage("Press 'Help' to open the ReadMe containing extensive information on these settings.");
if (changeSettings && (do_autocrop + do_autoBC) > 1) {
	Dialog.show();
}
	// AUTO-CROP
	minOrgaSize = Dialog.getNumber();
	cropBoundary = Dialog.getNumber();
	// AUTO-CONTRAST
	min_thresh_meth = Dialog.getChoice();
	minBrightnessFactor = Dialog.getNumber();
	overexp_percile = Dialog.getNumber();
	gamma_factor = Dialog.getNumber();
	multiply_factor = Dialog.getNumber();
	// TIME-CROP
	covCutoff = Dialog.getNumber();
	minMovieLength = Dialog.getNumber();


// Assemble dialog data to single array, used to pass argument
arguments = newArray(	t_step, // 0
						date, // 1
						prefix,	// 2
						do_registration, // 3
						do_autocrop, // 4
						do_autoBC, // 5
						do_autotime, // 6
						do_autoZ,	// 7
						gamma_factor, // 8
						multiply_factor, // 9
						sec_p_frame, //10
						"filename",	 // 11
						movie_index, // 12
						"queue",	// 13
						minOrgaSize, // 14
						cropBoundary, //15
						0, // 16 (loop_number)
						min_thresh_meth, // 17
						//max_thresh_meth, // 18
						overexp_percile, // 18
						output_format, // 19
						minBrightnessFactor, // 20
						covCutoff, // 21
						minMovieLength, // 22
						channel_number, // 23
						"");
//for(i = 0; i < arguments.length; i++)		print(i,arguments[i]);


// select directory to open files from
dir = getDirectory("Choose Data Directory");
if (dir == "")		exit("macro aborted\nno input directory given");
filelist = getFileList(dir);
if (filelist.length == 0)	exit("no data found in input directory\n" + dir);


/// Business end of macro


// run macro for all files with correct extenstion in "queue" mode, excluding files starting with an _
for (f = 0; f < filelist.length; f++) {
	currfile = filelist[f];
	if (endsWith(currfile, input_filetype)){
		if (underscore_only && startsWith(currfile, "_") )  	movie_index_list = initiateMainMacroStep1 (currfile, arguments);
		else if (startsWith(currfile, "_") == 0)				movie_index_list = initiateMainMacroStep1 (currfile, arguments);
		//print("index list follows");
		//Array.print(movie_index_list);
	}
}

// prep queue is finished now
print("*****************queue finished");
print("CURRENT TIME -", makeDateOrTimeString("time"));


// Now re-run macro in process mode
print("***************** entering process mode");
arguments[13] = "process";	// i.e. the run mode
arguments[16] = 0;	// loop number
arguments[arguments.length-1] = "Movie_index_1_follows";
arguments = Array.concat(arguments, movie_index_list);
//for (i=0;i<arguments.length;i++) print(i,arguments[i]);
passargument = makeArgument(arguments);

runMacro(Macro_location + "OrgaMovie_Main_.ijm", passargument);


print("Macro all done");
SaveLogToArchive("CompletedRun");


////////////////////////////////////////////// FUNCTIONS //////////////////////////////////////////////



function initiateMainMacroStep1(currfile, arguments){
	if (indexOf(currfile," ") >= 0){
		oldfilename = dir + currfile;
		currfile = replace(currfile," ","_");
		newfilename = dir + currfile;
		File.rename (oldfilename,newfilename);
	}

	// determine proper movie_index
	if (indexing == IndexingOptions[0])			movie_index ++;		// linear
	else if(indexing == IndexingOptions[1])		movie_index = substring(currfile, 0, indexOf(currfile,input_filetype));		// filename
	else if (indexing == IndexingOptions[2])	movie_index = substring(currfile, 0, indexOf(currfile,"_"));	// index (until 1st '_'")
	if (movie_index == "")						movie_index = substring(currfile, 0, indexOf(currfile,input_filetype));		// revert to filename if empty
	movie_index_list_returner = Array.concat(movie_index_list, movie_index);

	// set file specific arguments to pass
	arguments[11] = dir + currfile;	// filename
	arguments[12] = movie_index;	// movie index
	arguments[16] ++;				// loop number // DB: identical to movie_index if indexing is linear. Could probably be consolidated, but I can't be bothered to.

	// initiate main macro and do memory dumps
	//for(i = 0; i < arguments.length; i++)		print(i,arguments[i]);
	crash_test = "";

	if(skip_step_1 == 0){
		print("current memory usage: " + IJ.freeMemory());
		for(x=0;x<5;x++)	run("Collect Garbage");
		print("memory usage after collect garbage: " + IJ.freeMemory());
		print("run macro in queue mode on movie: " + movie_index);
		print("CURRENT TIME -", makeDateOrTimeString("time"));
	
		passargument = makeArgument(arguments);
	
		runMacro(Macro_location + "OrgaMovie_Main_.ijm", passargument);	// returns empty string if ok, or [aborted] if main macro crashed
	
		
		print("current memory usage: " + IJ.freeMemory());
		for(x=0;x<5;x++)	run("Collect Garbage");
		print("memory usage after collect garbage: " + IJ.freeMemory());
	}
	else{
		print("skipping step 1, processing movie: " + movie_index);
	}

	// exit start macro if main macro crashed
	if (crash_test == "[aborted]"){
		print("!!!!! main macro crashed");
		SaveLogToArchive("CrashReport");
		exit("Exit macro.\nOrgaMovie_Main crashed during last run.\nCurrent Log has been saved as CrashReport.txt\nPlease save a screenshot or pic of the current screen for debugging purposes.");
	}

	return movie_index_list_returner;
}


function makeArgument(arg_array){
	string_arg = "";
	splitter = "$";
	for (i = 0; i < arg_array.length; i++) {
		string_arg = string_arg + arg_array[i] + splitter;
	}
	return string_arg;
}



function makeDateOrTimeString(DorT){
	getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);

	if(DorT == "date" || DorT == "Date" || DorT == "DATE" || DorT == "D" || DorT == "d"){
		y = substring (d2s(year,0),2);

		if (month > 8)	m = d2s(month+1,0);
		else			m = "0" + d2s(month+1,0);

		if (dayOfMonth > 9)		d = d2s(dayOfMonth,0);
		else					d = "0" + d2s(dayOfMonth,0);

		string = y + m + d;
	}

	if(DorT == "time" || DorT == "Time" || DorT == "TIME" || DorT == "T" || DorT == "t"){
		if (hour > 9)	h = d2s(hour,0);
		else			h = "0" + d2s(hour,0);

		if (minute > 9)	m = d2s(minute,0);
		else			m = "0" + d2s(minute,0);

		if (second > 9)	s = d2s(second,0);
		else			s = "0" + d2s(second,0);

		string = h + ":" + m + ":" + s;
	}

	return string;
}

function getCurrUser(){
	curr_user = getDirectory("home");
	parent = File.getParent(curr_user);
	curr_user = substring(curr_user, lengthOf(parent)+1, lengthOf(curr_user)-1);
	curr_user = replace(curr_user,"\\.","");

	return curr_user;
}


function SaveLogToArchive(descriptor){
	// print settings and save Log for future reference
	currdate = makeDateOrTimeString("D");
	currtime = makeDateOrTimeString("T");
	print("CURRENT TIME -", currtime);
	
	currtime = replace(currtime,":","");
	savetextfile = "D:\\ANALYSIS DUMP\\Settings\\LogArchive" + File.separator + prefix + "_" + currdate + "_" + currtime + "_" + descriptor + ".txt";
	selectWindow("Log");
	saveAs("Text", savetextfile);
}

