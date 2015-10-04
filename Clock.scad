//a Notes for clock
// Need to add an optional connector to the sun, and make the axle optional with instead an axle hole
// The connector has a radius r (12mm?) and depth h=base_thickness, and has 6 (num_conn) further connector cylinders (1.5mm radius?) in a circle (radius 9mm?) around the axle. Note axle hole is 6mm diameter
// The second ring1, for the 12:1, then needs a connector-sized hole instead of an axle hole (add slack of 0.1mm to the radius)
// The first ring2 needs the connector cylinder holes in it
// A third ring1 can then be made with no ring gear, as a cap, but with the connector sized hole in the base area. It can have a slightly thicker base_thickness.

//a Ring ratio notes
// 1:60
// Fave: rotating_ring( sun_r=16, planets_r = 32, sun2_r = 21 ); to 1E-14; could use 4 planets if can futz ring2
//  can do 3 planets of 15/30/75 and 27/75, all three planets the same, size ratio as required at ring2/ring 75/80
// Fave: rotating_ring( sun_r=31, planets_r = 31, sun2_r = 34 ); to 1E-14; should work for top ring
//  can do 3 planets of 12/12/36, and 14/45, with size ratio as required by previous calc (sun2_r/sun_r = 34/31)
//  planets will all be different
// 1:12
// Fave: 1/1/3 and 2/9; this would be 3 planets of 12/12/36 and 12/54 all same, and ring2/ring 6/7
// Fave: 5/3/11 and 1/5; this would be 3 planets of 30/18/66 and 9/45 all same, and ring2/ring 3/4

//a Printing notes

//a Imports
use <mcad/involute_gears.scad>

//a Gear and axle modules
//m gjs_gear
module gjs_gear( r, num_teeth, thickness, dp=dp_gear, is_ring=false )
{
    pitch=num_teeth/((2*r)*dp);
    gear(number_of_teeth=num_teeth,
         diametral_pitch=pitch,
         gear_thickness=thickness,
         rim_thickness=thickness,
         hub_thickness=thickness,
         bore_diameter=0,
         backlash=backlash,
         clearance=is_ring?0:clearance,
         involute_facets=involute_facets,
         pressure_angle=pressure_angle);
}

//m z_neg_axle
module z_neg_axle(X_clearance=1.9, length) {
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

//a Connector and pegs/holes
//m connector
module connector(bearing_ring)
{
    union()
    {
        cylinder( r=connector_radius, h=connector_thickness+bearing_ring );
        for (i=[0:num_connector_pegs-1])
        {
            translate([0,0,connector_thickness+bearing_ring])
            rotate([0,0,i*360/num_connector_pegs])
                translate([connector_circle_radius,0,0])
                cylinder( r=connector_peg_radius, h=connector_peg_thickness );
        }
    }
}
module connector_peg_holes( thickness=connector_thickness )
{
    for (i=[0:num_connector_pegs-1])
    {
        rotate([0,0,i*360/num_connector_pegs])
            translate([connector_circle_radius,0,0])
            cylinder( r=connector_peg_radius, h=thickness*10 );
    }
}

//a Planetary gear stuff
//m sun
module sun( r, num_teeth, has_connector, thickness, bearing_ring )
{
    sun_gear_thickness = thickness*2*sun_disc_gear_thickness_ratio;
    difference()
    {   
        union()
        {
            gjs_gear( r=r, num_teeth=num_teeth, thickness=sun_gear_thickness );
            translate([0,0,sun_gear_thickness]) cylinder(r=r+sun_disc_extra, h=thickness*2-sun_gear_thickness);
            if (has_connector) // Connect from the sun to the neighboring ring
            {
                rotate([180,0,0]) connector(bearing_ring);
            }
        }
        if (has_connector)
        {
            translate([0,0,-thickness-bearing_ring]) cylinder( r=axle_hole_radius, h=thickness*10);
        }
        else
        {
            z_neg_axle( length=thickness*10);
        }
    }
}

//m planet_pairs
module planet_pairs( r1, num1_teeth, thickness1, r2, num2_teeth, thickness2, num_planets, orbit_r, rot_angle )
{
    min_r = ((r1<r2)?r1:r2);
    for (i=[0:num_planets-1])
    {
      rotate([0,0,360*i/num_planets])
          translate([orbit_r,0,0])
      {
          rotate([0,0,rot_angle]) // 180/num1_teeth+
              difference()
          {
              union ()
              {
                  translate([0,0,planet_support_thickness])
                      gjs_gear( r=r1, num_teeth=num1_teeth, thickness=thickness1-planet_support_thickness );
                  translate([0,0,thickness1])
                      gjs_gear( r=r2, num_teeth=num2_teeth, thickness=thickness2-planet_support_thickness );
              }
              union ()
              {
                   translate([-planet_hole_radius*3.0,0,-thickness1]) cylinder( r=planet_hole_radius/2.0, h=thickness1*3/2 ); // Marker hole
                   translate([0,0,-thickness1]) cylinder( r=planet_hole_radius, h=(thickness1+thickness2)*2 ); // hole in planets
              }
          }
      }
    }
}

//m ring
module ring( r, num_teeth, thickness, ring_thickness, bore_radius, base_thickness=0, base_below=true, planets_orbit_r, hand_length=0, has_supports=false, has_connector_holes=false, bearing_ring=0 )
{                                               
    ring_circle_offset = r*ring_circle_ratio;
    circle_space_available = 2*3.14*ring_circle_offset;
    circle_radius = (num_ring_circles>0) ? (circle_space_available/num_ring_circles-ring_circle_gap*2)/2 : 0;
    color([0.3,0.3,0.8])
    union()
    {
        if (base_thickness>0) // Base of the ring - possible with connector holes to help it turn, and with bearing ring
        {
            translate([0,0,(base_below?(-base_thickness):thickness)])
            {
                difference()
                {
                    union()
                    {
                        if (bearing_ring>0) {
                            translate([0,0,(base_below?(-bearing_ring):0)])
                            difference()
                            {
                                cylinder( r=r+ring_thickness, h=bearing_ring+base_thickness );
                                {
                                    translate([0,0,(base_below?-bearing_ring:base_thickness)])
                                    rotate_extrude(convexity = 10)
                                        translate([r/2, 0, 0])
                                        square(bearing_ring*2+0.1);
                                }
                            }
                        } else {
                                cylinder( r=r+ring_thickness, h=base_thickness );
                        }
                    }

                    translate([0,0,-base_thickness-bearing_ring])
                    {
                        cylinder( r=bore_radius, h=(base_thickness+bearing_ring)*3 );
                        for (i=[0:num_ring_circles-1])
                        {
                            rotate([0,0,i*360/num_ring_circles])
                                translate([ring_circle_offset,0,0])
                                cylinder( r=circle_radius, h=(base_thickness+bearing_ring)*3 );
                        }
                    }
                    if (has_connector_holes)
                    {
                        translate([0,0,-base_thickness]) connector_peg_holes(thickness = base_thickness*3);
                    }
                }
            }
        }
        if (hand_length>0) // Add hands
        {
            translate([r+ring_thickness*0.9,-hand_width/2,base_below?(-base_thickness):thickness-base_thickness]) cube( [hand_length, hand_width, thickness] );
        }
        if (has_supports)
        {
            for (i=[0:2])
            {
                rotate([0,0,120*(i+1)])
                    difference()
                {
                    union()
                    {
                        translate([r+ring_thickness*0.9,-support_width/2,base_below?(-base_thickness-bearing_ring):thickness-base_thickness])
                            cube( [support_length, support_width, support_thickness+bearing_ring] );
                        translate([r+ring_thickness+support_length,0,base_below?(-base_thickness-bearing_ring):thickness-base_thickness])
                            cylinder( r=axle_hole_radius+2, h=support_thickness+bearing_ring );
                    }
                    translate([r+ring_thickness+support_length,0,base_below?(-base_thickness):thickness-base_thickness])
                        #z_neg_axle( length=support_thickness*3 );
                }
            }
        }
        difference() // Main body of the ring - cylinder with large gear removed
        {
            cylinder( r=r+ring_thickness, h=thickness );
            rotate([0,0,180/num_teeth]) translate([0,0,-thickness])gjs_gear( r=r, num_teeth=num_teeth, thickness=thickness*3, dp=dp_ring, is_ring=true );
        }
        if (planet_support_thickness>0) // Removed from the main ring, this is a 'support' for the planets which means the planets don't rub on the whole main ring - just the planet support
        {
            translate([0,0,base_below?-base_thickness:thickness+base_thickness])
                rotate([base_below?0:180,0,0])
            difference()
            {
                cylinder( r=planets_orbit_r+planet_support_width+planet_hole_radius, h=base_thickness+planet_support_thickness ); // outer edge to center
                translate([0,0,-planet_support_thickness]) 
                    cylinder( r=planets_orbit_r-planet_support_width-planet_hole_radius, h=base_thickness+3*planet_support_thickness ); // remove inner edge to center
                translate([0,0,base_thickness]) // remove ring for bearing/peg - note we don't go below where we want to here
                    difference()
                {
                    cylinder( r=planets_orbit_r+planet_hole_radius+planet_support_radius_slack, h=base_thickness+planet_support_thickness );
                    translate([0,0,-planet_support_thickness])
                        cylinder( r=planets_orbit_r-planet_hole_radius-planet_support_radius_slack, h=base_thickness+3*planet_support_thickness );
                }
            }
        }
    }
}

//m rotating_ring
module rotating_ring( sun_angle, sun_has_connector, ring2_has_connector_holes, sun_teeth, planets_teeth, planets2_teeth, ring2_teeth, num_planets, ring_size, ring2_size, ring_thickness, hand_length, thickness, base_thickness )
{
    //b Variables
    ring_teeth = sun_teeth + 2*planets_teeth;
    sun_r       = ring_size / ring_teeth * sun_teeth;
    planets_r   = ring_size / ring_teeth * planets_teeth;
    planets2_r  = ring2_size / ring2_teeth * planets2_teeth;
    planets_orbit_r = sun_r+planets_r;

    echo("Ring speed relative to sun",(1-planets2_teeth*ring_teeth/ring2_teeth/planets_teeth)/(1+ring_teeth/sun_teeth),"or 1/",1/((1-planets2_teeth*ring_teeth/ring2_teeth/planets_teeth)/(1+ring_teeth/sun_teeth)));
    echo("RingR",ring_teeth,"Ring2R",ring2_teeth,"Ring2R / Planet2R", ring2_teeth/planets2_teeth);
    x = 1+ring_teeth/sun_teeth;
    x2 = planets2_teeth/ring2_teeth*ring_teeth/planets_teeth-1;
    planet_pos_angle = sun_angle / x;
    planet_rot_angle = -planet_pos_angle*ring_teeth/planets_teeth;
    ring2_rot_angle = -x2*planet_pos_angle;
    
    sun_rotations = [ [0,0,sun_angle+(planets_teeth%2)?0:(180/sun_teeth)], [180,0,0] ];
    sun_translations = [ [0,0,0], [0,ring_size,thickness*2] ];
    ring1_rotations = [ [0,0,180/ring_teeth], [0,0,30] ];
    ring1_translations = [ [0,0,0], [-(ring_size+ring_thickness+2),0,thickness*0.5] ];
    ring2_rotations = [ [0,0,180/ring2_teeth], [180,0,210] ];
    ring2_translations = [ [0,0,thickness*2], [ring_size+ring_thickness+2,0,thickness*1.5] ];

    ring1_layer = 0;
    sun_layer = 1;
    planet_layer = 1;
    ring2_layer = 2;

    //b Sun
    if (show_sun)
    {
        translate([0,0,sun_layer*thickness*explosion])
        translate(sun_translations[show_as_parts])
            rotate(sun_rotations[show_as_parts])
            //rotate([0,0,sun_angle+180/sun_teeth])
            sun( r=sun_r,
                 num_teeth=sun_teeth,
                 has_connector = sun_has_connector,
                 thickness=thickness,
                bearing_ring=2);
    }

    //b Planets
    if (show_planets)
    {
        translate([0,0,planet_layer*thickness*explosion])
        rotate([0,0,planet_pos_angle]) planet_pairs( r1         = planets_r,
                                                     num1_teeth = planets_teeth,
                                                     thickness1 = thickness*planet1_thickness_ratio,
                                                     r2         = planets2_r,
                                                     num2_teeth = planets2_teeth,
                                                     thickness2 = thickness,
                                                     num_planets= num_planets,
                                                     orbit_r    = planets_orbit_r,
                                                     rot_angle=planet_rot_angle );
    }

    //b Ring 1
    if (show_ring1)
    {
        translate([0,0,ring1_layer*thickness*explosion])
        translate(ring1_translations[show_as_parts])
            rotate(ring1_rotations[show_as_parts]) ring( r=ring_size,
                                                         num_teeth=ring_teeth,
                                                         thickness=thickness*planet2_thickness_ratio,
                                                         bore_radius=sun_has_connector?connector_hole_radius : axle_hole_radius,
                                                         ring_thickness=ring_thickness,
                                                         base_thickness=base_thickness,
                                                         planets_orbit_r = planets_orbit_r,
                                                         hand_length = 0,
                                                         has_supports = true,
                                                         has_connector_holes = false,
                                                         bearing_ring = 2 );
    }

    //b Ring 2
    if (show_ring2)
    {
        translate([0,0,ring2_layer*thickness*explosion])
        translate(ring2_translations[show_as_parts])
            rotate(ring2_rotations[show_as_parts]) 
            rotate([0,0,ring2_rot_angle])   ring( r=ring2_size,
                                                  num_teeth=ring2_teeth,
                                                  thickness=thickness,
                                                  bore_radius=axle_hole_radius,
                                                  ring_thickness=ring_thickness+ring_size-ring2_size,
                                                  base_thickness=base_thickness,
                                                  base_below=false,
                                                  planets_orbit_r = planets_orbit_r,
                                                  hand_length = hand_length,
                                                  has_supports = false,
                                                  has_connector_holes = ring2_has_connector_holes,
                                                  bearing_ring = 2 );
    }

    //b All done
}

//a Clock modules
//m clock
module clock( minutes_sun_angle,
              clock_diameter,
              ring_thickness,
              thickness,
              base_thickness )
{
    // 60:1
    if (show_minutes)
    {
        rotating_ring( sun_angle = minutes_sun_angle,
                       sun_has_connector = false,
                       ring2_has_connector_holes = true,
                       sun_teeth = 9,
                       planets_teeth = 36,
                       planets2_teeth = 30,
                       ring2_teeth = 81,    // MUST be multiple of # planets for identical planets (as we build) 75 if larger
                       num_planets = 3,
                       ring_size  = clock_diameter/2,
                       ring2_size = clock_diameter/2*15/17,
                       ring_thickness = 7,
                       hand_length = minute_hand_length,
                       thickness = thickness,
                       base_thickness = base_thickness
            );
    }
    // 12:1
    if (show_hours)
    {
        translate([0,0,(thickness*8*(1+explosion))])
            rotating_ring( sun_angle = minutes_sun_angle/60,
                           sun_has_connector = true,
                           ring2_has_connector_holes = false,
                           sun_teeth = 15,
                           planets_teeth = 15,
                           planets2_teeth = 8, // 12 if larger
                           ring2_teeth = 36,   // 54 if larger
                           num_planets = 3,
                           ring_size  = clock_diameter/2,
                           ring2_size = clock_diameter/2*6/7,
                           ring_thickness = 7,
                           hand_length = hour_hand_length,
                           thickness = thickness,
                           base_thickness = base_thickness
                );
    }
}

//a Global constants
pressure_angle=20;
//dp=1.0; // leave at one or we get gaps between everything
dp_gear=0.99; // basic scale factor for diameter of our gears
dp_ring=1.00; // basic scale factor for diameter of cutout for our rings
backlash=0.25; // amount of space to accommodate build issues
clearance=0.5; // how much space to provide by moving the rim in

clock_diameter = 100;
thickness      = 2.9; // Average thickness of planet gears - two of these plus base is a 'slice' - use to be 2
base_thickness = 1; // Thickness of base of each ring
axle_hole_radius=2.85;
hour_hand_length = 5;
minute_hand_length = 10;

hand_width = 2;
support_length = 20;
support_width = 5;
support_thickness = base_thickness+thickness;

sun_disc_gear_thickness_ratio = 0.6; // fraction of sun gear that is gear rather than disc
sun_disc_extra    = 0.7; // extra amount in mm around the sun for the disc

planet_hole_radius = 3.0;      //  radius of hole in center of planet pair - used to be 1.5
planet1_thickness_ratio = 0.9; // thickness of planet pair to allocate to lower planet (which should be LARGER)
planet2_thickness_ratio = 2 - planet1_thickness_ratio; // thickness to allocate to upper planet - must sum to 2 with planet1_thickness_ratio
planet_support_thickness = 0.3;    // added to the ring, removed from the planets
planet_support_width = 3;          // bar sizes around the planet_hole
planet_support_radius_slack = 0.2; // mm slack in the support ring hole compared to the planet hole radius

num_ring_circles = 6; // Number of circles in a ring
ring_circle_gap = 4; // gap between circles in a ring, kinda
ring_circle_ratio = 0.6; // fraction of ring radius at which to place ring circles

num_connector_pegs = 3;
connector_peg_radius = 3;
connector_circle_radius = 9;
connector_radius = 12;
connector_hole_radius = connector_radius + 0.1; // with extra slack for manufacture
connector_thickness = base_thickness;
connector_peg_thickness = base_thickness;

//a Build and animation constants
//v Defaults
draft = true;
explosion = 0; // Explode the Z axis
time_scale = 60;
sun_angle = 360*$t*time_scale;

show_as_parts = 0;
show_sun     = false;
show_planets = false;
show_ring1   = false;
show_ring2   = false;

show_minutes = false;
show_hours   = false;

//v Overrides for the build
num_ring_circles = 0; // Lose ring circles
draft = false;
explosion = 1; // 0 for as parts

//show_as_parts = 1;
show_sun     = true;
show_planets = true;
show_ring1   = true;
show_ring2   = true;

show_minutes = true;
show_hours   = true;

//v Derived constants
$fs = draft ? 2: 0.5; // minimum length of edge/etc in polygon from circle/sphere/cylinder
$fa = draft ? 20 : 3;   // minimum angle of edge/etc in polygon from circle/sphere/cylinder
involute_facets = draft ? 3: 6; // default is 5; number of facets for each tooth

//a Toplevel module
clock( minutes_sun_angle = sun_angle,
       clock_diameter = clock_diameter,
       ring_thickness = 7,
       thickness = thickness,
       base_thickness = base_thickness
    );

// originally (clk 2.0)
//    16.0 32.0 21.0 {1: (1.0, 2.0, 5.0), 2: (9.0, 25.0), 3: (80.0, 75.0, 1.0666666666666667)} 1.42108547152e-14
//   9 / 18 / 45 ; 27 / 75 ; ratio 16/15

// too small in the center - planets overlap
// ?? 14.0 70.0 36.0 {1: (1.0, 5.0, 11.0), 2: (4.0, 11.0), 3: (154.0, 132.0, 1.1666666666666667)} 1.42108547152e-14
//   6 30 66 ; 24 66; ratio 7/6

// teeth too small on the outside?
// ?? 11.0 33.0 18.0 {1: (1.0, 3.0, 7.0), 2: (13.0, 35.0), 3: (77.0, 70.0, 1.1)} 1.42108547152e-14
//   9 27 63 ; 39 105; ratio 11/10

// At clock_diameter of 75mm this is too small at the sun for the axle - needs to be 100mm
// 17.0 68.0 35.0 {1: (1.0, 4.0, 9.0), 2: (10.0, 27.0), 3: (153.0, 135.0, 1.1333333333333333)} -2.13162820728e-14
//   9 / 36 / 81; 30 / 81; ratio 17/15 
