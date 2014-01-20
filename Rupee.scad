
module wedge( length, width, height )
{
    rotate(v=[0,0,1],a=90) 
    rotate(v=[1,0,0],a=90) 
    linear_extrude( height=length,
                    center=false )
    {
        polygon([[0,0], [width,0], [0,height]]);
    }
}

module diamond_quarter( width=20, ridge_length=5, body_length=25, peak_length=55, height=30, truncation=15 )
{
    A = [ 0, width, 0 ];
    B = [ body_length, width, 0 ];
    C = [ peak_length, 0, 0 ];
    D = [ 0, 0, height ];
    E = [ ridge_length, 0, height ];

    intersection()
    {
        wedge( length=peak_length, width=width, height=height );
        translate([peak_length,0,0]) rotate([0,0,-30]) translate([-9*peak_length,-10*width,0]) wedge( length=peak_length*10, width=10*width, height=10*height );
        cube( [peak_length*2, width*2, truncation] );
    }
}

module diamond( width=20, ridge_length=5, body_length=25, peak_length=55, height=30, truncation=15 )
{
    union()
    {
        diamond_quarter( width=width, ridge_length=ridge_length, body_length=body_length, peak_length=peak_length, height=height, truncation=truncation );
        mirror([1,0,0]) diamond_quarter( width=width, ridge_length=ridge_length, body_length=body_length, peak_length=peak_length, height=height, truncation=truncation );
        mirror([0,1,0])
        {
            diamond_quarter( width=width, ridge_length=ridge_length, body_length=body_length, peak_length=peak_length, height=height, truncation=truncation );
            mirror([1,0,0]) diamond_quarter( width=width, ridge_length=ridge_length, body_length=body_length, peak_length=peak_length, height=height, truncation=truncation );
        }
    }        
}

module diamond_shell( width=20, ridge_length=5, body_length=25, peak_length=55, height=30, truncation=15, shell_thickness=3 )
{
    difference()
    {
        #diamond( width=width,
                 ridge_length=ridge_length,
                 body_length=body_length,
                 peak_length=peak_length,
                 height=height, 
                 truncation=truncation );
        translate([0,0,-shell_thickness])
        diamond( width=width,
                 ridge_length=ridge_length,
                 body_length=body_length,
                 peak_length=peak_length,
                 height=height, 
                 truncation=truncation );
    }
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

truncation=15;
axle_support_radius = 6;
rotate([180,0,0])
union()
{
    translate([-10,0,0]) difference()
    {
        cylinder( h=truncation, r=axle_support_radius, $fn=20 );
        z_neg_axle( length=13*2 ); // z_neg_axle is centred on x=y=0
    }
    diamond_shell( truncation=truncation );
    translate([10,0,0]) difference()
    {
        cylinder( h=truncation, r=axle_support_radius, $fn=20 );
        #z_neg_axle( length=13*2 ); // z_neg_axle is centred on x=y=0
    }
}
