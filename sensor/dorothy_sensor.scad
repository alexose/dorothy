/*

Dorothy Sensor
==============

(see also: Dorothy Hub)

The Dorothy Sensor Platform consists of three parts:

  1. Brain:  Where the sensors and CubeCell board are mounted.  Depending on the needs of the sensor,
    this usually is comprised of a "seal" (the threaded piece with the proper hole cut out) and a
    "sled" (the plate that the CubeCell board is attached to).
  2. Battery Pack:  Three 18650 cells placed in a Cylindrical Battery Holder (see: https://www.thingiverse.com/thing:6080710)
  3. Outer Shell: The threaded cylinder that covers the whole assembly and protects it from the elements

The Brain can come in many different shapes, depending on the type of sensor(s) you want to use.
This file includes variations for:

* US-100 ultrasonic sensor
* DHT22 temperature and humidity sensor
* Catnip Eletronics' soil moisture sensor (https://www.tindie.com/products/miceuz/i2c-soil-moisture-sensor/)

With more on the way!

*/


use <threads.scad>

// Parts
render_outer_shell = 1;
render_brain = 1;
render_standoffs = 1;
brain_type = "soil_moisture";  // distance, temperature_humidity, or soil_moisture


// Adjustable dimensions
thickness = 1;       // Thickness of wall.  Recommend 1mm to make room for threads
width = 27;          // Outer radius.  With 1mm thick walls, the inside radius becomes 25mm
dome_height = 8;     // Controls "Roundness" of shell
overhang = 4;        // Extra shell height to allow for a bit of overhang
tolerance = 0.3;     // Can be adjusted if threads don't fit together
fit_tolerance = 0.6; // Can be adjusted if inner shell doesn't fit
seal_padding = 0.5;  // Extra padding to allow annular seal to fit


// Non-adjustable dimensions
battery_pack_height = 75;
pitch = 2.8;
tooth_angle = 50;
seal_height = 6;
board_width = 28;
board_depth = 5;
thread_offset = 1.2;
sled_offset = 10;

// Note that while the board_height is 64mm, it goes through the 6mm "seal" and sticks about 3mm 
// into the battery pack.  So the total height of the brain ends up being 55mm.
board_height = 64;
    
// Height of inner "brain" compartment.  This needs to be a standard height so that shells are all
// compatible with one another.  
brain_height = 55; 


// The outer shell height should add up to the total height of all components smooshed together
height = battery_pack_height 
    + brain_height 
    + seal_height
    + overhang;

offset = width * 2.25;
if (render_brain) translate([0, 0, 0]) brain();
if (render_outer_shell) translate([offset, 0, 0]) outer_shell();
if (render_standoffs) translate([20, 0, 0]) cubecell_standoffs();

module brain() {
    if (brain_type == "distance") brain_distance();
    if (brain_type == "temperature_humidity") brain_temperature_humidity();
    if (brain_type == "soil_moisture") brain_soil_moisture();
}

module brain_distance() {
    // Distance module.  This is based on the US-100 ultrasonic sensor, available for about $2 on
    // ebay.  I prefer this sensor over other ultrasonic sensors because it has dedicated on-board 
    // timers, and outputs directly to serial.  
    //
    // The US-100 claims to work down to 2.4V, although it might be a good idea to add a 5V level converter.
    
    h = seal_height;
    w = width;
    
    sensor_width = 44 + fit_tolerance;
    sensor_height = 20 + fit_tolerance;
    sensor_depth = 3;

    sw = sensor_width;
    sh = sensor_height;
    sd = sensor_depth;
    
    bw = board_width;
    bh = board_height;

    difference() {
        union() {
            difference() {
                seal();
                translate([0, 0, h - (sd / 2) ]) {
                    translate([0, 0, 1]) {
                        cube([sw, sh, 3], center=true);
                        oval_cutout();
                    }
                }
                sensor_holes(h);
            }
        }
        
        union(){
            r = 1; // Mounting hole radius
            o = 4; // Mounting hole offset
            d = 5; // Mounting hole depth 
            translate([0, 0, h - d]) standoffs(r, d, sw - o, sh - o);              
        }
    }
    
    translate([sled_offset, 0]) sled_mount(sw, sh);
    
    module oval_cutout(){
        hull() translate([0, 0, -3.5]) standoffs(2, 2, 10, sensor_height-3);
    }
    
    module sensor_holes(h){
        hole_radius = 16/2 * 1.01;
        hole_distance = 23.75;
        f = 1.05;
        $fn = 150;
        
        translate([hole_distance/2, 0, 0]) cylinder(h*2, hole_radius*f, hole_radius*f);
        translate([-hole_distance/2, 0, 0]) cylinder(h*2, hole_radius*f, hole_radius*f);
    }
    
    translate([-45, 0, board_depth/2]) rotate([90, 180, 0]) sled(board_height - seal_height + 1);    
}
module brain_temperature_humidity() {
    // Temperature and humidity module.  This is based on the ubiquitous DHT22, which costs about $1.60.
    
    h = seal_height;
    w = width;
    
    sensor_width = 40 * 1.05; // fudged a bit
    sensor_height = 16 * 1.07;
    sensor_depth = 4;
    
    sw = sensor_width;
    sh = sensor_height;
    sd = sensor_depth;

    bw = board_width;
    bh = board_height;
    
    difference() {
        union() {
            
            difference() {
                seal();
                translate([0, 0, h - (sd / 2) ]) {
                    translate([0, 0, 1]) {
                        cube([sw, sh, 4.3], center=true);
                    }
                }
                translate([6, 0]) cube([20.3, 15.8, 20], center=true); 
            }
        }
    }
    
    translate([sled_offset, 0]) sled_mount(sw, sh);
    translate([-45, 0, board_depth/2]) rotate([90, 180, 0]) sled(board_height - seal_height + 1);
}

module brain_soil_moisture() {
    // Soil moisture module.  This hygrometer is based on the wonderful soil moisture sensor from
    // catnip electronics, and costs about $10:
    // https://www.tindie.com/products/miceuz/i2c-soil-moisture-sensor/
    //
    // The soil moisture sensor is mounted vertically, so the "spike" end sticks out of the bottom.
    h = seal_height;
    w = width;
    
    bw = board_width;
    bd = board_depth;
    bh = board_height;
    
    cutout_tolerance = 0.4;
    cutout = 8.5;
    t = 2.5;
    
    radius = 1;
    ww = 6;
    wd = 6;
    f = fit_tolerance;
    
    rotate([90, 0]) translate([-10, bd/2]) difference() {
        sled();
        union() {
        
            // Sensor cutout, with a little extra tolerance
            translate([0, 2.5, -50]) rotate([90, 0, 0]) scale([1, 1, 0.7])  minkowski() {
                import("soil_moisture_sensor.stl");
                cylinder(1, cutout_tolerance, cutout_tolerance);
            }
            
            // Extra cutout to give space for chips
            translate([0, 1, -8.5]) roundedcube([12, t+2.5, 30], true); 
        }
    }

    translate([-w*2, 0]) difference() {
        seal();
        offset = 6; // Gives a little extra breathing room for CubeCell
        voffset = 2; // Fudged this... room for improvement here
        translate([0, offset, bh/2 - voffset]) sled();
    }
}

module seal(){
    t = thickness;
    w = width - t*2;
    ScrewThread(w*2 + thread_offset, seal_height, pitch=pitch, tooth_angle=tooth_angle, tolerance=tolerance);
}

module sled(bh=board_height) {
    bw = board_width;
    bd = board_depth;
    
    h = seal_height;
    w = width;
    
    radius = 1;
    ww = 6;
    wd = 6;
    f = fit_tolerance;
    
    cx = 18.92;
    cy = 36.71;
    
    difference() {
        union() {
            roundedcube([bw, bd, bh], radius=radius, true);
            
            // Add "dogbones" which help lock the sled in place
            translate([bw/2, 0, -bh/2 + wd/2]) roundedcube([wd, bd, ww], radius=radius, true);
            translate([-bw/2, 0,  -bh/2 + wd/2]) roundedcube([wd, bd, ww], radius=radius, true);
            
            // Clips for CubeCell
            // translate([0, -4, 3]) rotate([90, 0, 0]) clips(cx - 7, cy);
        }
                    
        // Slice 2mm off bottom of roundedcube so that everything lines up nicely
        translate([0, 0, -bh+2]) cube([bw + wd * 2, bd, bh], true);
        
        // Mounting holes for CubeCell
        translate([0, 0, 3]) rotate([90, 0, 0]) standoffs(1, 10, cx, cy);
    }
}

module cubecell_standoffs() {
    h = 8;
    difference() {
        standoffs(1.2+thickness, h, 5, 5);
        standoffs(1.2, h, 5, 5);
    }
}

module sled_mount(sw, sh) {
    mh = 6.5;
    h = seal_height;
    bh = board_height;
    ho = h + mh/2 - 1;
    
    translate([0, 0, ho]) difference() {
        rotate([0, 0, 90]) roundedcube([41, 9, mh], radius=1.4, center=true);
        translate([0, 0, bh + 1 - ho]) rotate([0, 0, 90]) scale([1,1,2]) sled();
        cube([sw, sh, 100], center=true);
    }
}
 
module outer_shell(){
    h = height;
    t = thickness;
    w = width - t*2;
    
    total_height = height + dome_height;
    threaded_section_height = seal_height + overhang;
    
    translate([0, 0, total_height]) rotate([0, 180]) ScrewHole(w*2 + thread_offset, threaded_section_height, pitch=pitch, tooth_angle=tooth_angle, tolerance=tolerance) { 
        difference(){
            domed_cylinder(h,w + t*2);
            domed_cylinder(h-t,w);
        }
    }
}

module clips(height, width) {
    x = height / 2;
    y = width / 2;
    
    union() { 
        translate([x, y]) clip();
        translate([x, -y]) rotate([0, 0, 180])  clip();
        translate([-x, y]) clip();
        translate([-x, -y]) rotate([0, 0, 180])  clip();
    }
}

module clip() {
    translate([-2, 0]) rotate([90, 0, 90]) linear_extrude(4) polygon([[2,9],[1,10],[-2,9],[-2,8],[-1,8],[0,7],[-1,6],[-1,-2],[1,-2]]);
}

module standoffs(r, depth, height, width) {
    $fn = 20;
    d = depth;
    x = height / 2;
    y = width / 2;
    
    union() { 
        translate([x, y]) cylinder(d, r, r);
        translate([x, -y]) cylinder(d, r, r);
        translate([-x, y]) cylinder(d, r, r);
        translate([-x, -y]) cylinder(d, r, r);
    }
}

module oval_cutout(){
    hull() translate([0, 0, -3.5]) standoffs(2, 2, 10, sensor_height-3);
}

module domed_cylinder(h,w){
    $fs=3; // Don't set this to less than 1 unless you enjoy freezing OpenSCAD
    $fa=0.1;
    $fn=150; // Again, careful here
    c = dome_height * 2;
    // translate([0, 0, h]) scale([1,1,0.5]) sphere(w);

    difference(){ 
        union(){ 
            translate([0, 0, h]) scale([1, 1, 0.5]) sphere(w); // Flattened sphere
            cylinder(h, w, w);
        }
        translate([0, 0, h+c]) cube([w*2, w*2, c], center=true);  // Cutoff
    }
 }
 
 // More information: https://danielupshaw.com/openscad-rounded-corners/
module roundedcube(size = [1, 1, 1], center = false, radius = 0.5, apply_to = "all") {
    $fs = 0.15;
	// If single value, convert to [x, y, z] vector
	size = (size[0] == undef) ? [size, size, size] : size;

	translate_min = radius;
	translate_xmax = size[0] - radius;
	translate_ymax = size[1] - radius;
	translate_zmax = size[2] - radius;

	diameter = radius * 2;

	obj_translate = (center == false) ?
		[0, 0, 0] : [
			-(size[0] / 2),
			-(size[1] / 2),
			-(size[2] / 2)
		];

	translate(v = obj_translate) {
		hull() {
			for (translate_x = [translate_min, translate_xmax]) {
				x_at = (translate_x == translate_min) ? "min" : "max";
				for (translate_y = [translate_min, translate_ymax]) {
					y_at = (translate_y == translate_min) ? "min" : "max";
					for (translate_z = [translate_min, translate_zmax]) {
						z_at = (translate_z == translate_min) ? "min" : "max";

						translate(v = [translate_x, translate_y, translate_z])
						if (
							(apply_to == "all") ||
							(apply_to == "xmin" && x_at == "min") || (apply_to == "xmax" && x_at == "max") ||
							(apply_to == "ymin" && y_at == "min") || (apply_to == "ymax" && y_at == "max") ||
							(apply_to == "zmin" && z_at == "min") || (apply_to == "zmax" && z_at == "max")
						) {
							sphere(r = radius);
						} else {
							rotate = 
								(apply_to == "xmin" || apply_to == "xmax" || apply_to == "x") ? [0, 90, 0] : (
								(apply_to == "ymin" || apply_to == "ymax" || apply_to == "y") ? [90, 90, 0] :
								[0, 0, 0]
							);
							rotate(a = rotate)
							cylinder(h = diameter, r = radius, center = true);
						}
					}
				}
			}
		}
	}
}
