use <MCAD/involute_gears.scad>
include <MCAD/stepper.scad>

tol_x = .2;
tol_z = .4;
gear_thickness=10;

module bigGear(teeth, thickness) {
    difference() {
        gear(
            number_of_teeth=teeth,
            circular_pitch=256,
            twist=0,
            rim_width=2,
            rim_thickness=gear_thickness-tol_z,
            hub_diameter=5,
            hub_thickness=gear_thickness-tol_z,
            gear_thickness=gear_thickness-tol_z,
            circles=3,
            bore_diameter=5
        );
        hull() {
            translate([-13.5,-23.5,0]) cylinder(12, r=20);
            translate([-60,-19.5,0]) cylinder(12, r=25);
        }
        
        hull() {
            translate([-13.5,-23.5,0]) cylinder(12, r=20);
            translate([-13.5,-60,0]) cylinder(12, r=21);
        }
    }
}

module liftDoorArm() {
    end_x=-70;
    end_y=40;
    difference() {
        // outer
        union() {
            hull() {
                translate([end_x,end_y,0]) cylinder(10-tol_z, r=10);
                translate([-11,51,0]) cylinder(10-tol_z, r=5);
            }
            hull() {
                translate([end_x,end_y,0]) cylinder(10-tol_z, r=10);
                translate([-40,24,0]) cylinder(10-tol_z, r=7);
            }
        }
        // inner
        union() {
            hull() {
                translate([end_x+2,end_y,-1]) cylinder(12, r=2);
                translate([-10,41,-1]) cylinder(12, r=4);
            }
            hull() {
                translate([end_x+2,end_y,-1]) cylinder(12, r=2);
                translate([-40,33,-1]) cylinder(12, r=5);
            }
        }
    }
}

module gearWithArm() {
    rotate([0,0,-108]) bigGear(77);
    rotate([0,0,-90]) liftDoorArm();
}

module small_gear(teeth) {
    color([0,0,1]) translate([-2.5,1.9,0]) cube([5,2,15-tol_z]);
    gear(
        number_of_teeth=teeth,
        circular_pitch=256,
        twist=0,
        rim_width=2,
        rim_thickness=gear_thickness,
        hub_diameter=10,
        hub_thickness=15-tol_z,
        bore_diameter=5+4*tol_x,
        gear_thickness=gear_thickness-1,
        circles=5
    );
}

module nema() {
    motor(Nema17, NemaShort);
}

module nema17_hole(depth=10) {
    linear_extrude(depth) minkowski() {
        circle(6);
        square([31.04, 31.04], true);
    }
    translate([0, 0, -depth])
    cylinder(depth+1, r=3+tol_x);
    for (i = [0:3]) {
        rotate([0, 0, i*90])
        translate([31.04/2, 31.04/2, -depth])
        cylinder(depth+1, r=1.5+tol_x);
    }
}

module motorMount() {
    x_shift=2;
    color("grey",1.0)
    difference() {
        union() {
            translate([0, 0, -5]) hull() {
                translate([x_shift, 0, 0]) cylinder(5-tol_z, r=46/2);
                translate([-48, 0, 0]) cylinder(5-tol_z, r=46/2);
            }
            translate([0, 0, -15]) hull() {
                translate([10+x_shift, 0, 25]) cylinder(5, r=46/2);
                translate([-48, 0, 25]) cylinder(5, r=46/2);
            }
            translate([-48, 0, -5])
            hull() {
                linear_extrude(20) minkowski() {
                    circle(7.48);
                    rotate([0,0,45]) square([31.04, 31.04], true);
                }
                translate([0, 33, 18]) cylinder(2, r=5);
                translate([0, -33, 18]) cylinder(2, r=5);
                translate([-33, 0, 18]) cylinder(2, r=5);
            }
        }
        
        // big gear cut
        translate([25, 0, -tol_z]) cylinder(10+tol_z, r=68);
        
        // top hole for small gear 
        translate([-48, 0, -tol_z]) cylinder(20, r=12);
        
        // motor screw holes
        translate([-48, 0, -5]) rotate([0,0,45]) mirror([0, 0, 1]) nema17_hole(20);
        
        // motor knop hole        
        translate([-48, 0, -5]) cylinder(3.2, r=12);
        
        // screw hole for big gear
        translate([15.5, 0, -40]) cylinder(100, r=2.5+tol_x);
        
        hull() {
            translate([-20, 0, -40]) cylinder(100, r=10);
            translate([-3, 0, -40]) cylinder(100, r=10);
        }
        
        // countersinks motor
        translate([-48, 22, 9.2]) cylinder(20,r=3.2);
        translate([-48, -22, 9.2]) cylinder(20,r=3.2);
        translate([-70, 0, 9.2]) cylinder(20,r=3.2);
        translate([15.5, 0, 12.8]) cylinder(20,r=4);
        
        // countersinks wall next to stepper motor
        translate([-48, 32, 12]) cylinder(3.5,4,1,true);
        translate([-48, -32, 12]) cylinder(3.5,4,1,true);
        translate([-79, 0, 12]) cylinder(3.5,4,1,true);
        translate([-48, 32, 12]) cylinder(20,r=1);
        translate([-48, -32, 12]) cylinder(20,r=1);
        translate([-79, 0, 12]) cylinder(20,r=1);
        translate([-48, 32, -7.8]) cylinder(20,r=4.2);
        translate([-48, -32, -7.8]) cylinder(20,r=4.2);
        translate([-79, 0, -7.8]) cylinder(20,r=4.2);
        
        // countersink wall next to center of big gear
        translate([27.5, 0,10.5]) cylinder(3.5,4,1,true);
        translate([27.5, 0,10]) cylinder(20,r=1);
    }
            
}

module wallMount() {
    difference() {
        union() {
            hull() {
                translate([0, 0, 15]) cylinder(3, r=5);
                translate([-63.5, 22, 15]) cylinder(3, r=5);
            
            }
            hull() {
                translate([0, 0, 15]) cylinder(3, r=5);
                translate([-63.5, -22, 15]) cylinder(3, r=5);
            }
            hull() {
                translate([-85.5, 0, 15]) cylinder(3, r=5);
                translate([-63.5, 22, 15]) cylinder(3, r=5);
            }
            hull() {
                translate([-85.5, 0, 15]) cylinder(3, r=5);
                translate([-63.5, -22, 15]) cylinder(3, r=5);
            }
            hull() {
                translate([-63.5, 37, 15]) cylinder(3, r=5);
                translate([-63.5, -37, 15]) cylinder(3, r=5);
            }
            hull() {
                translate([-85.5, 0, 15]) cylinder(3, r=5);
                translate([-100.5, 0, 15]) cylinder(3, r=5);
            }
            hull() {
                translate([-8, 0, 15]) cylinder(3, r=7);
                translate([15, 00, 15]) cylinder(3, r=5);
            
            }
        }
        translate([13, 0, 16]) cylinder(4.1,0.3,4,true);
        translate([-97, 0, 16]) cylinder(4.1,0.3,4,true);
        translate([-63.5, 34, 16]) cylinder(4.1,0.3,4,true);
        translate([-63.5, -34, 16]) cylinder(4.1,0.3,4,true);
        translate([0, 0, -40]) cylinder(100, r=2.5+tol_x);
        translate([-63.5, 0, 8]) rotate([0,0,45]) mirror([0, 0, 1]) nema17_hole(20);
        
    }        
}


// gearing
// rotate([0,0,-$t*90]) 
//gearWithArm(); 
//translate([-63.5,0,0]) rotate([0,0,$t*90+3.8]) small_gear(12);

// mount
translate([-15.5,0,0]) motorMount();
//wallMount();

//translate([-48-15.5, 0, -5-20]) rotate([0,0,45]) mirror([0, 0, 1]) nema();
