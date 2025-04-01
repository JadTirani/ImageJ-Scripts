selection_x = 0;
selection_y = 0;
selection_w = 0;
selection_h = 0;
ovr_rows = 0;
ovr_cols = 0;


// Entry dialog
Dialog.create("Quantitative Dot Blot");
Dialog.addMessage("This app will allow you to obtain intensity values from your given circles such that you can quantitativly determine concentration");
Dialog.show();

// Prompt to remind you how to select input directory
Dialog.create("Selecting Input Directory");
Dialog.addMessage("You will be asked to select your starting directory");
Dialog.addMessage("Remember to put all your pictures into one file so that it cycles through them", 12, "#FF0000");
Dialog.show();

// Obtaining the file path
INPUT_DIR = getDirectory("Select a Input Directory");

Dialog.create("Selecting Output Directory");
Dialog.addMessage("You will be asked to select your results directory");
Dialog.show();

OUTPUT_DIR = getDirectory("Select a Output Directory");

photolist = getFileList(INPUT_DIR);
for (i = 0; i < photolist.length; i++) { // For each picture...
	FILE_PATH = INPUT_DIR + photolist[i];
	open(FILE_PATH);
	
	run("Invert"); // Invert the image picture
	
	Dialog.create("Selecting Output Directory");
	Dialog.addCheckbox("Use this image?", true);
	Dialog.show();
	
	if (!Dialog.getCheckbox()) {
		close("*");
		continue;
	}
	
	// Asks user to select the background to subtract
	waitForUser("Subtracting the background", "You will now be allowed to select a BACKGROUND. Select a spot between 2 dots as a BACKGROUND for subtraction.");
	
	// Actually subtracts the background
	run("Set Measurements...", "mean redirect=None decimal=3");
	run("Measure");
	BACKGROUND_INTENSITY = getResult("Mean");
	run("Select All");
	run("Subtract...", "value="+BACKGROUND_INTENSITY);
	run("Clear Results"); // Just deletes this single entry so it doesnt interfear with actual dots
	run("Set Measurements...", "area integrated redirect=None decimal=3");
	
	Dialog.createNonBlocking("Select Image Frame");
	Dialog.addMessage("Wrap the dividable space of the Image");
	Dialog.show();
	getSelectionBounds(selection_x, selection_y, selection_w, selection_h);

	Dialog.create("Select Image Atributes");
	Dialog.addCheckbox("Automaticaly divide", true); // Just as a option if we ever want to switch off this method
	Dialog.addNumber("Rows", 10);
	Dialog.addNumber("Columns", 10);
	Dialog.show();

	ovr_rows = Dialog.getNumber();
	ovr_cols = Dialog.getNumber();

	counter = 1;
	for (j = 0; j < ovr_rows; j++) {
		for (k = 0; k < ovr_cols; k++) {
				makeRectangle(selection_x+(selection_w/ovr_cols)*k, selection_y+(selection_h/ovr_rows)*j, selection_w/ovr_cols, selection_h/ovr_rows);
				Dialog.createNonBlocking("Selection");
				Dialog.addMessage("Is this covering blot " + counter + "?, if not adjust it");
				Dialog.show();
				run("Measure");
				offset_x = 0;
				offset_y = 0;
				blank_w = 0;
				blank_h = 0;
				getSelectionBounds(offset_x, offset_y, blank_w, blank_h);
				if (((selection_x+(selection_w/ovr_cols)*k) != offset_x) && ((selection_y+(selection_h/ovr_rows)*j) != offset_y)) {
					Dialog.create("Keep selection Position?");
					Dialog.addCheckbox("Do you wish to keep the newly selected posistion?", false);
					Dialog.show();
					if (Dialog.getCheckbox()) {
						selection_x = offset_x-(selection_w/ovr_cols)*k;
						selection_y = offset_y-(selection_h/ovr_rows)*j;
					}
				}
				counter++;
			}
	}


	Dialog.create("DBG");
	Dialog.addMessage("x: " + selection_x + ", y: " + selection_y + ", w: " + selection_w +", h: " + selection_h);
	Dialog.addMessage("Box Width: " + selection_w/ovr_cols + ", Box height: " + selection_h/ovr_rows);
	Dialog.show();

	
	close("*");
	Table.save(OUTPUT_DIR+photolist[i]+"(QuantDot-UPDATED).csv"); // OUTPUT_DIR+out_file_name
	run("Clear Results"); // Just deletes this single entry so it doesnt interfear with actual dots
}
run("Close All");