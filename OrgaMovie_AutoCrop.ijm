
minSize = 1500;	//um2
extra_boundary = 50 // px



// the following 2 optional additions are still under production
time_crop = false;
	cutoff = 0;
drift_correction = false;
	





getPixelSize(unit, pixelWidth, pixelHeight);
minPixSize = minSize/(pixelWidth*pixelHeight);



ori = getTitle();
//run("Z Project...", "projection=[Max Intensity] all");
zprj = getTitle()l
run("Z Project...", "projection=[Max Intensity]");
tprj = getTitle();
Stack.setXUnit("px");	Stack.setYUnit("px");
run("Properties...", "pixel_width=1 pixel_height=1");

setAutoThreshold("Yen dark");
run("Analyze Particles...", "size="+minPixSize+"-Infinity display exclude clear include add");

roiManager("select", 0);
x = getValue("BX") - extra_boundary;
y = getValue("BY") - extra_boundary;
width = getValue("Width") + extra_boundary*2;
height = getValue("Height") + extra_boundary*2;

close();


if (time_crop){
	selectImage(zprj);
	setSlice(nSlices);
	kurt = getValue("Kurtosis");

	while (kurt < cutoff) {
		run("Delete Slice");
		kurt = getValue("Kurtosis");
	}
	// set something
}


if (drift_correction){
	
}


selectWindow(ori);
makeRectangle(x, y, width, height);
run("Crop");






// check (in movie with drift) for drift correction
// depending on time consumption, either register the initial zprj, or first crop the zprj and then register


// check (in better movie) for place to end the movie by looking at stats over time. This is best done on original zprj




