// Dialog settings
date = makeDateString();

//Choice_time_interval_unit = newArray("sec","min","hr");
IndexingOptions = newArray("read from file","linear");


print("\\Clear");
print("start");
run("Close All");
run("Collect Garbage");
run("Set Measurements...", "area mean standard min bounding stack limit redirect=None decimal=1");

Dialog.create("OrgaMovie Setup");
	Dialog.addMessage("SETTING UP YOUR DATA STRUCTURE:");
	Dialog.addMessage("Put all your analysis data in a single folder.\nMake sure your filetype is opened in 'windowless' mode (Check README for details).\nIf you wish to skip any movies, add an underscore (i.e. _ ) in front of the filename.");
	Dialog.addMessage("Remove all 'Queued Exp' folders and all *.txt files from the ANALYSIS DUMP before proceeding");
	Dialog.addMessage("");

    Dialog.addMessage("DATA INPUT SETTINGS:");
    Dialog.addString("Filetype extension", "nd2");
    Dialog.addNumber("Time interval:", 3, 0, 2, "min");
    //    Dialog.addChoice("Time interval unit", Choice_time_interval_unit[1])
    Dialog.addString("Date experiment:", date);
    Dialog.addString("Experiment prefix:", "");
	Dialog.addMessage("");
	
	Dialog.addMessage("AUTOMATION SETTINGS");
	Dialog.addCheckbox("Use drift correction", 1);
	Dialog.addCheckbox("Use auto-cropping?", 1);
	Dialog.addCheckbox("Use auto-contrasting?", 1);
	Dialog.addCheckbox("Use auto-detection of last timepoint? (not implemented)", 0);
	Dialog.addCheckbox("Use auto-detection of Z planes? (not implemented)", 0);
	Dialog.addCheckbox("Change default automation settings?", 0);
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
    prefix = Dialog.getString() + "_";	
	// AUTOMATION SETTINGS
	do_registration = Dialog.getCheckbox();
	do_autocrop = Dialog.getCheckbox();
	do_autoBC = Dialog.getCheckbox();
	do_autotime = Dialog.getCheckbox();
	do_autoZ    = Dialog.getCheckbox();
	changeSettings = Dialog.getCheckbox();
	//MOVIE OUTPUT SETTINGS
	gamma_factor = Dialog.getNumber();
	multiply_factor = Dialog.getNumber();
	sec_p_frame = Dialog.getNumber();
	indexing = Dialog.getChoice();
		movie_index = 0;

T_options = getList("threshold.methods");

Dialog.create("Automation Settings");
	if(do_autocrop){
		Dialog.addMessage("Auto-crop settings:")
		Dialog.addNumber("Minimum organoid size:", 350, 0, 4, "um2");
		Dialog.addNumber("Boundary around square:", 30, 0, 4, "pixels");
	}
	if(do_autoBC){
		Dialog.addMessage("Contrast automation:")
		Dialog.addChoice("Threshold Method:", T_options, "Percentile");
	}
if (changeSettings && (do_autocrop + do_autoBC) > 1) {
	Dialog.show();
}
	minOrgaSize = Dialog.getNumber();
	cropBoundary = Dialog.getNumber();
	BC_thresh_meth = Dialog.getChoice();

arguments = newArray(	t_step, // 0
						date, 	// 1
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
						"loop_number", // 16
						BC_thresh_meth); // 17




dir = getDirectory("Choose Directory");
if (dir == "")		exit("macro aborted\nno input directory given");
	// dir should contain all image data and the autocrop and movie assembly macro
filelist = getFileList(dir);


outdir = dir + "output" + File.separator;
//File.makeDirectory(outdir);

// Macro_location = "C:\\Users\\j.fernandes\\Desktop\\TEST" + File.separator;
Macro_location = "C:\\Users\\TEMP\\Desktop\\OrgaMovie_Macro" + File.separator;


// run macro for all *.nd2 files in "queue" mode, excluding files starting with an _
for (f = 0; f < filelist.length; f++) {
	currfile = filelist[f];
	if (endsWith(currfile, filetype) &! startsWith(currfile, "_") )  {
		if (indexing)	movie_index = substring(currfile, lengthOf(currfile)-7, lengthOf(currfile)-4);
		else 			movie_index ++;
		
		arguments[11] = dir+currfile;
		arguments[12] = movie_index;
		arguments[16] = f+1;	// loop number
		
		passargument = makeArgument(arguments);

		//Array.print(arguments);
		print("run macro in queue mode on movie: " + movie_index);
		run("Collect Garbage");
		runMacro(Macro_location + "OrgaMovie_Main_.ijm",passargument);
		run("Collect Garbage");
	}
}
print("*****************queue finished");

// Now re-run macro in process mode
print("***************** entering process mode");
arguments[13] = "process";	// i.e. the run mode
arguments[16] = 0;	// loop number
passargument = makeArgument(arguments);
runMacro(Macro_location + "OrgaMovie_Main_.ijm",passargument);


// close macro
if (isOpen("ROI Manager")){
	selectWindow("ROI Manager");
	run("Close");
}
print("*****************initiation macro finished");


function makeArgument(arg_array){
	string_arg = "";
	splitter = "$";
	for (i = 0; i < arg_array.length; i++) {
		string_arg = string_arg + arg_array[i] + splitter;
	}
	return string_arg;
}



function makeDateString(){
	getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
	y = substring (d2s(year,0),2);
	
	if (month > 8)	m = d2s(month+1,0);
	else			m = "0" + d2s(month+1,0);

	if (dayOfMonth > 9)		d = d2s(dayOfMonth,0);
	else					d = "0" + d2s(dayOfMonth,0);
	
	date = y + m + d;
	return date;

}
