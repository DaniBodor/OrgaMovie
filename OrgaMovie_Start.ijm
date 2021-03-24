


dir = getDirectory("Choose Data Directory");
	// dir should contain all image data and the autocrop and movie assembly macro
filelist = getFileList(dir);


outdir = dir + "output" + File.separator;
File.makeDirectory(outdir);


for (f = 0; f < filelist.length; f++) {
	if endsWith(f, ".nd2"){

		open (dir+f);
		runMacro("OrgaMovie_Autocrop");
		runMacro("OrgaMovie_Main")
	}
}







