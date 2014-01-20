//a Version notes

//a Globals
module support_grid( width, height, thickness=1, min_thickness=0, gap_width=0.5, max_gap_height=4 )
{
// this builds a cuboid of width * height, of thickness 'thickness', with gaps such that the minimum bar thickness is 'min_thickness', and the gaps are approximately (at most?) gap_width wide. The gap height is also specified.
// Typical thickness is 1.5mm (>min_thickness)
// Then the min_thickness is the minimum thickness of a bar that a printer can print reliably vertically, given that it is also 'thickness' in the other dimension of a slice
// So if a printer can print 1.5mm by 0.3mm, then min_thickness can be 0.3
// gap_width is then the largest gap the printer can reasonably bridge - so maybe 1.5-2mm
  support_thickness = (min_thickness>0) ? min_thickness : thickness;
  hgap_separation = (gap_width+support_thickness);
  num_hgaps = floor(((width-hgap_separation)/2) / hgap_separation + 0.99);
  hmiddle_gap = width-2*num_hgaps*hgap_separation - 0*support_thickness;

  num_vgaps = floor((height-2*support_thickness) / max_gap_height+1.99);
  vgap_separation = (height-support_thickness) / num_vgaps;
  vgap_height = vgap_separation-support_thickness;
  echo("Vgaps",num_vgaps,"Hgaps",num_hgaps,"width",width,"support thickness",support_thickness,"hgap width",gap_width,"hmiddle_gap",hmiddle_gap);
  difference()
  {
   cube( [width, height, thickness] ) ;
   for (y=[0:num_vgaps-1])
   {
    if (hmiddle_gap>0)
    {
 	translate([(width-hmiddle_gap)/2,support_thickness+y*vgap_separation,-thickness]) cube( [hmiddle_gap,vgap_height,thickness*3] );
    }
    for (i=[0:num_hgaps-1])
    {
       translate([          i*hgap_separation,support_thickness+y*vgap_separation,-thickness]) cube( [gap_width,vgap_height,thickness*3] );
       translate([width-(i+1)*hgap_separation+support_thickness,support_thickness+y*vgap_separation,-thickness]) cube( [gap_width,vgap_height,thickness*3] );
    }
   }
  }
}

//support_grid( thickness=1.5, width=30, height=10, min_thickness=0.4, gap_width=2.0 );

module holey_cylinder( h )
{
 outer_d = 26.2;
 inner_d = 14.7;
 thickness = 2;
 ncircles = 12;
 circle_angle = 360/ncircles;
 circle_d = (outer_d-inner_d-2*thickness)/2;
 translate([outer_d/2,0,0])
   difference()
   {
     difference()
       {
	 cylinder( r=outer_d/2, h=h );
	 cylinder( r=inner_d/2, h=h );
       }
         for (i=[0:ncircles-1])
	    {
	      rotate([0,0,(i+0.5)*circle_angle])
		translate( [circle_d/2+inner_d/2+thickness/2,0,0] )
		cylinder( r=circle_d/2, h=h, $fs=0.5 );
	    }
   }
}

sh = 6;
h = 10;
sw = 10;
//translate([0, 0,0]) rotate([90,0,0])  support_grid( width=sw, height=sh, thickness=1.5, min_thickness=1.0, gap_width=1.5 );
//translate([0,-2.4,0]) rotate([90,0,0])  support_grid( width=sw, height=sh, thickness=1.5, min_thickness=1.0, gap_width=1.5 );
//translate([0,0,0]) rotate([0,-90,0]) holey_cylinder(h=4.0);
//translate([w,0,h])     rotate([90,0,90]) cylinder( h=1.5, r=h );
//holey_cylinder(h=1.5);
//holey_cylinder(h=3.0);

$fs=0.4;
module bearing_race( bearing_diameter, bearing_race_radius, wall_thickness, slack, center_on_z )
{
    inner_radius = bearing_race_radius-wall_thickness - bearing_diameter/2 + slack;
    outer_radius = bearing_race_radius+wall_thickness + bearing_diameter/2 + slack;
    height = bearing_diameter/2+wall_thickness+slack;
    echo("Outer radius",outer_radius, "Inner radius",inner_radius);
    translate([0,0,center_on_z?(-height):0])
    difference()
    {
        rotate_extrude() {
            if (tubular)
            {
                translate([bearing_race_radius,bearing_race_radius/2,0]) circle(r=(outer_radius-inner_radius)/2);
            }
            else
            {
                translate([inner_radius,0,0]) square(outer_radius-inner_radius);
            }
        }
        rotate_extrude()
        {
            translate([bearing_race_radius+0*bearing_diameter/2,wall_thickness+bearing_diameter/2,0]) circle(r=bearing_diameter/2);
        }
    }
}
intersection()
{
    translate([0,0,0]) bearing_race( bearing_diameter=3, bearing_race_radius=5, wall_thickness=1, slack=0.1, center_on_z=true );
    translate([0,0,-5]) cylinder( r=5-0.1, h=20 );
    //translate([-100,-100,0]) cube([200,200,200]);
}

intersection()
{
    translate([0,0,0]) bearing_race( bearing_diameter=3, bearing_race_radius=5, wall_thickness=1, slack=0.1, center_on_z=true );
    difference()
    {
       translate([-100,-100,-100]) cube([200,200,200]);
       translate([0,0,-5]) cylinder( r=5+0.1, h=20 );
     }
}
