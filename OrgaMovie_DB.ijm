



function openFile(filename){

	//%% open files
	run("Bio-Formats Importer", "open=[" + filename + "] color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");
	
	//%% fix file if not opened as Hyperstack
	hstack_check = Property.get("hyperstack");
	if (hstack_check != "true"){
		frames = Property.getNumber("SizeT");
		slices = nSlices/frames;
		if (isNaN(frames) || round(slices) != slices) {
			print("file not (opened as) a hyperstack:", filename)
		}
		else {
			slices = nSlices/frames;
			run("Stack to Hyperstack...", "order=xyczt(default) channels=1 slices="+slices+" frames="+frames+" display=Grayscale");
		}
	}
}



//%% create projections
selectImage(1);
close("\\Others");
ori = getTitle();
run("Z Project...", "projection=[Max Intensity] all");
prj = getTitle();
run("Z Project...", "projection=[Max Intensity]");
t_prj = getTitle();









function getTransformationMatrix(base_folder){
	selectImage(prj);
	run("Duplicate...", "duplicate");
	prj_reg = getTitle();
	TransMatrix_File = base_folder + "TrMatrix.txt";
	
	run("MultiStackReg", "stack_1="+prj_reg+" action_1=Align file_1="+TransMatrix_File+" stack_2=None action_2=Ignore file_2=[] transformation=[Rigid Body] save");

	return TransMatrix_File;
}

function correct_drift(im, TransMatrix_File){
	run("MultiStackReg", "stack_1="+im+" action_1=[Load Transformation File] file_1=["+TransMatrix_File+"] stack_2=None action_2=Ignore file_2=[] transformation=[Rigid Body]");
}



function autoCrop(minSize, extraBoundary) { // DB
	selectImage(t_prj);
	run("Select None");

	//%% find areas with signal
	setAutoThreshold("Percentile dark");
	getThreshold(lower, upper);
	setThreshold(lower*0.95, upper);
	run("Analyze Particles...", "size="+minSize+"-Infinity pixel clear add");

	if (nResults > 0) {
		//%% select largest ROI
		area = -1;
		largest_roi = 0;
		
		for (r = 1; r < nResults; r++) {
			curr_area = getResult("Area", r);
			if (curr_area > area){
				area = curr_area;
				largest_roi = r;
			}
		}

		//%% select largest region
		roiManager("select", largest_roi);
		getBoundingRect(x, y, width, height);
		roiManager("reset");
		makeRectangle(x-extraBoundary, y-extraBoundary, width+2*extraBoundary, height+2*extraBoundary)
		//roiManager("add");
		//roiManager("rename", "Crop1");

		//%% crop images
		for (i = 0; i < nImages; i++) {
			selectImage(i);
			roiManager("select", 0)
			run("Crop");
		}
	}
	
	// in case no region is found use entire image
	/*else {
		run("Select All");
		roiManager("add");
		roiManager("rename", "Crop1");
	}*/
}


