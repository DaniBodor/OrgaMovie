Registration_save_location = "C:\\Users\\dani\\Documents\\MyCodes\\OrgaMovie\\Registration_Files"+File.separator+"TransformationMatrices.txt";


// import stack info
ori = getTitle();
Stack.getDimensions(width, height, channels, slices, frames);

// Z project
run("Z Project...", "projection=[Max Intensity] all");
prj = getTitle();

// register projection
run("Duplicate...", "title=registered duplicate");
prj_reg = getTitle();
run("MultiStackReg", "stack_1=" + prj_reg + " action_1=Align file_1=" + Registration_save_location + " stack_2=None action_2=Ignore file_2=[] transformation=[Rigid Body] save");

// register individual Z-slices
concat_arg = "  title=" + ori + "_registered open keep"
for (z = 1; z < slices+1; z++) {
	selectImage(ori);
	
	run("Duplicate...", "title=" + ori + "_slice" + z +" duplicate slices="+z);
	curr_IM = getTitle();
	run("MultiStackReg", "stack_1=" + curr_IM + " action_1=[Load Transformation File] file_1=" + Registration_save_location + " stack_2=None action_2=Ignore file_2=[] transformation=[Rigid Body]");
	concat_arg = concat_arg + " image" + z + "=" + ori + "_slice" + z;
}

// concatenate slices back together
concat_arg = concat_arg + " image" + z + "=[-- None --]";
run("Concatenate...", concat_arg);
run("Stack to Hyperstack...", "order=xyctz channels=1 slices="+slices+" frames="+frames+" display=Grayscale");


function printTime(prefix){
	getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
	print(prefix + " @ " + hour + ":" + minute + ":" + second);
}
