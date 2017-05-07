// Face count setting
$fn=50; // Development (faster)
//$fn=200; // Production (slow)

BASE = 18; // Cherry caps are 18x18mm
SPACING = 19.05;

//normal_keycap();
//angled_keycap();
//thumb_keycap();
PWHRAO_Cluster();

module PWHRAO_Cluster() {
    normal_keycap();
    translate([0, SPACING, 0])
      normal_keycap();

    translate([SPACING, 0, 0])
      angled_keycap();
    translate([SPACING * 3 - 1, 0, 0])
      mirror()
      angled_keycap();
    translate([SPACING, SPACING, 0])
      angled_keycap();
    translate([SPACING * 3 - 1, SPACING, 0])
      mirror()
      angled_keycap();

    translate([SPACING * 0.5, -SPACING, 0])
      thumb_keycap();
    translate([SPACING * 2.5 - 1, -SPACING, 0])
      mirror()
      thumb_keycap();
}
  
// STKPW,PBLG,12378
module normal_keycap() {
  difference() {
    keyshape(BASE, [-2.5,0,11], [-2.5,0,11], [2.5,0,11], [2.5,0,11], 1, 1.5);
    synth();
  }
}

// HR,****,FRTSDZ,469
module angled_keycap() {
  difference() {
    keyshape(BASE, [0,0,8.5], [0,0,8.5], [3,0,11], [3,0,11], 1, 1);
    synth();
  }
}

// AO EU
module thumb_keycap() {
  difference() {
    keyshape(BASE, [0,-1,9.5], [0,-7,7.5], [3,-7,10], [3,-1,12], 1, 1);
    synth();
  }
}

module synth() {
// ~:$ynth values
translate([1.25, 1.25, 0])
  // We could do 2 instead of 0 for br bl, but we want symmetrical.
  keyshape(15.5, [-1,0,6.25], [-1,0,6.25], [1,0,6.25], [1,0,6.25], 0.25);
}

/**
 * base: int   mm square of base (18 for Cherry keycap)
 * 
 * The four points refer to the offset to their base corners.
 * tr: top right offset
 * br: bottom right offset
 * bl: bottom left offset
 * tl: top left offset
 * 
 * dish_depth: depth for dish, runs top to bottom
 * - It's best if the four points are in a plane.
 */
module keyshape(base, tr, br, bl, tl, r=0.01, dish_depth=0) {
  translate([0, 0, -r]) {
    difference() {
        hull() {
          // To make the shape we make 8 spheres; 1 for each corner.
          // The bottom 4 are determined by making a square around base.
          // The top 4 are the same, but with the translation provided
          // in the function call.
          translate([base-r,r,r])
            sphere(r=r);
          translate([base-r,r,0])
            translate(br)
            sphere(r=r);
           
          translate([r,r,r])
            sphere(r=r);
          translate([r,r,0])
            translate(bl)
            sphere(r=r);
         
          translate([r,base-r,r])
            sphere(r=r);
          translate([r,base-r,0])
            translate(tl)
            sphere(r=r); 
            
          translate([base-r,base-r,r])
            sphere(r=r);
          translate([base-r,base-r,0])
            translate(tr)
            sphere(r=r);
        }
        cube([base+2*r,base+2*r,r]);
        if (dish_depth) {
            //dish_depth = dish_depth - 0.5;
            // We need to make a dish running top to bottom.
            // To do so, we need to get the distance between the two points.
            // Assumption: Points are all in a plane.
            actual_tl = tl + [r, base-r, r];
            actual_tr = tr + [base-r, base-r, r];
            actual_bl = bl + [r, r, r];
            actual_br = br + [base-r, r, r];
            center = (actual_tl + actual_tr + actual_bl + actual_br) / 4;

            distance = sqrt(
              pow(actual_tl[0] - actual_tr[0], 2) +
              pow(actual_tl[1] - actual_tr[1], 2) +
              pow(tl[2] - tr[2], 2)
            );
            // Difference between right and left will give us sides.
            // Front and back will give cylinder angle.
            
            // We need to determine radius...
            a = distance / 2;
            // a^2 + b^2 = c^2, where c is the radius, a is distance / 2, and b is (c - dish_depth)
            // let x = dish_depth
            // Math came out to c=(a^2+x^2)/2x
            r = (pow(a, 2) + pow(dish_depth, 2))/(dish_depth*2);
            dx=actual_tr[0]-actual_tl[0];
            dz=actual_tr[2]-actual_tl[2];
            direction=[-dz, 0, dx]/distance;
            
            length_top_bottom =
              sqrt(
                pow(actual_tl[0] + actual_bl[0], 2) +
                pow(actual_tl[1] + actual_bl[1], 2) +
                pow(actual_tl[2] + actual_bl[2], 2)
              );
            
            d_tlbl = actual_tl - actual_bl;
            rotation_vector = [d_tlbl[2], 0, 0] /length_top_bottom * 90;
            xrot = atan(d_tlbl[2] / d_tlbl[1]);
            
            translate(center + (r-dish_depth)*direction)
              rotate([90, 0, 0])
              rotate([xrot,0,0])
              cylinder(r=r,h=length_top_bottom+r*4, center=true);
        }
    }
  }
}