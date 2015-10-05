//a Imports
use <mcad/involute_gears.scad>
// Changed the printer settings to 90% width instead of 0.5mm
//a Lego stuff
lego_unit = 1.6;
lego_height_units = 6;
lego_slat_height_units = 2;
lego_width_units  = 5;
lego_axle_hole_radius_units  = 3.2; // Originally 3, but is too tight when I print; 3.1 was not enough
lego_axle_hole_center_height_units  = 3.5;
lego_axle_hole_relief_radius_units  = 3.5;
lego_axle_radius_units  = 2.;
lego_knob_radius_units  = 3;
lego_wall_thickness_units  = 1;
lego_clutch_radius_units  = 4.07;
lego_clutch_support_thickness_units  = 1;
lego_teeth_per_unit = 8.0/lego_width_units; // There are 8 teeth for a gear of diameter one lego width unit
//lego_teeth_per_unit = 8.0/5.0/12.0*8.0;

//a Gear and axle modules
//m gjs_gear
module gjs_gear( r, num_teeth, thickness, bore_radius=0,dp=dp_gear  )
{
    pitch=num_teeth/((2.0*r)*dp);
    gear(number_of_teeth=num_teeth,
         diametral_pitch=pitch,
         gear_thickness=thickness,
         rim_thickness=thickness,
         hub_thickness=thickness,
         bore_diameter=2*bore_radius,
         backlash=backlash,
         clearance=0,
         involute_facets=involute_facets,
         pressure_angle=pressure_angle);
}

//m z_neg_axle
module z_neg_axle(length) {
  // Was X_clearance=1.9; but this is too tight on prints of working lego gears
  X_clearance=1.95;
  safe_diam = 5.4;
  safe_rad = 0.5 * safe_diam;
  linear_extrude(height = length,
                 center = true, convexity = 0, twist = 0) {
    polygon(points = [
      [0.5 * X_clearance,  0.7 * X_clearance],
      [0.7 * X_clearance,  0.5 * X_clearance],
      [safe_rad,           0.5 * X_clearance],
      [safe_rad,          -0.5 * X_clearance],
      [0.7 * X_clearance, -0.5 * X_clearance],
      [0.5 * X_clearance, -0.7 * X_clearance],
      [0.5 * X_clearance, -safe_rad],
      [-0.5 * X_clearance,-safe_rad],
      [-0.5 * X_clearance,-0.7 * X_clearance],
      [-0.7 * X_clearance,-0.5 * X_clearance],
      [-safe_rad,         -0.5 * X_clearance],
      [-safe_rad,          0.5 * X_clearance],
      [-0.7 * X_clearance, 0.5 * X_clearance],
      [-0.5 * X_clearance, 0.7 * X_clearance],
      [-0.5 * X_clearance, safe_rad],
      [ 0.5 * X_clearance, safe_rad]
    ] );
  }
}

//m z_axle_hole
module z_axle_hole(height) {
  cylinder( r=0.5*lego_unit*lego_axle_hole_radius_units, h=height);
}

//m z_axle_round
module z_axle_round(length, width_units=0.5*lego_width_units) {
  cylinder( r=width_units*lego_unit, h=length);
}

//a Connector and pegs/holes
//m planet_bar
module planet_bar( hole_center_length,
                   bar_width,
                   height,
                   axle_holes=[]
    )
{
    difference() {
        union() {
            translate([hole_center_length,0,0])
                z_axle_round(length=height);
            translate([0,-bar_width*0.5,0])
                cube([hole_center_length,bar_width, height]);
        }
        for (i=axle_holes) {
            translate([i[0]*lego_unit,0,-height])
                z_axle_hole_by_type(height=height*3, axle_hole_type_hole=i[1]);
        }
    }
}

module z_axle_hole_by_type(height, axle_hole_type_hole)
{
    if (axle_hole_type_hole) {
        z_axle_hole(height=height);
    } else {
        z_neg_axle(length=height*2);
    }
}

//m planet_bars
module planet_bars(length_units,
                   num_bars,
                   axle_holes = [] )
{
    difference() {
        union() {
            for (i=[0: num_bars-1]) {
                rotate ([0,0,360.0*i/num_bars])
                    planet_bar( hole_center_length = length_units*lego_unit,
                                bar_width = lego_width_units*lego_unit,
                                height = lego_slat_height_units*lego_unit,
                                axle_holes = axle_holes
                        );
            }
        }
        translate([0,0,-lego_unit])
            z_axle_hole(height=lego_unit*lego_slat_height_units*3);
    }
}

//m lego_washer
module lego_washer(height_units=lego_slat_height_units, axle_hole_type_hole=false)
{
    difference() {
        z_axle_round(length=height*lego_unit);
        translate([0,0,-1])
            z_axle_hole_by_type(height=lego_unit*lego_slat_height_units*3, axle_hole_type_hole=axle_hole_type_hole);
    }
}

//m lego_gear
module lego_gear(gear_diameter_units, include_supports=true, height_units=lego_slat_height_units, axle_hole_type_hole=false)
{
    gear_radius_units = 0.5*gear_diameter_units;
    make_solid = ((gear_diameter_units>3.5*lego_width_units) && include_supports) ? false:true;
    bore_radius = make_solid?0:(0.5*(gear_diameter_units-lego_width_units));
    num_teeth = gear_radius_units*lego_teeth_per_unit*2;
    //dp is diametral pitch
    //    pitch=num_teeth/((2*r)*dp);

    difference() {
        union() {
            gjs_gear( r=gear_radius_units*lego_unit, num_teeth=num_teeth, thickness=height_units*lego_unit, bore_radius=bore_radius*lego_unit, dp=dp_ring );
            if (!make_solid) {
                translate([-bore_radius*lego_unit,-0.25*lego_width_units*lego_unit,0]) cube([bore_radius*2*lego_unit,0.5*lego_width_units*lego_unit,height_units*lego_unit]);
                rotate([0,0,90]) translate([-bore_radius*lego_unit,-0.25*lego_width_units*lego_unit,0]) cube([bore_radius*2*lego_unit,0.5*lego_width_units*lego_unit,height_units*lego_unit]);
                z_axle_round(height_units*lego_unit,
                             width_units=1.0*lego_width_units);
            }
        }
        translate([0,0,-1])
            z_axle_hole_by_type(height=3*height_units*lego_unit, axle_hole_type_hole=axle_hole_type_hole);
    }
}

//m lego_ring_gear
module lego_ring_gear(inner_gear_diameter_units,
                      outer_gear_diameter_units,
                      height_units=lego_slat_height_units,
                      bar_centers=[])
{
    difference () {
        lego_gear(gear_diameter_units=outer_gear_diameter_units, height_units=height_units, include_supports=false);
        translate([0,0,-1]) lego_gear(gear_diameter_units=inner_gear_diameter_units, height_units=2*height_units, include_supports=false);
        for (i=bar_centers) {
            for (j=[0:i[1]-1]) {
                bar_center = i[0]*lego_unit*0.5;
                rotate([0,0,360.0*j/i[1]])
                    translate([ bar_center,0,-1])
                    z_neg_axle(length=3*height_units*lego_unit);
            }
        }
    }
}

// Constants
    backlash=0.25; // amount of space to accommodate build issues
    pressure_angle=20;
    dp_ring = 1.0; // fudge factor = <1 for a bit of a gap
    dp_gear = 1.0;
    draft = false;
    $fs = draft ? 2: 0.5; // minimum length of edge/etc in polygon from circle/sphere/cylinder
    $fa = draft ? 20 : 3;   // minimum angle of edge/etc in polygon from circle/sphere/cylinder
    involute_facets = draft ? 3: 6; // default is 5; number of facets for each tooth

    //planet_bars(3,3);
    //planet_bars(4,3);
//lego_gear(1*lego_width_units);
//traanslate([15,0,0]) lego_gear(2*lego_width_units);
//translate([-15,15,0]) lego_gear(3*lego_width_units);
module lego_planetary_gearset( sun_gear_diameter_units,
                               planet_gear_diameter_units,
                               ring_gear_diameter_units,
                               ring_bar_centers=[],
                               planet_bar_length_units=0,
                               planet_bar_holes = [],
                               planet_axle_holes=false )
{
    planet_center_units = (sun_gear_diameter_units+planet_gear_diameter_units)*0.5;
    if (planet_bar_length_units>0) {
        translate([0,0,2*lego_slat_height_units*lego_unit])
            planet_bars( length_units=planet_bar_length_units,
                         num_bars=3,
                         axle_holes = planet_bar_holes
                );
    }
    translate([0,0,0])  rotate([0,0,0.5*360/24.0]) lego_gear(sun_gear_diameter_units,axle_hole_type_hole=!planet_axle_holes);
    translate([planet_center_units*lego_unit,0,0]) lego_gear(planet_gear_diameter_units,axle_hole_type_hole=planet_axle_holes);
    lego_ring_gear(inner_gear_diameter_units = sun_gear_diameter_units+2*planet_gear_diameter_units,
                   outer_gear_diameter_units = ring_gear_diameter_units,
                   bar_centers=ring_bar_centers);
}

if (false) {
    lego_planetary_gearset( sun_gear_diameter_units    = 3*lego_width_units,
                            planet_gear_diameter_units = 3*lego_width_units,
                            ring_gear_diameter_units   = 14*lego_width_units,
                            ring_bar_centers=[[12*lego_width_units,12]], // Must be even # of lego_width_units really
                            planet_bar_length_units = 6*lego_width_units,
                            planet_bar_holes = [[3*lego_width_units*lego_unit, false],
                                                [6*lego_width_units*lego_unit, false]]
        );
}

if (false) {
    lego_planetary_gearset( sun_gear_diameter_units    = 2*lego_width_units,
                            planet_gear_diameter_units = 4*lego_width_units,
                            ring_gear_diameter_units   = 14*lego_width_units,
                            ring_bar_centers=[[12*lego_width_units,4]],
                            planet_bar_length_units = 6*lego_width_units,
                            planet_bar_holes = [[3*lego_width_units*lego_unit, false],
                                                [6*lego_width_units*lego_unit, false]]
        );
}

if (false) {
    lego_planetary_gearset( sun_gear_diameter_units    = 1.5*lego_width_units,
                            planet_gear_diameter_units = 2.5*lego_width_units,
                            ring_gear_diameter_units   = 10*lego_width_units,
                            ring_bar_centers=[[8*lego_width_units,4]],
                            planet_bar_length_units = 4*lego_width_units,
                            planet_bar_holes = [[2*lego_width_units*lego_unit, true],
                                                [4*lego_width_units*lego_unit, true]]
        );
}

module planetary_gears(gears=[])
{
    for (i=gears) {
        translate(i[1])
            lego_gear( gear_diameter_units = i[0],
                       axle_hole_type_hole = i[2]
                );
    }
}


gears_have_holes = (1==0);
gearset = [ //[1.5*lego_width_units, [0,0,0], gears_have_holes],
            //[2*lego_width_units,   [18,-5,0], gears_have_holes],
            //[2.5*lego_width_units, [40,-10,0], gears_have_holes],
            //[3*lego_width_units,   [65,0,0], gears_have_holes],
            [3.5*lego_width_units, [40,25,0], gears_have_holes],
            [4*lego_width_units,   [0,20,0], gears_have_holes],
            //[4.5*lego_width_units,   [0,-20,0], gears_have_holes],

    ];
if (true) {
    planetary_gears( gears=gearset );
    }
if (true) {
    for (i=[0,20,40,60]) {
        translate([i+0,-5,0])   
            lego_washer(axle_hole_type_hole=false);
        translate([i+10,-5,0])   
            lego_washer(axle_hole_type_hole=true);
    }
}

barset = [ //[2*lego_width_units, [-30,0,0], 3, [[2*lego_width_units,false]]],
           //[3*lego_width_units, [0,0,0],   3, [[3*lego_width_units,false]]],
           [4*lego_width_units, [40,0,0],  3, [[2*lego_width_units,false], [4*lego_width_units,false]]],
       ];
if (false) {
    for (i=barset) {
        translate(i[1])
            planet_bars( length_units=i[0],
                         num_bars=i[2],
                         axle_holes = i[3]
                );
    }
}
