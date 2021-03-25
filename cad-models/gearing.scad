use <MCAD/involute_gears.scad>
include <MCAD/stepper.scad>

tol_x = .2;
tol_z = .4;

module big_gear(teeth, thickness) {
    gear(
        number_of_teeth=teeth,
        circular_pitch=256,
        twist=0,
        rim_width=2,
        rim_thickness=thickness-tol_z,
        hub_diameter=5,
        hub_thickness=thickness-tol_z,
        gear_thickness=thickness-tol_z,
        circles=5
        // bore_diameter=0
    );
}

module small_gear(teeth, thickness) {
    color([0,0,1]) 
    translate([-2.5,1.5,0])
    cube([5,5,15]);
    gear(
        number_of_teeth=teeth,
        circular_pitch=256,
        twist=0,
        rim_width=2,
        rim_thickness=thickness,
        hub_diameter=10,
        hub_thickness=15,
        bore_diameter=5+tol_x/2,
        gear_thickness=thickness-1,
        circles=5
    );
}

module my_motor() {
    motor(Nema17, NemaShort);
}

module nema17_hole(depth=10) {
    linear_extrude(depth) minkowski() {
        circle(6);
        square([31.04, 31.04], true);
    }
    translate([0, 0, -depth])
    cylinder(depth+1, r=2.5+tol_x);
    for (i = [0:3]) {
        rotate([0, 0, i*90])
        translate([31.04/2, 31.04/2, -depth])
        cylinder(depth+1, r=1.5+tol_x);
    }
}


module male() {
    x_shift=23;
    color("grey",1.0)
    difference() {
        union() {
            translate([0, 0, -5]) hull() {
                translate([x_shift, 0, 0]) cylinder(5-tol_z, r=46/2);
                translate([-48, 0, 0]) cylinder(5-tol_z, r=46/2);
            }
            translate([0, 0, -15]) hull() {
                translate([x_shift, 0, 25]) cylinder(5, r=46/2);
                translate([-48, 0, 25]) cylinder(5, r=46/2);
            }
            translate([-48, 0, -20])
            linear_extrude(35) minkowski() {
                circle(7.48);
                square([31.04, 31.04], true);
            }
        }
        translate([25, 0, -tol_z]) cylinder(10, r=60);
        translate([-48, 0, -tol_z]) cylinder(20, r=18);
        translate([-48, 0, -2]) mirror([0, 0, 1]) nema17_hole(20);
        
        // male screw hole
        translate([x_shift, 0, -40]) cylinder(40, r=2.5+tol_x);
    }
}
    difference() {
hull() {
    translate([-7.5,100,0]) cylinder(10-2*tol_z, r=20/2);
    translate([-47,34,0]) cube([79,1,10-2*tol_z]);
}
hull() {
    translate([-7.5,80,-1]) cylinder(12, r=20/2);
    translate([-37,34,-1]) cube([59,1,12]);
}
}

translate([-7.5,0,0]) rotate([0,0,-18]) big_gear(77, 10-tol_z);

translate([-78.5,0,0])
rotate([0,0,0]) small_gear(22, 10-tol_z);

translate([-30.5,0,0]) male();
// my_motor();

