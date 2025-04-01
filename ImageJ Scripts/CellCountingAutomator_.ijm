Dialog.create("Cell Rounding Automator");
Dialog.addMessage("This app will allow you to preform all the cell counting you want.");
Dialog.addChoice("Select a input method", newArray("File of File(s) of Images", "File of Images"),"File of Images");
Dialog.show();

slct_choice = Dialog.getChoice();

Dialog.create("Selecting Input Directory");
Dialog.addMessage("You will be asked to select your starting directory");
Dialog.addMessage("Remember your input is: "+slct_choice, 12, "#FF0000");
Dialog.show();

file_path = getDirectory("Select a Input Directory");

Dialog.create("Selecting Output Directory");
Dialog.addMessage("You will be asked to select your results directory");
Dialog.show();

out_path = getDirectory("Select a Output Directory");

Dialog.create("Parameters");
// Size Parameters
Dialog.addMessage("Size Parameters");
Dialog.addString("Size Boundries", "300-6000");
// Cell Rounding Parameters
Dialog.addMessage("Cell Rounding Parameters");
Dialog.addSlider("Cell Rounding Minimum", 0, 1, 0.00);
Dialog.addToSameRow();
Dialog.addSlider("Cell Rounding Maximum", 0, 1, 0.50);
Dialog.show();

param_cell_size = Dialog.getString();
param_min_rounding = Dialog.getNumber();
param_max_rounding = Dialog.getNumber();

if (slct_choice == "File of File(s) of Images") { // Switch case "File of File(s) of Images" 
	subfolder = getFileList(file_path);
	full_run = true; // For the RadioButton to see if you just wanna run all the files to the end
	for (i = 0; i < subfolder.length; i++) {
		subpath = file_path + subfolder[i];
		
		// UI asking if you wish to continue
		if (full_run) {
			Dialog.create("Do you wish to continue?");
			Dialog.addMessage("Would you like to process the following folder?\nOnly select 'Cancel' if you wish to quit.");
			Dialog.addMessage(subpath, 12, "#0000FF");
			Dialog.addRadioButtonGroup("", newArray("Skip to end", "Skip this run", "Continue"), 1, 3, "Continue");
			Dialog.show();
			
			resp = Dialog.getRadioButton();
			if (resp=="Skip to end") { // Turns off the prompt between each folder
				full_run = false;
			} if (resp == "Skip this run") { // Just skips the next loop, *NOTE: this is turned off automatically if skip to end is called
				continue;
			}
		}

		
		photolist = getFileList(subpath);
		for (j = 0; j < photolist.length; j++) {
			filename = subpath + photolist[j];
			open(filename);
	
			// Actual operations on picture
			setAutoThreshold("Default");
			run("Threshold...");
			setOption("BlackBackground", true);
			run("Convert to Mask");
			
//			run("Analyze Particles...", "size=300-6000 summarize");
//			run("Analyze Particles...", "size=300-6000 circularity=0.5-1.00 summarize");
			run("Analyze Particles...", "size=" + param_cell_size + " summarize");
			run("Analyze Particles...", "size=" + param_cell_size + " circularity=" + param_min_rounding + "-" + param_max_rounding + " summarize");
			}
		close("*");
		out_file_name=substring(subfolder[i], 0, lengthOf(subfolder[i])-1);
		Table.save(out_path+out_file_name+".csv");
		Table.deleteRows(0, Table.size("Summary"), "Summary");
	}
} if (slct_choice == "File of Images") { // Switch case "File of Images"
	photolist = getFileList(file_path);
	for (j = 0; j < photolist.length; j++) {
		filename = file_path + photolist[j];
		open(filename);

		// Actual operations on picture
		setAutoThreshold("Default");
		run("Threshold...");
		setOption("BlackBackground", true);
		run("Convert to Mask");
		
//		run("Analyze Particles...", "size=300-6000 summarize");
//		run("Analyze Particles...", "size=300-6000 circularity=0.5-1.00 summarize");
		run("Analyze Particles...", "size=" + param_cell_size + " summarize");
		run("Analyze Particles...", "size=" + param_cell_size + " circularity=" + param_min_rounding + "-" + param_max_rounding + " summarize");
	}
	close("*");
	reduced_file_path = substring(file_path, 0, lengthOf(file_path)-1);
	out_file_name=substring(reduced_file_path, lastIndexOf(reduced_file_path, "\\"));
	Table.save(out_path+out_file_name+".csv");
}



