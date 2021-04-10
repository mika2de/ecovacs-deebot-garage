difference() {
    cube([42,11,7]);
    translate([1,0,-0.1]) cube([40,10,1.2]);
    translate([8,5,0]) cylinder(h=20,r=1.5,$fn=20);
    translate([34,5,0]) cylinder(h=20,r=1.5,$fn=20);
}