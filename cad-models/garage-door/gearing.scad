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
    translate([32,24,-10+tol_z]) rotate([0,0,-2.5]) newGear(38,10-tol_z,5);

    hull() {
    difference() {
        translate([32,24,-10+tol_z]) rotate([0,0,-2.5]) newGear(38,10-tol_z,5);
        translate([0,5,-11]) cube([80,60,12]);
        //translate([0,8,-11]) cube([80,61,12]);
    }
//        intersection() {
//            translate([32,24,-10+tol_z]) rotate([0,0,-2.5]) newGear(28,10-tol_z,7);
//            translate([42,4,-10+tol_z]) cylinder(10-tol_z, r=18);
//        }
        translate([42,-55,-10+tol_z]) cylinder(10-tol_z, r=10);
    }
}

module doubeGear() {
    rotate([0,0,35]) difference() {
        intersection() {
            newGear(77,10,0);
            union() {
                translate([-11,-11,-1]) cube(70);
                translate([-11,-11,-1]) rotate([0,0,-45]) cube(70);
            }
        }
        for(n = [1 : 4])
                rotate([0, 0, -91 + n * 44])
        {
            translate([33,0,0])
            cylinder(14, r=10);
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
                translate([25, 0, -tol_z]) cylinder(10+tol_z, r=68); 
             }      
            // bottom arm
            difference() {
                // arm
                union() {
                    hull() {
                        translate([25+x_shift, 0, 10]) cylinder(5, r=46/2);
                        translate([-48, 0, 10]) cylinder(5, r=46/2);
                    }
                    hull() {
                        translate([47.5, 24, 10]) cylinder(5, r=7);
                        translate([-48, 0, 10]) cylinder(5, r=46/2);
                    }
                    hull() {
                        translate([47.5, 24, 10]) cylinder(5, r=7);
                        translate([25+x_shift, 0, 10]) cylinder(5, r=46/2);
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
                    translate([15.5, 0, 12.4]) cylinder(20,r=4.3);
                }
            }
            // top arm 
            hull() {
                translate([-48, 0, -4.8]) linear_extrude(5) minkowski() {
                        circle(7.48);
                        rotate([0,0,45]) square([31.04, 31.04], true);
                }
                translate([-12, -18, -14.8]) cube([5,36,5]);
            }
            difference() {
                union() {
                    hull() {
                        translate([47.5, 24, -14.8]) cylinder(5, r=7);
                        translate([-12, 2, -14.8]) cube([5,16,5]);;
                    }
                    hull() {
                        translate([47.5, 24, -14.8]) cylinder(5, r=7);
                        translate([20, 0, -14.8]) cylinder(5, r=10);
                    }
                    translate([47.5, 24, 0]) cylinder(10, r=7); 
                }
                translate([15.5, 0, -40]) cylinder(100, r=2.5+tol_x);
                hull() {
                    translate([38, 18, -15]) cylinder(7, r=3);
                    translate([20, 0, -15]) cylinder(7, r=3);
                }
            }
            difference() {
                hull() {
                    translate([-12, -18, -14.8]) cube([5,36,5]);
                    translate([20, 0, -14.8]) cylinder(5, r=10);
                }
                translate([15.5, 0, -15.8]) cylinder(7, r=2.5);
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
        translate([42,10,10.5]) cylinder(3.5,4,1,true);
        translate([42,10,10]) cylinder(20,r=1);
        
        // hole for 3rd gear
        translate([47.5, 24, -15]) cylinder(40, r=2.5); 
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
rotate([0,0,90]) doubeGear(); 
//translate([-63.5,0,0]) rotate([0,0,$t*90+3.8]) small_gear(12);
color("LightCyan") liftDoorArm();
// mount
//color("grey",1.0) translate([-15.5,0,0]) motorMount();
//wallMount();

//translate([-48-15.5, 0, -5-25]) rotate([0,0,45]) mirror([0, 0, 1]) nema();
