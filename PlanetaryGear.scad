//A Old
// A / B / A+2B : A / B / A+2B => x2=0
x2=0;
// 8 / 8 / 24 : 6 / 10 / 26 => x2=-0.14
x2 = -0.14;
// 10 / 6 / 22 : 9 / 7 / 23 => x2=-0.12
x2 = -0.12;
// 10 / 6 / 22 : 5 / 11 / 27 => x2=-0.5
x2 = -0.5;
// 10 / 6 / 22 : 4 / 12 / 28 => x2=-0.58
x2 = -0.58;
// 4 / 12 / 28 : 10 / 6 / 22 => x2=-0.58
x2 = 0.37;
// 10 / 6 / 22 : 6 / 10 / 26 => x2=-0.58
x2 = 1;
//x2 = 2*ring2_d[0]/planets2_d[0]*planets_d[0]/ring_d[0]-1; //did not work
//x2 = planets2_d[0]/ring2_d[0]*ring_d[0]/planets_d[0]-1;

//A Notes for clock
// Need to add an optional connector to the sun, and make the axle optional with instead an axle hole
// The connector has a radius r (12mm?) and depth h=base_thickness, and has 6 (num_conn) further connector cylinders (1.5mm radius?) in a circle (radius 9mm?) around the axle. Note axle hole is 6mm diameter
// The second ring1, for the 12:1, then needs a connector-sized hole instead of an axle hole (add slack of 0.1mm to the radius)
// The first ring2 needs the connector cylinder holes in it
// A third ring1 can then be made with no ring gear, as a cap, but with the connector sized hole in the base area. It can have a slightly thicker base_thickness.

//A Printing notes
// First print
//backlash=0.25;
//clearance=0.2;
//pressure_angle=20;
//dp=1.0; // leave at one or we get gaps between everything
//thickness=2;
//scale_factor = 0.9; //1.0; //0.9;
//$fs = 0.2;
//               sun_teeth = 15,
//               planets_teeth = 30,
//               planets2_teeth = 27,
//               ring2_teeth = 75,
//               num_planets = 3,
//               ring_size  = 80  * scale_factor,
//               ring2_size = 75  * scale_factor,
//               ring_thickness = 7,
//               thickness = thickness
// Z axle was bad - reprinting sun with z axle with wider holes
// 1.1: Reprinted with bigger axle
// 1.2: Reprinted with slight scale reduction as 100% leads to jamming as print is a teensy bit bigger than expected

// Second print. Added bases to the rings, gave a teensy bit of space between cogs, printed at 40% size
// print takes about 3 hours
// too many teeth probably
// backlash=0.25;
// clearance=0.2;
// pressure_angle=20;
// dp_gear=0.98; // basic scale factor for diameter of our gears
// dp_ring=1.01; // basic scale factor for diameter of cutout for our rings
// clearance=0.5; // how much space to provide by moving the rim in
// 
// thickness=2;
// scale_factor = 0.9; //1.0; //0.9;
// scale_factor = 0.4;
// base_thickness=1;
// axle_hole_radius=3;
// 
// $fs = 0.2;
// rotating_ring( sun_angle=sun_angle,
//                sun_teeth = 15,
//                planets_teeth = 30,
//                planets2_teeth = 27,
//                ring2_teeth = 75,
//                num_planets = 3,
//                ring_size  = 80  * scale_factor,
//                ring2_size = 75  * scale_factor,
//                ring_thickness = 7,
//                thickness = thickness,
//                base_thickness = base_thickness
//     );
// To reduce teeth, maybe sun_teeth=9, planets_teeth=18, ring1 is 45
//    planets2 teeth of 18, ring2 teeth of 50

// Further notes on v2:
// gears are too separated; try dp_gear=0.99
// axle hole of radius is too large, try 2.9
// ring circles are too close together, probably remove
// add attach holes to ring2
// add div-12 epicycles for hours

use <mcad/involute_gears.scad>

module gjs_gear( r, num_teeth, thickness, dp=dp_gear )
{
    pitch=num_teeth/((2*r)*dp);
    gear(number_of_teeth=num_teeth,
         diametral_pitch=pitch,
         gear_thickness=thickness,
         rim_thickness=thickness,
         hub_thickness=thickness,
         bore_diameter=0,
         backlash=backlash,
         clearance=clearance,
         pressure_angle=pressure_angle);
}

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

module sun( r, num_teeth, thickness )
{
    difference()
    {   
        union()
        {
            gjs_gear( r=r, num_teeth=num_teeth, thickness=thickness );
            translate([0,0,thickness]) cylinder(r=r+1, h=thickness);
        }
        z_neg_axle( length=thickness*10);
    }
}

module planet_pairs( r1, num1_teeth, thickness1, r2, num2_teeth, thickness2, num_planets, orbit_r, rot_angle )
{
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
                  gjs_gear( r=r1, num_teeth=num1_teeth, thickness=thickness1 );
                  translate([0,0,thickness1])
                      gjs_gear( r=r2, num_teeth=num2_teeth, thickness=thickness2 );
              }
              translate([0,0,-thickness1]) cylinder( r=0.5*((r1<r2)?r1:r2), h=(thickness1+thickness2)*2 );
          }
      }
    }
}

module ring( r, num_teeth, thickness, ring_thickness, base_thickness=0, base_below=true )
{
    num_circles = 6;
    circle_offset = (r-axle_hole_radius)*2/3;
    circle_space_available = 2*3.14*circle_offset;
    circle_radius = (circle_space_available/num_circles-4)/2;
    union()
    {
        echo("base thickness",base_thickness);
        if (base_thickness>0)
        {
            translate([0,0,(base_below?(-base_thickness):thickness)])
            {
                difference()
                {
                    cylinder( r=r+ring_thickness, h=base_thickness );
                    translate([0,0,-base_thickness])
                    {
                        cylinder( r=axle_hole_radius, h=base_thickness*3 );
                        for (i=[0:num_circles-1])
                        {
                            rotate([0,0,i*360/num_circles])
                                translate([circle_offset,0,0])
                                cylinder( r=circle_radius, h=base_thickness*3 );
                        }
                    }
                }
            }
        }
        difference()
        {
            cylinder( r=r+ring_thickness, h=thickness );
            rotate([0,0,180/num_teeth]) translate([0,0,-thickness])gjs_gear( r=r, num_teeth=num_teeth, thickness=thickness*3, dp=dp_ring );
        }
    }
}

module rotating_ring( sun_angle, sun_teeth, planets_teeth, planets2_teeth, ring2_teeth, num_planets, ring_size, ring2_size, ring_thickness, thickness, base_thickness )
{
    ring_teeth = sun_teeth + 2*planets_teeth;
    sun_r       = ring_size / ring_teeth * sun_teeth;
    planets_r   = ring_size / ring_teeth * planets_teeth;
    planets2_r  = ring2_size / ring2_teeth * planets2_teeth;

    echo("Ring speed relative to sun",(1-planets2_teeth*ring_teeth/ring2_teeth/planets_teeth)/(1+ring_teeth/sun_teeth),"or 1/",1/((1-planets2_teeth*ring_teeth/ring2_teeth/planets_teeth)/(1+ring_teeth/sun_teeth)));
    echo("RingR",ring_teeth,"Ring2R",ring2_teeth,"Ring2R / Planet2R", ring2_teeth/planets2_teeth);
    x = 1+ring_teeth/sun_teeth;
    x2 = planets2_teeth/ring2_teeth*ring_teeth/planets_teeth-1;
    planet_pos_angle = sun_angle / x;
    planet_rot_angle = -planet_pos_angle*ring_teeth/planets_teeth;
    ring2_rot_angle = -x2*planet_pos_angle;
    
    sun_rotations = [ [0,0,sun_angle+180/sun_teeth], [180,0,0] ];
    sun_translations = [ [0,0,0], [0,ring_size,thickness*2] ];
    ring1_rotations = [ [0,0,180/ring_teeth], [0,0,0] ];
    ring1_translations = [ [0,0,0], [-(ring_size+ring_thickness+2),0,thickness*0.5] ];
    ring2_rotations = [ [0,0,180/ring2_teeth], [180,0,0] ];
    ring2_translations = [ [0,0,thickness*2], [ring_size+ring_thickness+2,0,thickness*1.5] ];
    echo("Sun angle",sun_angle);
    if (show_sun)
    {
        translate(sun_translations[show_as_parts])
            rotate(sun_rotations[show_as_parts])
            //rotate([0,0,sun_angle+180/sun_teeth])
            sun( r=sun_r,
                 num_teeth=sun_teeth,
                 thickness=thickness );
    }
    if (show_planets)
    {
        rotate([0,0,planet_pos_angle]) planet_pairs( r1         = planets_r,
                                                     num1_teeth = planets_teeth,
                                                     thickness1 = thickness,
                                                     r2         = planets2_r,
                                                     num2_teeth = planets2_teeth,
                                                     thickness2 = thickness,
                                                     num_planets= num_planets,
                                                     orbit_r    = sun_r+planets_r,
                                                     rot_angle=planet_rot_angle );
    }
    if (show_ring1)
    {
        translate(ring1_translations[show_as_parts])
        rotate(ring1_rotations[show_as_parts]) ring( r=ring_size,
                                           num_teeth=ring_teeth,
                                           thickness=thickness,
                                           ring_thickness=ring_thickness,
                                           base_thickness=base_thickness );
    }

    if (show_ring2)
    {
        translate(ring2_translations[show_as_parts])
            rotate(ring2_rotations[show_as_parts]) 
            rotate([0,0,ring2_rot_angle])   ring( r=ring2_size,
                                              num_teeth=ring2_teeth,
                                              thickness=thickness,
                                                  ring_thickness=ring_thickness,
                                                  base_thickness=base_thickness,
                base_below=false);
    }
}

backlash=0.25;
clearance=0.2;
pressure_angle=20;
//dp=1.0; // leave at one or we get gaps between everything
dp_gear=0.99; // basic scale factor for diameter of our gears
dp_ring=1.01; // basic scale factor for diameter of cutout for our rings
clearance=0.5; // how much space to provide by moving the rim in

thickness=2;
scale_factor = 0.9; //1.0; //0.9;
scale_factor = 0.4;
base_thickness=1;
axle_hole_radius=2.9;

$fs = 0.2;
time_scale = 60;
sun_angle = 360*$t*time_scale;

show_sun     = false;
show_planets = false;
show_ring1   = false;
show_ring2   = false;

show_as_parts = 0;
show_sun     = true;
show_planets = true;
show_ring1   = true;
show_ring2   = true;

rotating_ring( sun_angle = sun_angle,
               sun_teeth = 15,
               planets_teeth = 15,
               planets2_teeth = 12,
               ring2_teeth = 54,
               num_planets = 3,
               ring_size  = 7 * 11  * scale_factor,
               ring2_size = 6 * 11  * scale_factor,
               ring_thickness = 7,
               thickness = thickness,
               base_thickness = base_thickness
    );


// 1:16
//rotating_ring( sun_r=6, planets_r = 6, sun2_r = 8 );
// 1:21
//rotating_ring( sun_r=6, planets_r = 7, sun2_r = 8 );
// 1:40
//rotating_ring( sun_r=6, planets_r = 10, sun2_r = 8 );
// 1:18.33
//rotating_ring( sun_r=6, planets_r = 10, sun2_r = 10 );
// 1:59.5  sun_r = 12, planets_r = 21, sun2_r = 15,
// 1:60
// Fave: rotating_ring( sun_r=16, planets_r = 32, sun2_r = 21 ); to 1E-14; could use 4 planets if can futz ring2
//  can do 3 planets of 15/30/75 and 27/75, all three planets the same, size ratio as required at ring2/ring 75/80
// Fave: rotating_ring( sun_r=31, planets_r = 31, sun2_r = 34 ); to 1E-14; should work for top ring
//  can do 3 planets of 12/12/36, and 14/45, with size ratio as required by previous calc (sun2_r/sun_r = 34/31)
//  planets will all be different
// 2nd Fave: rotating_ring( sun_r=11, planets_r = 33, sun2_r = 18 ); should work for top ring
// rotating_ring( sun_r=11, planets_r = 24, sun2_r = 15 );
// rotating_ring( sun_r=19, planets_r = 20, sun2_r = 21 );
// rotating_ring( sun_r=14, planets_r = 52, sun2_r = 27 );
//               
// For 1:12
// We can do 
// 1/1/3 and 2/9; this would be 3 planets of 12/12/36 and 12/54 all same, and ring2/ring 6/7
// 5/3/11 and 1/5; this would be 3 planets of 30/18/66 and 9/45 all same, and ring2/ring 3/4
