// Platform Level test pattern
// Ed Nisley KE4ZNU - Dec 2011

// Successfully printing objects requires accurate build platform
// alignment. I find that 0.25 mm layers require leveling within about
// +/-0.05 mm across the entire platform.

// This OpenSCAD program generates an object with bars exactly one thread
// tall and two threads wide. Skeinforge (or your favorite slicer)
// converts the STL file into G-Code that will produce a very short and
// thin plastic extrusion that reveals any misalignment.

// Update: You must modify the OpenSCAD source to match your Skeinforge
// settings. The STL file is set for 0.25 mm thickness and 0.50 mm width,
// so it won't produce the correct G-Code for other printing
// parameters. It will (probably) print something that you can use for
// platform leveling, but the bars won't be exactly one-high by two-wide.

// After printing, cooling, and removing the pattern, measure the
// thickness with calipers. Each bar should exactly match the Skeinforge
// layer thickness; if it doesn't, then you know which part of the
// platform to adjust.

// My (extensively modified) Thing-O-Matic has a double aluminum plate
// build platform with three M3x0.5 mm adjusting screws at the left
// front, left rear, and right center mounting holes. Measuring the bar
// thicknesses near those screws directly indicates the required
// adjustment.

// It also has a Z-minimum platform height sensor switch, so I simply
// adjust the screws to level the platform; my start.gcode routine
// measures and sets the correct Z=0 position. Without that sensor, you
// must adjust the screws to eliminate the tilt and set the height to
// match the layer thickness.

// The overall printed width of each bar should match the Skeinforge W/T
// setting. For example, with 0.25 mm thickness and W/T=2.0, the bars
// should be 2 x 2 x 0.25 = 1.00 mm wide. This is very sensitive to the
// actual printed thickness.

// Two tabs mark the +X and +Y axis directions so you can figure out
// where to make the corrections. The bottom surface will be shinier than
// the top, indicating which side was down.

// More details and background on my blog at
// http://softsolder.com/2012/01/10/platform-level-test-pattern/.

//-------
//- Extrusion parameters must match reality!

ThreadThick = 0.3;   // Extrusion thickness of first layer in Slic3r
ThreadWidth = 0.475; // Extrusion width of first layer in Slic3r minus a bit as Slic3r is enthusiastic

//-------
// Dimensions
small = (1==0);

BoxSize = small ? 80 : 120;

//-------

module ShowPegGrid(Space = 10.0,Size = 1.0) {

  Range = floor(50 / Space);
  for (x=[-Range:Range])
    for (y=[-Range:Range])
      translate([x*Space,y*Space,Size/2])
        %cube(Size,center=true);
}

//-------

ShowPegGrid();

for (Index=[0:3])
  rotate(Index*90)
    translate([0,BoxSize/2,ThreadThick/2])
      cube([BoxSize,2*ThreadWidth,ThreadThick],center=true);

for (Index=[-1,1])
  rotate(Index*45)
    translate([0,0,ThreadThick/2])
      cube([sqrt(2)*BoxSize,2*ThreadWidth,ThreadThick],center=true);

translate([BoxSize/2,0,ThreadThick/2])
  cube([BoxSize/6,2*ThreadWidth,ThreadThick],center=true);

translate([0,BoxSize/2,ThreadThick/2])
  rotate(90)
    cube([BoxSize/6,2*ThreadWidth,ThreadThick],center=true);
