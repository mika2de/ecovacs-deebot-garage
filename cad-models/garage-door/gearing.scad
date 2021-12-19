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
        translate([32,24,-10+tol_z]) rotate([0,0,17]) newGear(38,10-tol_z,11);
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
    difference() {
        newGear(77,10,3);
        color("black") for(n = [1 : 3])
                rotate([0, 0, 60 + n * 120])
        {
            translate([39,0,0])
            cylinder(50, r=9);
        }
    }
    
    translate([0,0,-10+tol_z]) color("LightYellow") newGear(18,10,7);
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

module motorMount() {
    x_shift=2;
    difference() {
        union() {
            difference() {
                translate([-48, 0, -5])
                    union() {
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
             }      
            // bottom arm
            difference() {
                // arm
                union() {
                    hull() {
                        translate([25+x_shift, 0, 10]) cylinder(5, r=46/2);
                        translate([-48, 0, 10]) cylinder(5, r=46/2);
                        translate([40, 55,  10]) cube([20,11,5]);
                    }
                }
                // holes
                union() {
                    hull() {
                        translate([-20, 0, 9]) cylinder(12, r=10);
                        translate([-2, 0, 9]) cylinder(12, r=10);
                    }
                    hull() {
                        translate([29, 4, 9]) cylinder(12, r=6);
                        translate([29, -4, 9]) cylinder(12, r=6);
                    }
                    translate([15.5, 12, 9]) cylinder(12, r=4);
                    translate([15.5, -12, 9]) cylinder(12, r=4);
                    
                    // screw hole for big gear
                    translate([15.5, 0, -40]) cylinder(100, r=2.5+tol_x);
                    translate([15.5, 0, 12.4]) cylinder(20,r=6);
                }
            }
            // top arm 
            hull() {
                translate([-48, 0, -5.4]) linear_extrude(5) minkowski() {
                        circle(7.48);
                        rotate([0,0,45]) square([31.04, 31.04], true);
                }
                translate([-12, -18, -14.8]) cube([5,36,5]);
            }
            difference() {
                union() {
                    hull() {
                        translate([47.5, 24, -16.8]) cylinder(7, r=7);
                        translate([-12, 2, -14.8]) cube([5,16,5]);
                        translate([40, 55, -16.8]) cube([20,11,5]);
                    }
                    hull() {
                        translate([47.5, 24, -16.8]) cylinder(7, r=7);
                        translate([20, 0, -16.8]) cylinder(7, r=10);
                    }
                }
                // middle gear screw hole
                translate([15.5, 0, -40]) cylinder(100, r=2.5+tol_x);
            }
            
            translate([40, 55, -16.8]) cube([20,11,30.8]);
            
            difference() {
                hull() {
                    translate([-12, -18, -14.8]) cube([5,36,5]);
                    translate([20, 0, -16.8]) cylinder(7, r=10);
                }
                translate([15.5, 0, -40]) cylinder(100, r=2.5);
            }
        }
        
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
        translate([42,0,10.5]) cylinder(3.5,4,1,true);
        translate([42,0,10]) cylinder(20,r=1);
        
        // hole for 3rd gear
        translate([47.5, 24, -17]) cylinder(40, r=2.5); 
        
        // hole for fixing arm that suffers from high torque
        translate([50, 60.5, -16.8]) cylinder(45,4,4,true);
        translate([50, 60.5, -16.8]) cylinder(60,r=1,true);
        translate([50, 60.5, 5.2]) cylinder(3.5,4,1,false); 
        
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

module giantMount() {
    translate([-15.5,0,10]) rotate([180,0,0]) difference() {
        difference() {
                translate([-48, 0, -5])
                    union() {
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
             }
            
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
                
}


// gearing
// rotate([0,0,-$t*90]) 
rotate([0,0,90]) doubeGear(); 
translate([-63.5,0,0]) rotate([0,0,$t*90+3.8]) small_gear(12);
//translate([0,0,-40]) 
color("LightCyan") liftDoorArm();
// color("grey",0.2) translate([-15.5,0,0]) motorMount();
// wallMount();

translate([-48-15.5, 0, -5-25]) rotate([0,0,45]) mirror([0, 0, 1]) nema();

giantMount();
