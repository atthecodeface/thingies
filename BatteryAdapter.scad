//a Version notes
// First versions have inner_d for AA batteries of 14.7; this is probably a teensy bit tight

//a Globals
module holey_cylinder( outer_d, inner_d, h, ncircles=12, thickness=2 )
{
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

module aa_to_c_adapter()
{
 holey_cylinder( outer_d = 26.2,
		 inner_d = 14.7,
		 thickness = 2,
		 ncircles = 12,
		 h       = 3.0 );
}

!aa_to_c_adapter();
