// number of files to split into
nSplit = 2;

// total number of frames
nFrames = 360;

// hide images while opening
setBatchMode(true);



// define file locations
dir = getDirectory("Choose a Directory");
flist = getFileList(dir);
outdir = dir + "Split_ND2s" + File.separator;
File.makeDirectory(outdir);
print("\\Clear");


// run through folder
for (f = 0; f < flist.length; f++) {
	if (endsWith(flist[f], ".nd2")) {
		
		// define current file location
		read_file = dir + flist[f];
		print (read_file);

		for (n = 0; n < nSplit; n++) {
			// define first and last frames
			t_begin = 1 + n * (nFrames/nSplit);
			t_end   = (1+n) * (nFrames/nSplit);
			outfile = outdir + substring(flist[f], 0, lengthOf(flist[f])-4) + "_frame" + IJ.pad(t_begin,3) + "-" + IJ.pad(t_end,3);
			print("opening frames", t_begin, "to" , t_end);
			
			// open and export part of image
			run("Bio-Formats Importer", "open=" + read_file + " specify_range t_begin=" + t_begin + " t_end=" + t_end);
			saveAs("Tiff", outfile + ".tif");
			File.rename(outfile + ".tif", outfile + ".nd2");
			print("\\Update:saved", outfile + ".nd2");
			close();

			// memory dump
			run("Collect Garbage");
		}
		
		print("");
	}
}




