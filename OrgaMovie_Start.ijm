// Dialog settings
getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
date = "" + dayOfMonth + "-" + month+1 + "-" + year;
Choice_time_interval_unit = newArray("sec","min","hr")

Dialog.create("OrgaMovie Setup");
	Dialog.addMessage("SETTING UP YOUR DATA STRUCTURE:");
	Dialog.addMessage("Put all your analysis data in a single folder.\nMake sure your filetype is opened in 'windowless' mode (Check README for details).\nIf you wish to skip any movies, add an underscore (i.e. _ ) in front of the filename.");
	Dialog.addMessage("");

    Dialog.addMessage("DATA INPUT SETTINGS:");
    Dialog.addNumber("Time interval:", 3, 0, 2, "min");
    //    Dialog.addChoice("Time interval unit", Choice_time_interval_unit[1])
    Dialog.addString("Date experiment:", date);
    Dialog.addString("Experiment prefix:", "Pos_");
	Dialog.addMessage("");
	
	Dialog.addMessage("AUTOMATION SETTINGS:");
	Dialog.addCheckbox("Use drift correction", 0);
	Dialog.addCheckbox("Use auto-cropping?", 1);
	Dialog.addCheckbox("Use auto-detection of last timepoint?", 0);
	Dialog.addCheckbox("Use auto-detection of Z planes?", 0);
	Dialog.addMessage("");

	Dialog.addMessage("MOVIE OUTPUT SETTINGS (!! currently unused !!):");
	Dialog.addNumber("Gamma factor:", 0.7, 1, 4,"(brings low and high intensity together)" );
    Dialog.addNumber("Multiply factor:", 1.0, 1, 4,"(for depth coded channel)" );
    Dialog.addNumber("Duration:", 1.3, 1, 4,"sec / frame");
    
Dialog.show();    
    // DATA INPUT SETTINGS
    t_step = Dialog.getNumber();	// min
    // t_unit = Dialog.getChoice();
    date = Dialog.getString();
    prefix = Dialog.getString();	
	// AUTOMATION SETTINGS
	do_registration = Dialog.getCheckbox();
	do_autocrop = Dialog.getCheckbox();
	do_autotime = Dialog.getCheckbox();
	do_autoZ    = Dialog.getCheckbox();
	//MOVIE OUTPUT SETTINGS
	gamma_factor = Dialog.getNumber();
	multiply_factor = Dialog.getNumber();
	sec_p_frame = Dialog.getNumber();


dir = getDirectory("Choose Directory");
	// dir should contain all image data and the autocrop and movie assembly macro
filelist = getFileList(dir);


outdir = dir + "output" + File.separator;
File.makeDirectory(outdir);


for (f = 0; f < filelist.length; f++) {
	if endsWith(f, ".nd2"){

		//open (dir+f);
		runMacro("OrgaMovie_Autocrop");
		runMacro("OrgaMovie_Main")
	}
}







