//a Globals
// First model has pegs, which we need to remove
// The side notches are also unnecessary
// The eye holes are slightly too big even for the apple earbuds
// The bottom notches could be slightly deeper (not absolutely necessary, 1mm poss)
//
// Second model works very well with the Apple ishuffle earbuds

//a Modules
module ear_bud( base_d, ear_d, depth )
{
  cylinder( h=depth*0.9, r1=base_d/2, r2=ear_d/2 );
  translate([0,0,depth*0.9]) cylinder( h=depth*0.1, r=ear_d/2 );
}

module ear_bud_with_wire( bud, wire )
{
  // bud is [ base diameter, ear diameter, height ]
  // wire is [ body diameter, body length ]
  translate([0,0,-wire[0]/2]) ear_bud( depth=bud[2], base_d=bud[0], ear_d=bud[1] );
  rotate([0,90,0])            cylinder( h=wire[1], r=wire[0]/2, $fs=0.5 );
}

module headphone_35mm_plug_straight( body, strain_relief )
{
  rotate([0,90,0])                             cylinder( h=0.5, r1=2.6/2, r2=3.5/2, $fs=0.5 );
  translate([0.5,0,0])        rotate([0,90,0]) cylinder( h=3.0, r2=2.6/2, r1=3.5/2, $fs=0.5 );
  translate([3.5,0,0])        rotate([0,90,0]) cylinder( h=3.5, r=3.0/2, $fs=0.5 );
  translate([7,0,0])          rotate([0,90,0]) cylinder( h=3.5, r=3.2/2, $fs=0.5 );
  translate([10.5,0,0])       rotate([0,90,0]) cylinder( h=3.5, r=3.5/2, $fs=0.5 );
  translate([14,0,0])         rotate([0,90,0]) cylinder( h=body[1], r=body[0]/2, $fs=0.5 );
  translate([14+body[1],0,0]) rotate([0,90,0]) cylinder( h=strain_relief[1], r=strain_relief[0]/2, $fs=0.5 );
}

// apple shuffle headphones
//ear_bud_with_wire( bud=[5,16,12], wire=[5,26] );
//translate([0,10,0]) headphone_35mm_plug_straight( body=[5,12], strain_relief=[3.5,5] );

// ear_bud_with_wire( bud=[5,16,12], wire=[5,26] );
// translate([0,10,0]) headphone_35mm_plug_straight( body=[5,12], strain_relief=[3.5,5] );

ear_bud       = [5,16,12];
ear_bud_wire  = [5,26];
plug_body     = [5,12];
plug_strain_relief = [3.5,5];
plug = [ plug_body, plug_strain_relief ];
wire_radius = 9;

module cable_wrap_headphone_plug_hole(length)
{
  scale([1,1,1.3]) rotate([0,90,0]) cylinder( h=length, r=3.5/2, $fs=0.5 );
}

module cable_wrap_earphone_hole(length, width, height, ear_bud, plug, countersink )
{
  plug_room = plug[0][0]*1;
  ear_plug_r0 = ear_bud[1]/2;
  ear_plug_r1 = ear_bud[1]/2+0.5-1*countersink;
  ear_plug_r2 = ear_bud[1]/2+1.0;
  ear_plug_offset = ear_plug_r2/2 + plug_room/2;
  translate( [-length+14+ear_plug_r2,0,0] )      
    {
      union()
      {
	hull()
	  {
	    translate([0,-ear_plug_offset,0]) cylinder( h=height, r2=ear_plug_r0, r1=ear_plug_r1 );
	    translate([0,+ear_plug_offset,0]) cylinder( h=height, r2=ear_plug_r0, r1=ear_plug_r1 );
	  }
	translate([0,-ear_plug_offset,0]) cylinder( h=height, r2=ear_plug_r1, r1=ear_plug_r2 );
	translate([0,+ear_plug_offset,0]) cylinder( h=height, r2=ear_plug_r1, r1=ear_plug_r2 );
	translate([0,-plug[1][0]/2,0]) cube( [plug[1][1]+wire_radius,plug[1][0],height] );
      }
    }
}

module cable_wrap_body( length, width, height, ear_bud=ear_bud, plug=plug )
{
  space=4;
  scale([1,1,1/2]) minkowski()
    {
      translate([-space/2,-space/2]) cube([space,space,height]);
      hull()
      {
        cable_wrap_earphone_hole( length=length, width=width, height=height, ear_bud=ear_bud, plug=plug, countersink=0 );
        scale([1,(width-space)/(length-space),1]) cylinder( r=length-space, h=height );
      }
    }
}

//	  translate( [-(length-space-ear_bud[1]/2),0,0] ) cylinder( h=height, r=ear_bud[1]/2 );
//	  translate( [length-space-ear_bud[1]/2,0,0] ) cylinder( h=height, r=ear_bud[1]/2 );
//	  translate( [length-space*2-ear_bud[1]/2,width-20,0] ) cylinder( h=height, r=ear_bud[1]/2 );
//	  translate( [length-space*2-ear_bud[1]/2,-width+20,0] ) cylinder( h=height, r=ear_bud[1]/2 );
//	  translate( [0,width-space-ear_bud[1]/2,0] )    cylinder( h=height, r=ear_bud[1]/2 );
//	  translate( [0,-(width-space-ear_bud[1]/2),0] ) cylinder( h=height, r=ear_bud[1]/2 );

module cable_wrap_notch( length, width, height, angle, notch )
{
  scale([1,width/length,1])
    {
      rotate([0,0,angle])
	translate( [length-notch[0],-notch[1]/2,0] )
	scale([1,1,1/2]) minkowski()
	{
	  cylinder(r=1,h=height, $fs=0.5);
	  cube( [notch[0]*2,notch[1],height] );
	}
    }
}

module cable_wrap_tie_off( length, width, height, scales )
{
  intersection()
    {
      difference()
	{
	  scale( [scales[0],scales[0]*width/length,1] ) { cylinder( r=length, h=height ); }
	  scale( [scales[1],scales[1]*width/length,1.1] ) { cylinder( r=length, h=height ); }
	}
      translate([0,-width,-height]) cube([length,width*2,height*3]);
    }
}

module cable_wrap_peg( peg )
{
  translate([peg[0]/2,0,0]) cylinder( r=peg[0]/2, h=peg[1], $fs=0.1 );
}

module cable_wrap_peg_range_recurse( peg, peg_separations, index )
{
  cable_wrap_peg( peg );
  if (index<len(peg_separations))
    {
      translate([peg[0]+peg_separations[index],0,0]) cable_wrap_peg_range_recurse( peg, peg_separations, index+1 );
    }
}

function vec_sum(v,index=0) = (index>=len(v)) ? 0 : (v[index]+vec_sum(v,index+1));

module cable_wrap_peg_range( peg, peg_separations, angle, length, width, scale=1.0 )
{
  rscale = scale;
  peg_range_width = vec_sum(peg_separations) + peg[0]*(len(peg_separations)+1);
  translate([length*cos(angle)*rscale,width*sin(angle)*rscale,0])
    rotate([0,0,angle])
    rotate([0,0,90])
    translate([-peg_range_width/2,0,0])
    cable_wrap_peg_range_recurse( peg, peg_separations, 0 );
}

module cable_wrap( length, width, height, ear_bud, plug, notch )
{
  lw = sqrt(length*width);
  union()
  {
    // length is x, width is y
    difference() {
      cable_wrap_body( length=length, width=width, height=height, ear_bud=ear_bud, plug=plug );
      translate( [-length-1/2,0,height/2] )                 cable_wrap_headphone_plug_hole(length=18);
      translate( [0,0,-0.01] )                              cable_wrap_earphone_hole( length=length, width=width, height=height+0.02, ear_bud=ear_bud, plug=plug, countersink=1 );
      //      for (i=[25,70,160,-160,-70,-25])
      for (i=[25,160,-160,-25])
	{
	  cable_wrap_notch( length=length, width=width, height=height+0.02, notch=notch, angle=i );
	}
      translate([0,0,-0.01]) cable_wrap_tie_off( length=length, width=width, height=height*2, scales=tie_off_scales );
    }
    translate([0,0,height-0.01])
      {
	for (i=[5:7])
	  {
	    //cable_wrap_peg_range( peg=peg, peg_separations=peg_separations, length=length, width=width, angle=-25, scale=i*0.1 );
	    //cable_wrap_peg_range( peg=peg, peg_separations=peg_separations, length=length, width=width, angle=25, scale=i*0.1 );
	  }
      }
  }
}

length=40;
width=25;
height=4;
notch = [7,10];
peg = [1.3,1.5];
peg_separations = [1.0,1.9,1.0];
tie_off_scales = [0.4,0.2];
tie_off_scales = [0.65,0.15];

cable_wrap( length=length, width=width, height=height, ear_bud=ear_bud, plug=plug, notch=notch );

//translate([-length+2,0,height/2]) headphone_35mm_plug_straight( body=plug[0], strain_relief=plug[1] );
//translate([-length+15+(ear_bud[1]+3*ear_bud[0])*3/8, plug[0][0]*1/2+ear_bud[1]/2,height+ear_bud_wire[0]/2]) rotate([180,0,-30]) ear_bud_with_wire( ear_bud, ear_bud_wire );
//translate([-length+15+(ear_bud[1]+3*ear_bud[0])*3/8,-plug[0][0]*1/2-ear_bud[1]/2,height+ear_bud_wire[0]/2]) rotate([180,0,  5]) ear_bud_with_wire( ear_bud, ear_bud_wire );


// Note that a peg of smaller than 1.3mm is not reliably printed on standard slic3r settings
// Hence peg [1.3,1.5] was chosen for our pegs. Before we removed them.
//length=10;
//width=20;
//union()
//{
//    translate([-8,-30,0]) cube([16,30,1]);
//    translate([0,0,0.99]) for (i=[1:14])
//    {
//        cable_wrap_peg_range( peg=[0.5+i*0.1,1.2], peg_separations=peg_separations, length=length, width=width, angle=-90, scale=i*0.1 );
//    }
//}
