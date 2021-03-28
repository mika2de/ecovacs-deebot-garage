module spring_mount(height){
    translate([5,5,3]) difference() {
    cylinder(h=height, r=5,$fn=50);
    cylinder(h=height+0.2, r=3.6,$fn=50);
    }
    translate([5,15,3]) difference() {
        cylinder(h=height, r=5,$fn=50);
        cylinder(h=height+0.2, r=3.6,$fn=50);
    }
}

    
module base(){
    difference() {
        translate([-15,-10,0]) cube([4,40,10]);
        translate([-10,-5,5]) rotate([0,-90,0]) cylinder(5.1,3,1,false,$fn=50);
        translate([-10,25,5]) rotate([0,-90,0]) cylinder(5.1,3,1,false,$fn=50);
    }

    difference() {
        translate([-15,0,0]) cube([25,20,18]);
        
        hull(){
            translate([0,25,9]) rotate([90,0,0]) cylinder(h=30, r=6,$fn=50);
            translate([20,25,9]) rotate([90,0,0]) cylinder(h=30, r=6,$fn=50);
        }
        // switch hole
        translate([0.8,5.8,14]) cube([8.4,8.4,5]);
    }
    spring_mount(6);
    
    
    difference() {
        cube([120,20,3]);
        translate([0,-5,3]) rotate([0,1,0]) cube([130,30,3]);
    }
    difference() {
        translate([20,8,0]) cube([30,4,15]);
        translate([0,-5,14]) rotate([0,4.8,0]) cube([130,30,10]);
    }
    translate([0,0,-1]) switchMountScrewArms();
}

module switchMount() {
    translate([1,6,14]) difference() {
        cube([8,8,5]);
        translate([0.8,0.8,-0.2]) cube([6.4,6.4,4.2]);
        translate([1.4,1.4,-1]) cylinder(7,0.8,0.8,$fn=100);
        translate([6.6,1.4,-1]) cylinder(7,0.8,0.8,$fn=100);
        translate([1.4,6.6,-1]) cylinder(7,0.8,0.8,$fn=100);
        translate([6.6,6.6,-1]) cylinder(7,0.8,0.8,$fn=100);
    }     
    switchMountScrewArms();   
}

module switchMountScrewArms() {
    difference() {
        union() {
            hull() {
                translate([5,23,18.5]) cylinder(h=1,d=8,center=true,$fn=100);
                translate([1,14,18]) cube([8,8,1]);
            }
            hull() {
                translate([5,-3,18.5]) cylinder(h=1,d=8,center=true,$fn=100);
                translate([1,-2,18]) cube([8,8,1]);
            }
        }
        translate([5,23,18.5]) cylinder(h=2,d=3,center=true,$fn=50);
        translate([5,-3,18.5]) cylinder(h=2,d=3,center=true,$fn=50);
    }
}

module switch() {
    color("azure") translate([2,7,14]) cube([6,6,4]);
    color("black") translate([5,10,13.5]) cylinder(h=1,d=4,center=true,$fn=50);
}

module plate(){
    tol=0.2;
    difference() {
        hull(){
            translate([0,0,10]) cube([20,20,2]);
            translate([-20,-15,-1]) minkowski() {
                translate([20,0,0]) rotate([0,1,0]) cube([100,50,2]);
                translate([20,0,3]) cylinder(h=0.1, r=4);
            }
        }
        translate([0,-1,5]) cube([12,22,5]);
        translate([0,-5,2]) rotate([0,1,0]) cube([130,30,2]);
        translate([20-tol,8-tol,0]) cube([30.4,4.4,15]);
    }
    translate([0,0,6]) spring_mount(1);
    translate([5,10,12.5]) cylinder(h=1,d=4,center=true,$fn=50);
}

base();
color("red") switchMount();
color("LightSlateGray") plate();
switch();