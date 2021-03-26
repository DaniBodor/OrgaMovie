// Dialog settings
getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
date = "" + dayOfMonth + "-" + month+1 + "-" + year;
Choice_time_interval_unit = newArray("sec","min","hr");
IndexingOptions = newArray("read from file","linear");

print("\\Clear");


Dialog.create("OrgaMovie Setup");
	Dialog.addMessage("SETTING UP YOUR DATA STRUCTURE:");
	Dialog.addMessage("Put all your analysis data in a single folder.\nMake sure your filetype is opened in 'windowless' mode (Check README for details).\nIf you wish to skip any movies, add an underscore (i.e. _ ) in front of the filename.");
	Dialog.addMessage("Remove all 'Queued Exp' folders and all *.txt files from the ANALYSIS DUMP before proceeding");
	Dialog.addString("Filetype extension", "nd2");
	Dialog.addMessage("");

    Dialog.addMessage("DATA INPUT SETTINGS:");
    Dialog.addNumber("Time interval:", 3, 0, 2, "min");
    //    Dialog.addChoice("Time interval unit", Choice_time_interval_unit[1])
    Dialog.addString("Date experiment:", date);
    Dialog.addString("Experiment prefix:", "Pos_");
	Dialog.addMessage("");
	
	Dialog.addMessage("AUTOMATION SETTINGS (!! currently not implemented !!) ");
	Dialog.addCheckbox("Use drift correction", 0);
	Dialog.addCheckbox("Use auto-cropping?", 0);
	Dialog.addCheckbox("Use auto-detection of last timepoint?", 0);
	Dialog.addCheckbox("Use auto-detection of Z planes?", 0);
	Dialog.addCheckbox("Change default automation settings?", 1);
	Dialog.addMessage("");

	Dialog.addMessage("MOVIE OUTPUT SETTINGS:");
	Dialog.addNumber("Gamma factor:", 0.7, 1, 4,"(brings low and high intensity together)" );
    Dialog.addNumber("Multiply factor:", 1.0, 1, 4,"(for depth coded channel)" );
    Dialog.addNumber("Duration:", 1.3, 1, 4,"sec / frame");
    Dialog.addChoice("Index by:", IndexingOptions, IndexingOptions[0]);
    
Dialog.show();    
    // DATA INPUT SETTINGS
    filetype = Dialog.getString();
    t_step = Dialog.getNumber();	// min
    date = Dialog.getString();
    prefix = Dialog.getString();	
	// AUTOMATION SETTINGS
	do_registration = Dialog.getCheckbox();
	do_autocrop = Dialog.getCheckbox();
	do_autotime = Dialog.getCheckbox();
	do_autoZ    = Dialog.getCheckbox();
	autoSettings = Dialog.getCheckbox();		///vhdsiuvgshd
	//MOVIE OUTPUT SETTINGS
	gamma_factor = Dialog.getNumber();
	multiply_factor = Dialog.getNumber();
	sec_p_frame = Dialog.getNumber();
	indexing = Dialog.getChoice();
		movie_index = 0;


Dialog.create("Automation Settings");
	Dialog.addMessage("Auto-crop settings:")
	Dialog.addNumber("Minimum organoid size:", 1500, 0, 4, "um2");
	Dialog.addNumber("Boundary around square:", 50, 0, 4, "pixels");
if (autoSettings) {
	Dialog.show();
}
	minOrgaSize = Dialog.getNumber();
	cropBoundary = Dialog.getNumber();


arguments = newArray(	t_step, // 0
						date, 	// 1
						prefix,	// 2
						do_registration, // 3 
						do_autocrop, // 4
						do_autotime, // 5 
						do_autoZ,	// 6
						gamma_factor, // 7
						multiply_factor, // 8
						sec_p_frame, //9
						"filename",	 // 10
						movie_index, // 11
						"queue",	// 12
						minOrgaSize, // 13
						cropBoundary); // 14




dir = getDirectory("Choose Directory");
	// dir should contain all image data and the autocrop and movie assembly macro
filelist = getFileList(dir);


outdir = dir + "output" + File.separator;
//File.makeDirectory(outdir);

Macro_location = "C:\\Users\\j.fernandes\\Desktop\\TEST" + File.separator;


// run macro for all *.nd2 files in "queue" mode, excluding files starting with an _
for (f = 0; f < filelist.length; f++) {
	currfile = filelist[f];
	if (endsWith(currfile, filetype) &! startsWith(endsWith(currfile, "_") ){
		if (indexing)	movie_index = substring(currfile, lengthOf(currfile)-7, lengthOf(currfile)-4);
		else 			movie_index ++;
		
		arguments[10] = dir+currfile;
		arguments[11] = movie_index;
		passargument = makeArgument(arguments);
		
		
		runMacro(Macro_location + "OrgaMovie_Main_.ijm",passargument);
	}
}
print("*****************queue finished");

// Now re-run macro in process mode
print("***************** entering process mode");
print("this mode is untested as of 25-03-2021 and might crash")
arguments[12] = "process";	// run_mode = "process"
passargument = makeArgument(arguments);
runMacro(Macro_location + "OrgaMovie_Main_.ijm",passargument);


print("*****************process mode finished");


function makeArgument(arg_array){
	string_arg = "";
	splitter = "$";
	for (i = 0; i < arg_array.length; i++) {
		string_arg = string_arg + arg_array[i] + splitter;
	}
	return string_arg;
}



