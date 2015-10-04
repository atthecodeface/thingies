std_data = [6.2, 0.9, 6.0];
function ball_x(bp,d) = (5+d[0]*bp[0]+d[0]/2*bp[1]+d[0]/2*bp[2]);
function ball_y(bp,d) = (5+d[0]*0.866*bp[1]+d[0]*0.866/3*bp[2]);
function ball_z(bp,d) = (d[2]/2+d[1]*bp[2]);

module bb_ball(bd=6.0)
{
    sphere(r=bd/2,$fn=20);
}

bd=6.0;
spacing = 1.05;
num_balls = 12;
slack_angle = 10.0;
theta = (360 - slack_angle) / num_balls;
ball_angle = 360/num_balls;
race_radius = bd/2 / sin(theta/2);
outer_radius = 24.0;
ring_gap = 0.2;
axle_radius = 8.0*5/2;
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

module race_concavity()
{
 rotate_extrude(convexity = 10)
 translate([race_radius, 0, 0])
 circle(bd/2*spacing);
}
module annulus(r0,r1,h)
{
    difference() {
        cylinder(r=r1,h=h);
        cylinder(r=r0,h=h);
    }
}

draft = (1==0);
show_balls = (1==0);
show_inner = (1==1);
show_outer = (1==1);
explode = (1==1);
$fs = draft ? 2: 0.5; // minimum length of edge/etc in polygon from circle/sphere/cylinder
$fa = draft ? 20 : 3;   // minimum angle of edge/etc in polygon from circle/sphere/cylinder

module ball_race(show_inner, show_outer, show_balls)
{
    difference() {
        union() {
            if (show_inner) {
                annulus(r0=0.1, r1=race_radius-ring_gap, h=bd);
            }
            if (show_outer) {
                annulus(r0=race_radius+ring_gap, r1=outer_radius, h=bd );
            }
        }
        race_concavity();
translate([0,0,3.0]) z_neg_axle(length=10.0);
translate([axle_radius,0,3.0]) z_neg_axle(length=10.0);
translate([-axle_radius,0,3.0]) z_neg_axle(length=10.0);
translate([0,axle_radius,3.0]) z_neg_axle(length=10.0);
translate([0,-axle_radius,3.0]) z_neg_axle(length=10.0);
    }
    if (show_balls) {
        for (i=[0:num_balls-1]) {
            rotate([0,0,ball_angle*i]) translate([race_radius,0,0]) bb_ball();
        }
    }
}

rotate([180,0,0])
if (explode) {
    translate([-outer_radius-race_radius-2,0,0]) ball_race(show_inner,0,show_balls);
    translate([0,0,0])               ball_race(0,show_outer,show_balls);
} else {
    ball_race(show_inner,show_outer,show_balls);
}
