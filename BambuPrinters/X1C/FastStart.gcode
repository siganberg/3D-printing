;===== machine: P1P ========================
;===== date: 202200815 =====================
;===== reset machine status =================
G91
M17 Z0.3 ; lower the z-motor current
G0 Z7 F300 ; lower the hotbed , to prevent the nozzle is below the hotbed
G90
M17 X1.2 Y1.2 Z0.75 ; reset motor current to default
M960 S5 P1 ; turn on logo lamp
G90
M220 S100 ;Reset Feedrate
M221 S100 ;Reset Flowrate
M73.2   R1.0 ;Reset left time magnitude
M1002 set_gcode_claim_speed_level : 5
M221 X0 Y0 Z0 ; turn off soft endstop to prevent protential logic problem

;===== heatbed preheat ====================
M1002 gcode_claim_action : 2
{if bbl_bed_temperature_gcode}
M1002 set_heatbed_surface_temp:[bed_temperature_initial_layer_vector] ;config bed temps
M140 A S[bed_temperature_initial_layer_single] ;set bed temp
M190 A S[bed_temperature_initial_layer_single] ;wait for bed temp
{else}
M140 S[bed_temperature_initial_layer_single] ;set bed temp
M190 S[bed_temperature_initial_layer_single] ;wait for bed temp
{endif}

=============turn on fans to prevent PLA jamming=================
{if filament_type[initial_tool]=="PLA"}
    {if (bed_temperature[current_extruder] >45)||(bed_temperature_initial_layer[current_extruder] >45)}
    M106 P3 S100
    {elsif (bed_temperature[current_extruder] >50)||(bed_temperature_initial_layer[current_extruder] >50)}
    M106 P3 S100
    {endif};Prevent PLA from jamming
{endif}
M106 P2 S100 ; turn on big fan ,to cool down toolhead

;===== prepare print temperature and material ==========
M104 S[nozzle_temperature_initial_layer] ;set extruder temp
G91
G0 Z2 F1200
G90
G28 X
M975 S1 ; turn on 
G1 X60 F12000
G1 Y245
G1 Y265 F3000
M620 M
M620 S[initial_tool]A   ; switch material if AMS exist
    M109 S[nozzle_temperature_initial_layer]
    G1 X120 F12000

    G1 X20 Y50 F12000
    G1 Y-3
    T[initial_tool]
    G1 X54 F12000
    G1 Y265
    M400
M621 S[initial_tool]A

M412 S1 ; ===turn on filament runout detection===

M109 S240 ;set nozzle to common flush temp
M106 P1 S0
G92 E0
G1 E50 F200
M400
M104 S[nozzle_temperature_initial_layer]
G92 E0
G1 E20 F200
M400
M106 P1 S255
G92 E0
G1 E5 F300
M109 S{nozzle_temperature_initial_layer[initial_extruder]-20} ; drop nozzle temp, make filament shink a bit
G92 E0
G1 E-0.5 F300
G1 X70 F9000
G1 X76 F15000
G1 X65 F15000
G1 X76 F15000
G1 X65 F15000; shake to put down garbage
G1 X80 F6000
G1 X95 F15000
G1 X80 F15000
G1 X95 F15000
G1 X76 F15000; wipe and shake


;== Custom Shake for TPU 
M109 S{nozzle_temperature_initial_layer[initial_extruder]-40} ; drop nozzle temp, make filament shink a bit
G1 X80 F6000
G1 X95 F15000
G1 X80 F15000
G1 X95 F15000
G1 X76 F15000; wipe and shake
M109 S{nozzle_temperature_initial_layer[initial_extruder]-60} ; drop nozzle temp, make filament shink a bit
G1 X80 F6000
G1 X95 F15000
G1 X80 F15000
G1 X95 F15000
G1 X76 F15000; wipe and shake
M109 S{nozzle_temperature_initial_layer[initial_extruder]-80} ; drop nozzle temp, make filament shink a bit
G1 X80 F6000
G1 X95 F15000
G1 X80 F15000
G1 X95 F15000
G1 X76 F15000; wipe and shake

M400
M106 P1 S0


G0 X135 Y253 F20000  ; move to exposed steel surface edge
G28 Z P0 T300; home z with low precision,permit 300deg temperature
G29.2 S0 ; turn off ABL
G0 Z2 F20000

G1 X60 Y265
G92 E0
G1 E-0.5 F300 ; retrack more
G1 X100 F5000; second wipe mouth
G1 X70 F15000
G1 X100 F5000
G1 X70 F15000
G1 X100 F5000
G1 X70 F15000
G1 X100 F5000
G1 X70 F15000
G1 X90 F5000

# G0 X128 Y261 Z-1.5 F20000  ; move to exposed steel surface and stop the nozzle
M104 S160 ; set temp down to heatbed acceptable
M106 S255 ; turn on fan (G28 has turn off fan)

M221 R; pop softend status
G1 Z10 F1200
M400
G1 Z10
G1 F30000
G1 X230 Y15
G29.2 S1 ; turn on ABL
G28 ; home again after hard wipe mouth
M106 S0 ; turn off fan , too noisy
;===== wipe nozzle end ================================

;===== bed leveling ==================================
M1002 judge_flag g29_before_print_flag
M622 J1

    M1002 gcode_claim_action : 1
    G29 A X{first_layer_print_min[0]} Y{first_layer_print_min[1]} I{first_layer_print_size[0]} J{first_layer_print_size[1]}
    M400
    M500 ; save cali data

M623
;===== bed leveling end ================================

;===== home after wipe mouth============================
#M1002 judge_flag g29_before_print_flag
#M622 J0
#
#    M1002 gcode_claim_action : 13
#    G28
#
#M623
;===== home after wipe mouth end =======================

M975 S1 ; turn on vibration supression
=============turn on fans to prevent PLA jamming=================
{if filament_type[initial_tool]=="PLA"}
    {if (bed_temperature[current_extruder] >45)||(bed_temperature_initial_layer[current_extruder] >45)}
    M106 P3 S100
    {elsif (bed_temperature[current_extruder] >50)||(bed_temperature_initial_layer[current_extruder] >50)}
    M106 P3 S100
    {endif};Prevent PLA from jamming
{endif}
M106 P2 S100 ; turn on big fan ,to cool down toolhead


M104 S{nozzle_temperature_initial_layer[initial_extruder]} ; set extrude temp earlier, to reduce wait time

;===== noozle load line ===============================
M975 S1
G90 
M83
T1000
G1 X18.0 Y5.0 Z0.2 F18000;Move to start position
M109 S{nozzle_temperature[initial_extruder]}
G0 E3 F300
G0 X240 E15 F{outer_wall_volumetric_speed/(0.3*0.5)     * 60} 
G0 Y5.5 
G0 X18 E15
M400

;========turn off light and wait extrude temperature =============
M1002 gcode_claim_action : 0
M106 S0 ; turn off fan
M106 P2 S0 ; turn off big fan 
M106 P3 S0 ; turn off chamber fan

M975 S1 ; turn on mech mode supression
