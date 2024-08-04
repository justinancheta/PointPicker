# PointPicker
MATLAB Tool to get points from image plot

Simple GUI tool to assist in pulling data from an image plot. Control points 
define the axis end points, while points can be added using the "Add Points"
button. Zooming and panning can be done between between Add Point calls. An 
overlaid plot showing the picked points is provided after each update. This 
function utilizes the "ginput" function from MATLAB. Each time "Add Points" 
is called, press return after the final point. This will append the values 
to the x,y values for the plot. 

Options to toggle x and y log axes are provided. Buttons will enable when 
previous steps are completed. In order to scale data appropriately, ensure 
that you update teh X Range and Y Range values. 

Order of Operations: 
1. Open a file with the Open File button.
2. Adjust the X/Y range depending on image.
3. Add control points for the plot
4. Add points or clear as needed 
5. Enable the X-Log or Y-Log buttons as neeeded for each axis
6. Test output with the "Output Coordinates" button.
7. Save variables to workspace or file using the "Output Coordinates" or 
   "Write to File" button. 
	When selecting either option, a window will pop up which will request
	the workspace variable name or file name. If no file path is specified 
	with the file name, it will default to the working directory in MATLAB.


Remark: 
While Add Points is active all key presses will add points to the plot. 

