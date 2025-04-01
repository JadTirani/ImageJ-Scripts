// Entry dialog
Dialog.create("Quantitative Dot Blot");
Dialog.addMessage("This app will allow you to obtain intensity values from your given circles such that you can quantitativly determine concentration");
Dialog.show();

// Select the way you would like to run your selection softwear
Dialog.create("Selection Mode");
Dialog.addMessage("[Personal Selection] mode allows you to surround each individual dot the way you like.");
Dialog.addMessage("[Gel Lane Selection] will allow you to make a rectangular selection of a lane and then create a spectra of which you can selectivly integrate peaks.");
Dialog.addChoice("Select a mode", newArray("Personal Selection", "Gel Lane Selection"),"Personal Selection");
Dialog.show();
// Selection will switch on this variable
SELECTION_MODE = Dialog.getChoice(); 

// Prompt to remind you how to select input directory
Dialog.create("Selecting Input Directory");
Dialog.addMessage("You will be asked to select your starting directory");
Dialog.addMessage("Remember to put all your pictures into one file so that it cycles through them", 12, "#FF0000");
Dialog.show();

// Obtaining the file path
file_path = getDirectory("Select a Input Directory");

Dialog.create("Selecting Output Directory");
Dialog.addMessage("You will be asked to select your results directory");
Dialog.show();

OUTPUT_DIR = getDirectory("Select a Output Directory");

photolist = getFileList(file_path);
for (j = 0; j < photolist.length; j++) { // For each picture...
	FILE_NAME = file_path + photolist[j];
	open(FILE_NAME);
	
	run("Invert"); // Invert the image picture
	
	// Asks user to select the background to subtract
	waitForUser("Subtracting the background", "You will now be allowed to select a BACKGROUND. Select a spot between 2 dots as a BACKGROUND for subtraction.");
	
	// Actually subtracts the background
	run("Set Measurements...", "mean redirect=None decimal=3");
	run("Measure");
	BACKGROUND_INTENSITY = getResult("Mean");
	run("Select All");
	run("Subtract...", "value="+BACKGROUND_INTENSITY);
	run("Clear Results"); // Just deletes this single entry so it doesnt interfear with actual dots
	
	// Proceeds with the imaging based on selection mode...
	if (SELECTION_MODE == "Personal Selection") {	
		run("Set Measurements...", "area integrated redirect=None decimal=3");
		waitForUser("Selection Size", "Please use one of the selection tools to wrap your LARGEST dot comfortably. This will ensure all dots can be encompassed.");
		REMAINING_DOTS = true;
		NUM_DOTS = 1;
		while (REMAINING_DOTS) {
			//Keeps prompting you to select dots untill your finished
			Dialog.createNonBlocking("Select Dot");
			Dialog.addMessage("Move your selection tool onto Dot " + NUM_DOTS);
			Dialog.addCheckbox("Are you finished?", false);
			Dialog.show();
			FINISHED = Dialog.getCheckbox();
			if (FINISHED) {
				REMAINING_DOTS = false;
			} else {
				run("Measure");
			}
			NUM_DOTS++;
		}
		
		
		close("*"); // Closes the image
		// Makes a file for every picture b/c the standard curve will be diffrent
		//reduced_file_path = substring(file_path, 0, lengthOf(file_path)-1);
		//out_file_name=substring(reduced_file_path, lastIndexOf(reduced_file_path, "\\"));
		Table.save(OUTPUT_DIR++"(QuantDot).csv"); // OUTPUT_DIR+out_file_name
		run("Clear Results"); // Just deletes this single entry so it doesnt interfear with actual dots
	} if (SELECTION_MODE == "Gel Lane Selection") {
		run("Set Measurements...", "area integrated redirect=None decimal=3");
		// Warning, this is an unoptimized parameter
		run("Subtract Background...", "rolling=50");
		
		
		
	
	}
	
	
	
	
	
	// === Debug pause ===
	Dialog.create("Additional info");
	Dialog.addMessage("Background intensity: " + BACKGROUND_INTENSITY);
	Dialog.addMessage("Selection mode: " + SELECTION_MODE);
	Dialog.show();
}