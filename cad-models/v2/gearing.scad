// DRAFT
// Quick'n dirty cad file used to export the unfinished giantMount.stl which I used as input for FreeCad to finally finish it.

use <MCAD/involute_gears.scad>
include <MCAD/stepper.scad>

tol_x = .2;
tol_z = .4;
gear_thickness=10;

module newGear(teeth, gear_thickness, circle) {
    gear(
        number_of_teeth=teeth,
        circular_pitch=256,
        twist=0,
        rim_width=2,
        rim_thickness=gear_thickness-tol_z,
        hub_diameter=5,
        hub_thickness=gear_thickness-tol_z,
        gear_thickness=gear_thickness-tol_z,
        circles=circle,
        bore_diameter=5
    ); 
}


module liftDoorArm() {
    difference() {
        translate([32,24,-10+tol_z]) rotate([0,0,17]) newGear(41,10-tol_z,11);
        translate([32,24,-3+tol_z]) cylinder(10-tol_z, r=10);
    }
    hull() {
        intersection() {
            translate([32,24,-10+tol_z]) rotate([0,0,-2.5]) newGear(38,10-tol_z,5);
            translate([55,45,-10+tol_z]) cylinder(10-tol_z, r=13);
        }
        translate([85,85,-10+tol_z]) cylinder(10-2*tol_z, r=10);
    }

}

module doubeGear() {
    color("LightBlue") difference() {
        newGear(77,10,3);
        for(n = [1 : 3])
                rotate([0, 0, 60 + n * 120])
        {
            translate([39,0,0])
            cylinder(50, r=9);
        }
    }
    
    translate([0,0,-10+tol_z]) color("LightYellow") newGear(15,10,7);
    //rotate([0,0,-90]) liftDoorArm();

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

module giantMount() {
    translate([-15.5,0,10]) rotate([180,0,0]) difference() {
        union() {
            difference() {
                translate([-48, 0, -5]) union() {
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
                translate([25, 0, -tol_z]) cylinder(10+2*tol_z, r=68); 
            
            
            // top hole for small gear 
            translate([-48, 0, -tol_z]) cylinder(20, r=12);
        
            // motor screw holes
            translate([-48, 0, -5]) rotate([0,0,45]) mirror([0, 0, 1]) nema17_hole(20);
        
            // motor knop hole        
            translate([-48, 0, -5]) cylinder(3.2, r=12);
        
            // countersinks motor
            translate([-48, 22, 9.2]) cylinder(20,r=3.2);
            translate([-48, -22, 9.2]) cylinder(20,r=3.2);
            translate([-70, 0, 9.2]) cylinder(20,r=3.2);
        }
        
translate([00, -0, -24.4]) union() {
        translate([20, -0, 9]) hull() { 
            translate([50, 40, 10.4]) cylinder(4.6, r=7);    
            translate([0, 0, 10.4]) cylinder(4.6, r=7);  
            translate([27.5, -24, 10.4]) cylinder(4.6, r=7); 

        }
        translate([20, -0, 9]) hull() { 
            translate([-40-15.5, -18, 10.4]) cube([5,36,4.6]);
            translate([0, 0, 10.4]) cylinder(4.6, r=7);  
            translate([27.5, -24, 10.4]) cylinder(4.6, r=7); 
        }
    }
        translate([-50.5,0,10.4]) hull() {
            linear_extrude(5) minkowski() {
                circle(7.48);
                rotate([0,0,45]) square([31.04, 31.04], true);
            }
            translate([35, -18, 10.4]) cube([5,36,5]);
        }
        union() {
        translate([20, -0, 9.4]) hull() { 
            translate([50, 40, 10.4]) cylinder(6, r=7);    
            translate([0, 0, 10.4]) cylinder(6, r=7);  
            translate([27.5, -24, 10.4]) cylinder(6, r=7); 

        }
        translate([20, -0, 9.4]) hull() { 
            translate([-20-15.5, -18, 10.4]) cube([5,36,6]);
            translate([0, 0, 10.4]) cylinder(6, r=7);  
            translate([27.5, -24, 10.4]) cylinder(6, r=7); 
        }
    }
        translate([70, 40, -2]) cylinder(27, r=7); 
    translate([110.5-42, 14, 10.4-10-5.4]) rotate([0,0,72.5]) cube([46,84,4.6]);

    }
    
    translate([15.5,0,-10]) union() {
            //translate([13, 0, 16]) cylinder(4.1,0.3,4,true);
        //translate([-97, 0, 16]) cylinder(4.1,0.3,4,true);
        //translate([-63.5, 34, 16]) cylinder(4.1,0.3,4,true);
        //translate([-63.5, -34, 16]) cylinder(4.1,0.3,4,true);
        translate([0, 0, -40]) cylinder(100, r=2.5+tol_x);
    }
}

}


rotate([0,0,27]) doubeGear(); 
//translate([-63.5,0,0]) rotate([0,0,$t*90+3.8]) small_gear(12);
//translate([0,0,-40]) 
//color("LightCyan") translate([14,59.7,0]) rotate([0,0,-100]) liftDoorArm();

// translate([-48-15.5, 0, -5-25]) rotate([0,0,45]) mirror([0, 0, 1]) nema();
//translate([-48-15.5, 0, 14.5]) rotate([180,0,45]) mirror([0, 0, 1]) nema();
// difference() {giantMount();
//translate([32, 24, -40]) cylinder(100, r=2.5+tol_x);}
