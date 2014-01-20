//a Version notes
// First version includes prongs, and notch_end was too small
// The prongs completely failed - too thin, did not cool between layers

//a Globals
// cable_diameter is actually the gap between the prongs really - it should be bigger than the cable diameter itself
cable_diameter = 8;
// cable_width is the amount of cable if latching - bear in mind you lose some for the prong bobble
cable_length = 10;
  // prong_width is the width of the prong, doh
prong_width = 4;
// prong_bobble is the blob on the end inside the prongs - it eats in to the cable size, but holds the cables in
prong_bobble_radius = 3.6; // good idea is 0.7*cable_diameter/2; the end gap is cable_diameter-2*prong_bobble_radius
  // eccentricity is how much deeper along the prong compared to the between the prongs the bobble is
prong_bobble_eccentricity = 1.0;
  // latch_body_thickness is the thickness of the latch body
latch_body_thickness = 6;
  //prong_thickness
prong_thickness = 4;
  // latch_prong_thickness is the thickness of the latch prong
latch_prong_thickness = prong_thickness*0.3;
  // notch_end is the amount of prong at the tip before the first notch 
notch_end = 2;
  // notch_separation is the gap between notches
notch_separation = 3;
  // notch_slack is the slack amount between the notch width and the latch width
notch_slack = 0.15;
  // notch_width is the width of a notch
notch_width = latch_body_thickness + notch_slack;
  // prong_depth provides for the cables - note that if latching, the prong_depth is reduced by latch_body_thickness+notch_end+latch_body_thickness
prong_depth = cable_length+2*latch_body_thickness+notch_end;
// latch_height_slack is the extra slack between cable ties when latched together
latch_height_slack = 0.8;
// latch_notch_slack is the extra slack between cable ties when latched together
latch_notch_slack = 0.6;
// clasp
clasp_interior = 6;
clasp_exterior = clasp_interior+2.5; // should be interior+2.5 at least
clasp_entrance = (clasp_exterior-clasp_interior)/2*2;

// Small variant
// Good - could do with two clasps big and small on the head end
// need longer variant too
// potentially wiggly internals to the cable area
cable_diameter = 6;
cable_length = 8;// was 10
prong_width = 3;
prong_bobble_radius = 0.8*cable_diameter/2;
prong_bobble_eccentricity = 1.0;
latch_body_thickness = 3.5;
prong_thickness = 3.5;
latch_prong_thickness = prong_thickness*0.3;
notch_end = 2;
notch_separation = 3;
notch_slack = 0.15;
notch_width = latch_body_thickness + notch_slack;
prong_depth = cable_length+2*latch_body_thickness+notch_end;
latch_height_slack = 0.8;
latch_notch_slack = 0.6;
clasp_interior = 3.0;
clasp_exterior = clasp_interior+2.5; // should be interior+2.5 at least
clasp_entrance = (clasp_exterior-clasp_interior)*0.85;
clasp_angle=14;


echo("Prong bobble radius",prong_bobble_radius);
echo("Prong thickness",prong_thickness);
echo("Prong thickness after notch (should be >prong_bobble_radius)",prong_thickness-2*latch_prong_thickness);
echo("Check this value is not negative... if so, reduce prong_bobble_radius",prong_thickness-2*latch_prong_thickness-prong_bobble_radius);

//a Modules
module cable_tidy_latch()
{
  latch_body_width  = cable_diameter + 2*prong_thickness;
  latch_body_height = prong_width*2 + latch_height_slack;
  latch_hole_width  = latch_body_width - 2*(latch_prong_thickness - latch_notch_slack);
  latch_bobble_radius = latch_prong_thickness-latch_notch_slack;
  echo("Latch prong thickness",latch_prong_thickness);
  echo("Latch bobble radius",latch_bobble_radius);
  if (with_prongs==true)
    {
      difference()
	{
	  translate( [0,-latch_body_width/2,0] )                             cube( [latch_body_height,latch_body_width,latch_body_thickness] );
	  translate( [prong_width,-latch_hole_width/2,-latch_body_thickness/2] )  cube( [latch_body_height,latch_hole_width,latch_body_thickness*2] );
	}
      translate([latch_body_height-latch_bobble_radius, (latch_body_width/2-latch_bobble_radius),0]) cylinder(h=latch_body_thickness,r=latch_bobble_radius, $fs=1.0);
      translate([latch_body_height-latch_bobble_radius,-(latch_body_width/2-latch_bobble_radius),0]) cylinder(h=latch_body_thickness,r=latch_bobble_radius, $fs=1.0);
    }
  else
    {
      union()
      {
	translate( [0,-latch_body_width/2,0] )  cube( [prong_width,latch_body_width,latch_body_thickness] );
	translate( [0,0,latch_body_thickness+clasp_interior/2] )  cable_tidy_clasp();
      }
    }
}

module cable_tidy_clasp()
{
  hole_r = (clasp_interior+clasp_exterior)/4;
  hole_angle = clasp_angle;
  rotate([0,90,0]) 
    difference()
    {
      cylinder( r=clasp_exterior/2, h=prong_width, $fs=0.5 );
      cylinder( r=clasp_interior/2, h=prong_width, $fs=0.5 );
      translate([hole_r*sin(hole_angle),hole_r*cos(hole_angle),0]) cylinder( r=clasp_entrance/2, h=prong_width, $fs=0.4 );
    }
}

module cable_tidy_prong_notch()
{
  // a notch mask that is based at 0,0,0, with length in +ve x and width both sides of y
  // the notch is > prong_width long (its basic length requirement, +ve x) and exactly notch_width wide (y), and extra high (z)
  // note that the notch is basically 
  difference()
    {
      translate([-prong_width,-notch_width/2,prong_thickness-2*latch_prong_thickness])                 cube( [prong_width*3,notch_width,prong_thickness*3] );
      translate([-2*latch_prong_thickness,-notch_width,-latch_prong_thickness]) cube( [prong_width,2*notch_width,prong_thickness] );
    }
}

module cable_tidy_prong()
{
  union()
  {
    translate([prong_depth-prong_bobble_radius*prong_bobble_eccentricity,prong_width/2,0]) rotate([90,0,0]) scale([prong_bobble_eccentricity,1,1]) cylinder( h=prong_width, r=prong_bobble_radius, $fs=1 );
    translate( [-1,-prong_width/2,0] )                             cube( [prong_depth+1,prong_width,prong_thickness] );
  }
}

module cable_tidy_prong_notched()
{
  union()
  {
    translate([prong_depth-prong_bobble_radius*prong_bobble_eccentricity,prong_width/2,0]) rotate([90,0,0]) scale([prong_bobble_eccentricity,1,1]) cylinder( h=prong_width, r=prong_bobble_radius, $fs=1 );
    difference()
      {
        translate( [-1,-prong_width/2,0] )                             cube( [prong_depth+1,prong_width,prong_thickness] );
	for (i = [0:2])
	  {
	    translate( [prong_depth-notch_end-notch_width/2-i*(notch_width+notch_separation),-prong_width/2,0]) rotate([0,0,90]) cable_tidy_prong_notch();
	  }
      }
  }
}

module cable_tidy()
{
  union()
    {
      rotate([0,-90,0]) cable_tidy_latch();
      translate([0,+cable_diameter/2,0]) rotate([-90,0,0]) translate([0,-prong_width/2,0]) cable_tidy_prong();
      mirror([0,1,0]) translate([0,+cable_diameter/2,0]) rotate([-90,0,0]) translate([0,-prong_width/2,0]) cable_tidy_prong();
    }
}

//cable_tidy_prong();
//translate([-20,0,0]) rotate([0,0,90]) cable_tidy_prong_notch();

cable_tidy();
//cable_tidy_latch();
