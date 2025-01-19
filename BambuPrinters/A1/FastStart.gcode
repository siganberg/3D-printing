;===== Machine: A1 =========================
G392 S0
M9833.2

;===== start to heat heatbead&hotend without waiting ==========
M1002 gcode_claim_action : 2
M1002 set_filament_type:{filament_type[initial_no_support_extruder]}
M104 S{nozzle_temperature_initial_layer[initial_extruder]-70} ; wait for initial temperature before homing. 
M302 S{nozzle_temperature_initial_layer[initial_extruder]-70} ; allow this temperature on homing.
M140 S[bed_temperature_initial_layer_single]

;===== reset machine status =================
M204 S6000

M630 S0 P0
G91
M17 Z0.3; lower the z-motor current

G90
M17 X0.65 Y1.2 Z0.6 ; reset motor current to default
M960 S5 P1 ; turn on logo lamp
G90
M220 S100 ;Reset Feedrate
M221 S100 ;Reset Flowrate
M73.2   R1.0 ;Reset left time magnitude

;=== Initial Homing
M1002 gcode_claim_action : 13
G28 X
G90
 
;=== Goto center and do low precision z-homing since we have clean the exturder yet
G0 X128 F30000
G0 Y128 F3000
G28 Z P0 T300

;=== Go to wiping area 
M109 S{nozzle_temperature_initial_layer[initial_extruder]-70} ; wait for initial temperature before wiping. 
M106 S255;
M104 S{nozzle_temperature_initial_layer[initial_extruder]-85} ; reduced the temperature during wiping.
G90
G1 Y250 F30000
G1 X55
G1 Z1.300 F1200
G1 Y262.5 F6000
G91
G1 X-35 F30000
G1 Y-0.5
G1 X45
G1 Y-0.5
G1 X-45
G1 Y-0.5
G1 X45
G1 Y-0.5
G1 X-45
G1 Y-0.5
G1 X45
G1 Z5.000 F1200

;== 2nd pass
G90
G1 Y250 F30000
G1 X55
G1 Z1.300 F1200
G1 Y262.5 F6000
G91
G1 X-35 F30000
G1 Y-0.5
G1 X45
G1 Y-0.5
G1 X-45
G1 Y-0.5
G1 X45
G1 Y-0.5
G1 X-45
G1 Y-0.5
G1 X45
G1 Z5.000 F1200

;== 3nd pass
G90
G1 Y250 F30000
G1 X55
G1 Z1.300 F1200
G1 Y262.5 F6000
G91
G1 X-35 F30000
G1 Y-0.5
G1 X45
G1 Y-0.5
G1 X-45
G1 Y-0.5
G1 X45
G1 Y-0.5
G1 X-45
G1 Y-0.5
G1 X45
G1 Z5.000 F1200

;=== nozzle cleanup routine cleanup done. 
G90 
G1 Z20.000 F1200
M106 S0 ; turn off the fan

; === check if we want to do bed leveling
M1002 judge_flag g29_before_print_flag

M622 J1
    ;===== bed leveling ==================================
    G1 Z5 F1200
    G1 X0 Y0 F30000
    G29.2 S1 ; turn on ABL

    M190 S[bed_temperature_initial_layer_single]; ensure bed temp
    M109 S140

    M1002 gcode_claim_action : 1
    G29 A1 X{first_layer_print_min[0]} Y{first_layer_print_min[1]} I{first_layer_print_size[0]} J{first_layer_print_size[1]}
    M400
    M500 ; save cali data
    G1 Z5 F1200
M623
;===== bed leveling end ================================


M622 J0
    ;=== No Bed leveling selected, just do final homing
    G90
    G0 Z10 F1200
    G0 X128 F30000
    G0 Y128 F3000
    G28 Z P0 T300
    G90
M623

G90
G0 X-48.2 F30000

;===== prepare print temperature and material end =====
M620 M ;enable remap
M620 S[initial_no_support_extruder]A   ; switch material if AMS exist
    M1002 gcode_claim_action : 4
    M400
    M1002 set_filament_type:UNKNOWN
    M109 S[nozzle_temperature_initial_layer]
    M104 S250
    M400
    T[initial_no_support_extruder]
    G1 X-48.2 F3000
    M400

    M620.1 E F{filament_max_volumetric_speed[initial_no_support_extruder]/2.4053*60} T{nozzle_temperature_range_high[initial_no_support_extruder]}
    M109 S250 ;set nozzle to common flush temp
    M106 P1 S0
    G92 E0
    G1 E25 F200 ; (FMM) Reduced to 25, I think 50 is too much
    M400
    M1002 set_filament_type:{filament_type[initial_no_support_extruder]}
M621 S[initial_no_support_extruder]A

M109 S{nozzle_temperature_range_high[initial_no_support_extruder]} H300
G92 E0
G1 E25 F200 ; lower extrusion speed to avoid clog. (FMM). Reduced again to 25
M400
M106 P1 S178
G92 E0
G1 E5 F200
M104 S{nozzle_temperature_initial_layer[initial_no_support_extruder]}
G92 E0
G1 E-0.5 F300

G1 X-28.5 F30000
G1 X-48.2 F3000
G1 X-28.5 F30000 ;wipe and shake
G1 X-48.2 F3000
G1 X-28.5 F30000 ;wipe and shake
G1 X-48.2 F3000

M400
M106 P1 S0
;===== prepare print temperature and material end =====


;========turn off light and wait extrude temperature =============
M1002 gcode_claim_action : 0
M400

;===== nozzle load line ===============================
G90
M83
G1 Z5 F1200
G1 X50 Y-0.5 F20000
G1 Z0.2 F1200 

;=== commented since temperature is already high 
;M109 S{nozzle_temperature_initial_layer[initial_extruder]}

G1 E2 F300
G1 X200 E10 F2000
G1 Z1 F1200
;===== nozzle load line end ===========================


;===== for Textured PEI Plate , lower the nozzle as the nozzle was touching topmost of the texture when homing ==
G29.1 Z-0.02 ; for Textured PEI Plate

M960 S1 P0 ; turn off laser
M960 S2 P0 ; turn off laser
M106 S0 ; turn off fan
M106 P2 S0 ; turn off big fan
M106 P3 S0 ; turn off chamber fan

M975 S1 ; turn on mech mode supression
G90
M83
T1000

M211 X0 Y0 Z0 ;turn off soft endstop
M1007 S1 ; turn on mass estimation
G29.4


