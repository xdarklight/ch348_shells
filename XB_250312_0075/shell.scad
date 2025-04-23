// PARAMETERS
pcb_length = 68.5;
pcb_width = 49;
pcb_height = 2;
usb_c_width = 8.9;
usb_c_height = 3.3;
usb_c_margin_w = 2;
usb_c_margin_h = 2;
serial_height = 6;
clearance = 0.5;
wall = 2;

// CLIP PARAMETERS
clip_width = 8;
clip_depth = wall; // clip depth equals wall thickness
clip_height = 2 * wall; // updated clip height = 2 * wall
clip_gap = 0.3;   // Clearance for snap fit
clips_per_side = 2;

// Cutout parameters
roof_cutout1_size = 15;
roof_cutout1_offset_x = wall + 15;
roof_cutout1_offset_y = (pcb_width + 2*clearance + 2*wall - roof_cutout1_size) / 2;
roof_cutout2_x = 15;
roof_cutout2_y = 20;
roof_cutout2_offset_x = (pcb_length + 2*clearance + 2*wall) - wall - 3 - roof_cutout2_x;
roof_cutout2_offset_y = (pcb_width + 2*clearance + 2*wall - roof_cutout2_y) / 2;

usb_c_cutout_width = usb_c_width + 2*usb_c_margin_w;
usb_c_cutout_height = usb_c_height + 2*usb_c_margin_h;

// Enclosure dimensions
inner_length = pcb_length + 2*clearance;
inner_width  = pcb_width  + 2*clearance;
inner_height = (pcb_height - wall) + serial_height + clearance;
outer_length = inner_length + 2*wall;
outer_width  = inner_width  + 2*wall;
outer_height = inner_height + wall*2;

// Calculate USB cutout Y-range
usb_c_y_min = (outer_width / 2) - (usb_c_cutout_width / 2);
usb_c_y_max = (outer_width / 2) + (usb_c_cutout_width / 2);

text_size = 4;
text_depth = wall / 2;

// Function for safe clip positions, avoids USB port
function safe_clip_positions(count, total_length, wall, clip_width, avoid_min, avoid_max) =
    let(
        region1 = [wall, avoid_min - clip_width],
        region2 = [avoid_max, total_length - wall - clip_width],
        region1_len = max(0, region1[1] - region1[0]),
        region2_len = max(0, region2[1] - region2[0]),
        total_len = region1_len + region2_len
    )
    count == 2 ?
        // One in each region, centered
        [ region1_len > 0 ? region1[0] + region1_len/2 : region2[0] + region2_len/2,
          region2_len > 0 ? region2[0] + region2_len/2 : region1[0] + region1_len/2 ] :
    count == 4 ?
        // Two in each region, quarter and three-quarter points
        [ region1[0] + region1_len/4, region1[0] + 3*region1_len/4,
          region2[0] + region2_len/4, region2[0] + 3*region2_len/4 ] :
    []; // Extend as needed

// Clip slot in floor (negative, to be subtracted)
module clip_slot(y_pos) {
    // At floor top surface (z=0), slots go into the floor thickness (z positive)
    translate([0, y_pos, 0])
        cube([clip_depth + clip_gap, clip_width, clip_height]);
    translate([outer_length - clip_depth - clip_gap, y_pos, 0])
        cube([clip_depth + clip_gap, clip_width, clip_height]);
}

// Clip tab on shell (positive, to be added)
module clip_tab(y_pos) {
    // Tabs stick down from shell bottom (z=wall), so translate to z=wall - clip_height
    translate([0, y_pos, wall - clip_height])
        cube([clip_depth, clip_width, clip_height]);
    translate([outer_length - clip_depth, y_pos, wall - clip_height])
        cube([clip_depth, clip_width, clip_height]);
}

// SHELL (no bottom)
module shell() {
    difference() {
        union() {
            // Walls and top plate
            translate([0, 0, 0])
                cube([outer_length, wall, outer_height]);
            translate([0, outer_width - wall, 0])
                cube([outer_length, wall, outer_height]);
            translate([0, wall, 0])
                cube([wall, outer_width - 2*wall, outer_height]);
            translate([outer_length - wall, wall, 0])
                cube([wall, outer_width - 2*wall, outer_height]);
            translate([0, 0, outer_height - wall])
                cube([outer_length, outer_width, wall]);

            // --- CLIP TABS ON SHELL ---
            for (y_pos = safe_clip_positions(clips_per_side, outer_width, wall, clip_width, usb_c_y_min, usb_c_y_max))
                clip_tab(y_pos);
        }

        // Hollow for PCB and connectors (starts at z=wall)
        translate([wall, wall, wall])
            cube([inner_length, inner_width, inner_height]);

        // Openings on both long sides (for serial connectors)
        translate([wall, 0, wall])
            cube([inner_length, wall + 0.1, inner_height]);
        translate([wall, outer_width - wall, wall])
            cube([inner_length, wall + 0.1, inner_height]);

        translate([wall + text_size, inner_width / 2, outer_height - wall + text_depth])
            rotate([0,0,90])
            linear_extrude(text_depth)
                text("CON: _VRTG", size = text_size, halign = "center", valign = "center");

        translate([wall + (15 * 1), wall + text_size, outer_height - wall + text_depth])
            linear_extrude(text_depth)
                text("_A", size = text_size, halign = "right", valign = "center");

        translate([wall + (15 * 2), wall + text_size, outer_height - wall + text_depth])
            linear_extrude(text_depth)
                text("_B", size = text_size, halign = "right", valign = "center");

        translate([wall + (15 * 3), wall + text_size, outer_height - wall + text_depth])
            linear_extrude(text_depth)
                text("_C", size = text_size, halign = "right", valign = "center");

        translate([wall + (15 * 4), wall + text_size, outer_height - wall + text_depth])
            linear_extrude(text_depth)
                text("_D", size = text_size, halign = "right", valign = "center");

        translate([wall + (15 * 4), outer_width - wall - text_size, outer_height - wall + text_depth])
            rotate([180,180,0])
            linear_extrude(text_depth)
                text("_E", size = text_size, halign = "left", valign = "center");

        translate([wall + (15 * 3), outer_width - wall - text_size, outer_height - wall + text_depth])
            rotate([180,180,0])
            linear_extrude(text_depth)
                text("_F", size = text_size, halign = "left", valign = "center");

        translate([wall + (15 * 2), outer_width - wall - text_size, outer_height - wall + text_depth])
            rotate([180,180,0])
            linear_extrude(text_depth)
                text("_G", size = text_size, halign = "left", valign = "center");

        translate([wall + (15 * 1), outer_width - wall - text_size, outer_height - wall + text_depth])
            rotate([180,180,0])
            linear_extrude(text_depth)
                text("_H", size = text_size, halign = "left", valign = "center");

        // USB-C cutout extending to floor
        translate([0, outer_width / 2 - usb_c_cutout_width / 2, 0])
            cube([wall + 0.1, usb_c_cutout_width, usb_c_cutout_height]);

        // Roof (top) cutout 1
        translate([roof_cutout1_offset_x, roof_cutout1_offset_y, outer_height - wall])
            cube([roof_cutout1_size, roof_cutout1_size, wall + 0.1]);

        translate([roof_cutout1_offset_x + roof_cutout1_size + (text_size / 2), roof_cutout1_offset_y + (roof_cutout1_size / 2) + 3, outer_height - wall + text_depth])
            linear_extrude(text_depth)
                text("PWR", size = text_size, halign = "left", valign = "center");

        translate([roof_cutout1_offset_x + roof_cutout1_size + (text_size / 2), roof_cutout1_offset_y + (roof_cutout1_size / 2) - 3, outer_height - wall + text_depth])
            linear_extrude(text_depth)
                text("ACT", size = text_size, halign = "left", valign = "center");

        // Roof (top) cutout 2 (1x3cm)
        translate([roof_cutout2_offset_x, roof_cutout2_offset_y, outer_height - wall])
            cube([roof_cutout2_x, roof_cutout2_y, wall + 0.1]);
    }
}

// FLOOR (bottom plate with slots and USB cutout)
module floor() {
    difference() {
        cube([outer_length, outer_width, wall]);

        // --- CLIP SLOTS ON FLOOR ---
        for (y_pos = safe_clip_positions(clips_per_side, outer_width, wall, clip_width, usb_c_y_min, usb_c_y_max))
            clip_slot(y_pos);

        // --- USB PORT CUTOUT IN FLOOR ---
        translate([0, usb_c_y_min, 0])
            cube([wall + 0.1, usb_c_cutout_width, wall + 0.1]);

        translate([outer_length / 2, (outer_width / 2) + (5 * text_size), wall - text_depth])
            linear_extrude(text_depth)
                text("XB0201348 Version: 4", size = text_size, halign = "center", valign = "center");

        translate([outer_length / 2, (outer_width / 2) + (3 * text_size), wall - text_depth])
            linear_extrude(text_depth)
                text("XB_250312_0075", size = text_size, halign = "center", valign = "center");

        translate([outer_length / 2, (outer_width / 2) + (1 * text_size), wall - text_depth])
            linear_extrude(text_depth)
                text("VCC: 3.3V; RX, TX: 3.3V", size = text_size, halign = "center", valign = "center");

        translate([outer_length / 2, (outer_width / 2) - (1 * text_size), wall - text_depth])
            linear_extrude(text_depth)
                text("VCC: 5.0V; RX, TX: 5.0V", size = text_size, halign = "center", valign = "center");

        translate([outer_length / 2, (outer_width / 2) - (5 * text_size), wall - text_depth])
            linear_extrude(text_depth)
                text("shell ver. 0.2", size = text_size, halign = "center", valign = "center");
    }
}

// Show both parts, separated for clarity
shell();
translate([0, outer_width + wall, outer_height - wall]) // translate([0, 0, -wall - 2])
    floor();

