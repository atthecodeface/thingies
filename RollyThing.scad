std_data = [6.2, 0.9, 6.0];
function ball_x(bp,d) = (5+d[0]*bp[0]+d[0]/2*bp[1]+d[0]/2*bp[2]);
function ball_y(bp,d) = (5+d[0]*0.866*bp[1]+d[0]*0.866/3*bp[2]);
function ball_z(bp,d) = (d[2]/2+d[1]*bp[2]);

module bb_ball(bd=6.0)
{
    sphere(r=bd/2,$fn=20);
}

module bb_ball_hole(h=1,d=10.0/8/6, ball_radius=3.0)
{
    translate( [0,0,-h/2] ) cylinder(r=ball_radius*(1-d), h=h*2, $fn=20);
}

module bb_ball_plate(w,d,h,xh,yh)
{
    xs = 2.0+6.0/2;
    ys = 2.0+6.0/2;
    xd = 8;
    yd = 8;
    difference()
    {
        cube([w,d,h]);
        for (i=[0:xh-1])
        {
            for (j=[0:yh-1])
            {
                translate([xs+xd*i,ys+yd*j,0]) bb_ball_hole( h=h );
            }
        }
    }
}

//translate([0,0,0.1]) bb_ball_plate( w=40, d=40, h=0.9, xh=4, yh=4 );
//translate([0,0,5.0]) bb_ball_plate( w=40, d=40, h=0.9, xh=4, yh=4 );


module set_of_balls(ball_set=[ [1,0,0],
                                       [2,0,0],
                                       [0,1,0],
                                       [1,1,0],
                                       [2,1,0],
                                       [0,2,0],
                                       [1,2,0] ],
                    data = std_data)
{
    for (ball=ball_set)
    {
        translate([ball_x(ball,data),ball_y(ball,data),ball_z(ball,data)]) bb_ball(bd=data[2]);
    }
}


/*
difference()
{
    translate([0,0,0.2]) cube( [35,30,3+6.2*0.866*0.9*0.5-0.2] );

    set_of_balls();
    translate( [6.2*0.5,6.2*0.866*0.33,6.2*0.866*0.9] ) set_of_balls();
    translate( [5,2,3] ) cube([5+16.6,5+13.6,6.2*0.866*0.9]);
}
polyhedron( points=[ [5,5,3],
                     [5+6.2*3,5,3],
                     [5+3.1*3,5+6.2*0.866*3,3],
                     [6.2*0.5+5,5,6.2*0.866*0.9+3], [6.2*0.5+5+6.2*3,5,6.2*0.866*0.9+3], [6.2*0.5+5+3.1*3,5+6.2*0.866*3,6.2*0.866*0.9+3],
                ],
            triangles=[[0,2,1], [3,4,5],
                       [0,3,1], [1,3,4], 
                       [1,4,2], [2,5,4],
                       [0,2,5], [0,5,3]
                ] );

*/
//set_of_balls( ball_set=[ [0,0,0], [2,0,0], [0,2,0], [2,2,0] ] );
// We have an equilateral triangle at the base which has side 'sep', where sep=2r+delta
// The next level ball sits at the centre of this triangle
// Looking at the equilateraly triangle  from above, it breaks down in to 3 identical isosceles triangles with a side of length 'sep' and two of length 'br'
// Note that a right-angled triangle of hypoteneuse of br, opposite of sep/2 and angle of 60 degrees exists. Since sin60 is 0.866, sep/2/br = 0.866, or br = sep/sqrt(3)
// There is a further triangle with base br, height 'rowh', and hypotenuse of 2*ball_radius. Hence rowh = sqrt(4ball_radius^2 - br^2)
// or rowh = sqrt(4ball_radius^2-sep^2/3)
ball_radius = 3.0;
sep = ball_radius*2+3.0;
rowh = sqrt(4*ball_radius*ball_radius-sep*sep/3);
ball_data = [sep,rowh,ball_radius*2];
ball_set = [ [0,0,0], [1,0,0], [2,0,0], [3,0,0], [0,1,0], [1,1,0], [2,1,0], [3,1,0],  [0,2,0], [1,2,0], [2,2,0], [3,2,0], [0,3,0], [1,3,0], [2,3,0], [3,3,0],
             [0,0,1], [1,0,1], [2,0,1], [3,0,1], [0,1,1], [1,1,1], [2,1,1], [3,1,1],  [0,2,1], [1,2,1], [2,2,1], [3,2,1], [0,3,1], [1,3,1], [2,3,1], [3,3,1],
    ];

base_height=1.2;
base_length=45;
base_width=20;
body_height=20;
extension = 0.3;
h=6.5;

base_height=0.6;

ball_surround = [ [-0.7,-0.7,0],
                  [ 4.2,-0.7,0],
                  [ 4.2, 4.1,0],
                  [-0.7, 4.1,0], ];
ball_cutout = [ [ -0.2, -0.2, 0],
                [ 3.5, -0.2,0],
                [ 3.5, 3.6,0],
                [ -0.2, 3.6,0], ];
balls = (1==1);
base = (1==1);
top = (1==0);

module ball_block( h )
{
    linear_extrude( height=h )
    {
        polygon( points=[ [ball_x(ball_surround[0],ball_data),ball_y(ball_surround[0],ball_data)],
                          [ball_x(ball_surround[1],ball_data),ball_y(ball_surround[1],ball_data)],
                          [ball_x(ball_surround[2],ball_data),ball_y(ball_surround[2],ball_data)],
                          [ball_x(ball_surround[3],ball_data),ball_y(ball_surround[3],ball_data)],
                     ] );
    }
}
module ball_block_cutout( h )
{
    linear_extrude( height=h )
    {
        polygon( points=[ [ball_x(ball_cutout[0],ball_data),ball_y(ball_cutout[0],ball_data)],
                          [ball_x(ball_cutout[1],ball_data),ball_y(ball_cutout[1],ball_data)],
                          [ball_x(ball_cutout[2],ball_data),ball_y(ball_cutout[2],ball_data)],
                          [ball_x(ball_cutout[3],ball_data),ball_y(ball_cutout[3],ball_data)],
                     ] );
    }
}

if (balls)
{
    set_of_balls( ball_set=ball_set, data = ball_data);
}

if (base)
{
    difference()
    {
        translate( [0,0,extension]) ball_block( h=h );
        translate( [0,0,0]) ball_block_cutout( h=h*2 );
        for (ball=ball_set)
        {
            translate( [ball_x( ball, ball_data ),
                        ball_y( ball, ball_data ),
                        -5] ) cylinder(r=ball_radius+0.3,h=30, $fn=20);
        }
    }
}

difference()
{
    union()
    {
        if (base)
        {
            translate( [0,0,extension]) ball_block( h=base_height );//cube([base_length,base_width,base_height]);
        }
        if (top)
        {
            translate( [0,0,ball_radius*2+rowh-0.3-base_height]) ball_block( h=base_height );//cube([base_length,base_width,base_height]);
        }
    }
    for (ball=ball_set)
    {
        translate( [ball_x( ball, ball_data ),
                    ball_y( ball, ball_data ),
                    ball_z( ball, ball_data )-ball_radius] ) bb_ball_hole( ball_radius=ball_radius, h=base_height, d=0.05 );
        translate( [ball_x( ball, ball_data ),
                    ball_y( ball, ball_data ),
                    ball_z( ball, ball_data )+ball_radius-base_height] ) bb_ball_hole( ball_radius=ball_radius, h=base_height, d=0.05 );
    }
}
