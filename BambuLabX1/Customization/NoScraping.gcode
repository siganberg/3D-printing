
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

{if scan_first_layer}
;=========register first layer scan=====
M977 S1 P60
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

M109 S250 ;set nozzle to common flush temp
M106 P1 S0
G92 E0
G1 E50 F200
M400
M104 S[nozzle_temperature_initial_layer]
G92 E0
G1 E50 F200
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
G1 X165 F15000; wipe and shake
M400
M106 P1 S0
;===== prepare print temperature and material end =====


;===== wipe nozzle ===============================
M1002 gcode_claim_action : 14
M975 S1
M106 S255
G1 X65 Y230 F18000
G1 Y264 F6000
M109 S{nozzle_temperature_initial_layer[initial_extruder]-20}
G1 X100 F18000 ; first wipe mouth

G0 X135 Y253 F20000  ; move to exposed steel surface edge
G28 Z P0 T300; home z with low precision,permit 300deg temperature
G29.2 S0 ; turn off ABL

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
G0 X128 Y261 Z-1.5 F20000  ; move to exposed steel surface and stop the nozzle
M104 S140 ; set temp down to heatbed acceptable
M106 S255 ; turn on fan (G28 has turn off fan)

M221 R; pop softend status
G1 Z10 F1200
M400
G1 Z10
G1 F30000
G1 X230 Y15
G29.2 S1 ; turn on ABL
;G28 ; home again after hard wipe mouth
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
M1002 judge_flag g29_before_print_flag
M622 J0

    M1002 gcode_claim_action : 13
    G28

M623
;===== home after wipe mouth end =======================

M975 S1 ; turn on vibration supression

;===== check scanner clarity ===========================
M972 S5 P0  
M400 S1
;===== check scanner clarity end =======================

=============turn on fans to prevent PLA jamming=================
{if filament_type[initial_tool]=="PLA"}
    {if (bed_temperature[current_extruder] >45)||(bed_temperature_initial_layer[current_extruder] >45)}
    M106 P3 S180
    {elsif (bed_temperature[current_extruder] >50)||(bed_temperature_initial_layer[current_extruder] >50)}
    M106 P3 S255
    {endif};Prevent PLA from jamming
{endif}
M106 P2 S100 ; turn on big fan ,to cool down toolhead

{if scan_first_layer}
;start heatbed  scan====================================
M976 S2 P1 
{endif}

M104 S{nozzle_temperature_initial_layer[initial_extruder]} ; set extrude temp earlier, to reduce wait time

;===== mech mode fast check============================
G1 X128 Y128 Z5 F20000
M400 P200
M970.3 Q1 A7 B30 C80  H15 K0
M974 Q1 S2 P0

G1 X128 Y128 Z5 F20000
M400 P200
M970.3 Q0 A7 B30 C90 Q0 H15 K0
M974 Q0 S2 P0

M975 S1
G1 F30000
G1 X230 Y15
G28 X ; re-home XY 
;===== fmech mode fast check============================


;===== noozle load line ===============================
M975 S1
G90 
M83
T1000
G1 X18.0 Y5.0 Z0.3 F18000;Move to start position
M109 S{nozzle_temperature[initial_extruder]}
G0 E3 F300
G0 X240 E15 F{outer_wall_volumetric_speed/(0.3*0.5)     * 60} 
G0 Y5.5 
G0 X18 E15
M400

;===== draw extrinsic para cali paint =================
M1002 judge_flag extrude_cali_flag
M622 J1

    M1002 gcode_claim_action : 8

    T1000 
    G0 F3000 X28.000 Y19.500 Z0.200
    G1 F1200.0 X28.000 Y45.000 Z0.200 E0.933 
    G1 F1200.0 X28.500 Y45.000 Z0.200 E0.018 
    G1 F1200.0 X28.500 Y19.500 Z0.200 E0.933 
    G1 F1200.0 X31.000 Y19.500 Z0.200 E0.091 
    G1 F1200.0 X31.000 Y49.000 Z0.200 E1.080 
    G1 F1200.0 X37.500 Y49.000 Z0.200 E0.238 
    G1 F1200.0 X37.500 Y60.000 Z0.200 E0.403 
    G1 F1200.0 X42.500 Y60.000 Z0.200 E0.183 
    G1 F1200.0 X42.500 Y49.000 Z0.200 E0.403 
    G1 F1200.0 X48.000 Y49.000 Z0.200 E0.201 
    G1 F1200.0 X48.000 Y20.000 Z0.200 E1.061 
    G1 F1200.0 X30.000 Y20.000 Z0.200 E0.659 
    G1 F1200.0 X30.000 Y41.000 Z0.200 E0.769 
    G1 F1200.0 X50.000 Y41.000 Z0.200 E0.732 
    G1 F1200.0 X50.000 Y34.000 Z0.200 E0.256 
    G1 F1200.0 X30.000 Y34.000 Z0.200 E0.732 
    G1 F1500.000 E-0.800 

    ;=========== extruder cali extrusion ================== 
    T1000 
    M83 

    ;G0 X18 Y28 F20000
    ;G0 Y0
    ;G0 Z0.3
    ;G0 X250 E18 F{outer_wall_volumetric_speed/(0.3*0.5)    * 60}
    ;G0 Y0.5
    ;G0 X18 E18 F{outer_wall_volumetric_speed/(0.3*0.5)    * 60}

    G0 X35.000 Y18.000 Z0.300 F30000 E0
    G1 F1500.000 E0.800 
    M106 S0 ; turn off fan
    G0 X185.000 E9.35441 F{outer_wall_volumetric_speed/(0.3*0.5)    * 60}
    G0 X187 Z0
    G1 F1500.000 E-0.800 
    G0 Z1
    G0 X180 Z0.3 F18000
    
    M900 L1000.0 M1.0
    M900 K0.040 
    G0 X45.000 F30000 
    G0 Y20.000 F30000 
    G1 F1500.000 E0.800 
    G1 X65.000 E1.24726 F{outer_wall_volumetric_speed/(0.3*0.5)/ 4 * 60}
    G1 X70.000 E0.31181 F{outer_wall_volumetric_speed/(0.3*0.5)/ 4 * 60} 
    G1 X75.000 E0.31181 F{outer_wall_volumetric_speed/(0.3*0.5)    * 60}  
    G1 X80.000 E0.31181 F{outer_wall_volumetric_speed/(0.3*0.5)/ 4 * 60} 
    G1 X85.000 E0.31181 F{outer_wall_volumetric_speed/(0.3*0.5)    * 60}  
    G1 X90.000 E0.31181 F{outer_wall_volumetric_speed/(0.3*0.5)/ 4 * 60} 
    G1 X95.000 E0.31181 F{outer_wall_volumetric_speed/(0.3*0.5)    * 60}  
    G1 X100.000 E0.31181 F{outer_wall_volumetric_speed/(0.3*0.5)/ 4 * 60} 
    G1 X105.000 E0.31181 F{outer_wall_volumetric_speed/(0.3*0.5)    * 60}  
    G1 X110.000 E0.31181 F{outer_wall_volumetric_speed/(0.3*0.5)/ 4 * 60} 
    G1 X115.000 E0.31181 F{outer_wall_volumetric_speed/(0.3*0.5)    * 60}  
    G1 X120.000 E0.31181 F{outer_wall_volumetric_speed/(0.3*0.5)/ 4 * 60} 
    G1 X125.000 E0.31181 F{outer_wall_volumetric_speed/(0.3*0.5)    * 60}  
    G1 X130.000 E0.31181 F{outer_wall_volumetric_speed/(0.3*0.5)/ 4 * 60} 
    G1 X135.000 E0.31181 F{outer_wall_volumetric_speed/(0.3*0.5)    * 60}  
    G1 X140.000 E0.31181 F{outer_wall_volumetric_speed/(0.3*0.5)/ 4 * 60} 
    G1 X145.000 E0.31181 F{outer_wall_volumetric_speed/(0.3*0.5)    * 60}  
    G1 X150.000 E0.31181 F{outer_wall_volumetric_speed/(0.3*0.5)/ 4 * 60} 
    G1 X155.000 E0.31181 F{outer_wall_volumetric_speed/(0.3*0.5)    * 60}  
    G1 X160.000 E0.31181 F{outer_wall_volumetric_speed/(0.3*0.5)/ 4 * 60} 
    G1 X165.000 E0.31181 F{outer_wall_volumetric_speed/(0.3*0.5)    * 60}  
    G1 X170.000 E0.31181 F{outer_wall_volumetric_speed/(0.3*0.5)/ 4 * 60} 
    G1 X175.000 E0.31181 F{outer_wall_volumetric_speed/(0.3*0.5)    * 60}  
    G1 X180.000 E0.31181 F{outer_wall_volumetric_speed/(0.3*0.5)    * 60}  
    G1 F1500.000 E-0.800 
    G1 X183 Z0.15 F30000
    G1 X185
    G1 Z1.0
    G0 Y18.000 F30000 ; move y to clear pos 
    G1 Z0.3
    M400

    G0 X45.000 F30000 
    M900 K0.020 
    G0 X45.000 F30000 
    G0 Y22.000 F30000 
    G1 F1500.000 E0.800 
    G1 X65.000 E1.24726 F{outer_wall_volumetric_speed/(0.3*0.5)/ 4 * 60}
    G1 X70.000 E0.31181 F{outer_wall_volumetric_speed/(0.3*0.5)/ 4 * 60} 
    G1 X75.000 E0.31181 F{outer_wall_volumetric_speed/(0.3*0.5)    * 60}  
    G1 X80.000 E0.31181 F{outer_wall_volumetric_speed/(0.3*0.5)/ 4 * 60} 
    G1 X85.000 E0.31181 F{outer_wall_volumetric_speed/(0.3*0.5)    * 60}  
    G1 X90.000 E0.31181 F{outer_wall_volumetric_speed/(0.3*0.5)/ 4 * 60} 
    G1 X95.000 E0.31181 F{outer_wall_volumetric_speed/(0.3*0.5)    * 60}  
    G1 X100.000 E0.31181 F{outer_wall_volumetric_speed/(0.3*0.5)/ 4 * 60} 
    G1 X105.000 E0.31181 F{outer_wall_volumetric_speed/(0.3*0.5)    * 60}  
    G1 X110.000 E0.31181 F{outer_wall_volumetric_speed/(0.3*0.5)/ 4 * 60} 
    G1 X115.000 E0.31181 F{outer_wall_volumetric_speed/(0.3*0.5)    * 60}  
    G1 X120.000 E0.31181 F{outer_wall_volumetric_speed/(0.3*0.5)/ 4 * 60} 
    G1 X125.000 E0.31181 F{outer_wall_volumetric_speed/(0.3*0.5)    * 60}  
    G1 X130.000 E0.31181 F{outer_wall_volumetric_speed/(0.3*0.5)/ 4 * 60} 
    G1 X135.000 E0.31181 F{outer_wall_volumetric_speed/(0.3*0.5)    * 60}  
    G1 X140.000 E0.31181 F{outer_wall_volumetric_speed/(0.3*0.5)/ 4 * 60} 
    G1 X145.000 E0.31181 F{outer_wall_volumetric_speed/(0.3*0.5)    * 60}  
    G1 X150.000 E0.31181 F{outer_wall_volumetric_speed/(0.3*0.5)/ 4 * 60} 
    G1 X155.000 E0.31181 F{outer_wall_volumetric_speed/(0.3*0.5)    * 60}  
    G1 X160.000 E0.31181 F{outer_wall_volumetric_speed/(0.3*0.5)/ 4 * 60} 
    G1 X165.000 E0.31181 F{outer_wall_volumetric_speed/(0.3*0.5)    * 60}  
    G1 X170.000 E0.31181 F{outer_wall_volumetric_speed/(0.3*0.5)/ 4 * 60} 
    G1 X175.000 E0.31181 F{outer_wall_volumetric_speed/(0.3*0.5)    * 60}  
    G1 X180.000 E0.31181 F{outer_wall_volumetric_speed/(0.3*0.5)    * 60}  
    G1 F1500.000 E-0.800 
    G1 X183 Z0.15 F30000
    G1 X185
    G1 Z1.0
    G0 Y18.000 F30000 ; move y to clear pos 
    G1 Z0.3
    M400

    G0 X45.000 F30000 
    M900 K0.000 
    G0 X45.000 F30000 
    G0 Y24.000 F30000 
    G1 F1500.000 E0.800 
    G1 X65.000 E1.24726 F{outer_wall_volumetric_speed/(0.3*0.5)/ 4 * 60}
    G1 X70.000 E0.31181 F{outer_wall_volumetric_speed/(0.3*0.5)/ 4 * 60} 
    G1 X75.000 E0.31181 F{outer_wall_volumetric_speed/(0.3*0.5)    * 60}  
    G1 X80.000 E0.31181 F{outer_wall_volumetric_speed/(0.3*0.5)/ 4 * 60} 
    G1 X85.000 E0.31181 F{outer_wall_volumetric_speed/(0.3*0.5)    * 60}  
    G1 X90.000 E0.31181 F{outer_wall_volumetric_speed/(0.3*0.5)/ 4 * 60} 
    G1 X95.000 E0.31181 F{outer_wall_volumetric_speed/(0.3*0.5)    * 60}  
    G1 X100.000 E0.31181 F{outer_wall_volumetric_speed/(0.3*0.5)/ 4 * 60} 
    G1 X105.000 E0.31181 F{outer_wall_volumetric_speed/(0.3*0.5)    * 60}  
    G1 X110.000 E0.31181 F{outer_wall_volumetric_speed/(0.3*0.5)/ 4 * 60} 
    G1 X115.000 E0.31181 F{outer_wall_volumetric_speed/(0.3*0.5)    * 60}  
    G1 X120.000 E0.31181 F{outer_wall_volumetric_speed/(0.3*0.5)/ 4 * 60} 
    G1 X125.000 E0.31181 F{outer_wall_volumetric_speed/(0.3*0.5)    * 60}  
    G1 X130.000 E0.31181 F{outer_wall_volumetric_speed/(0.3*0.5)/ 4 * 60} 
    G1 X135.000 E0.31181 F{outer_wall_volumetric_speed/(0.3*0.5)    * 60}  
    G1 X140.000 E0.31181 F{outer_wall_volumetric_speed/(0.3*0.5)/ 4 * 60} 
    G1 X145.000 E0.31181 F{outer_wall_volumetric_speed/(0.3*0.5)    * 60}  
    G1 X150.000 E0.31181 F{outer_wall_volumetric_speed/(0.3*0.5)/ 4 * 60} 
    G1 X155.000 E0.31181 F{outer_wall_volumetric_speed/(0.3*0.5)    * 60}  
    G1 X160.000 E0.31181 F{outer_wall_volumetric_speed/(0.3*0.5)/ 4 * 60} 
    G1 X165.000 E0.31181 F{outer_wall_volumetric_speed/(0.3*0.5)    * 60}  
    G1 X170.000 E0.31181 F{outer_wall_volumetric_speed/(0.3*0.5)/ 4 * 60} 
    G1 X175.000 E0.31181 F{outer_wall_volumetric_speed/(0.3*0.5)    * 60}  
    G1 X180.000 E0.31181 F{outer_wall_volumetric_speed/(0.3*0.5)    * 60}  
    G1 F1500.000 E-0.800
    G1 X183 Z0.15 F30000
    G1 X185
    G1 Z1.0
    G0 Y18.000 F30000 ; move y to clear pos 
    G1 Z0.3

    G0 X45.000 F30000 ; move to start point

M623 ; end of "draw extrinsic para cali paint"

M104 S140


;=========== laser and rgb calibration =========== 
M400
M18 E
M500 R

M973 S3 P14

G1 X120 Y5.0 Z0.3 F18000.0;Move to first extrude line pos
T1100
G1 X143.0 Y5.0 Z0.3 F18000.0;Move to first extrude line pos

M400 P100

M960 S1 P1
M400 P100
M973 S6 ; use auto exposure by xcam
M960 S0 P0

;=========== handeye calibration ======================
M1002 judge_flag extrude_cali_flag
M622 J1

    M973 S3 P1 ; camera start stream
    M400 P500
    M973 S1 
    G0 F6000 X40.000 Y54.500 Z0.000 
    M960 S0 P1
    M973 S1
    M400 P800
    M971 S6 P0
    M973 S2 P16000
    M400 P500 
    G0 Z0.000 F12000
    M960 S0 P0
    M960 S1 P1 
    G0 Y37.50 
    M400 P200
    M971 S5 P1 
    M960 S0 P0
    M960 S2 P1 
    G0 Y54.50 
    M400 P200 
    M971 S5 P3 
    G0 Z0.500 F12000
    M960 S0 P0
    M960 S1 P1 
    G0 Y37.50 
    M400 P200
    M971 S5 P2 
    M960 S0 P0
    M960 S2 P1 
    G0 Y54.50 
    M400 P500 
    M971 S5 P4 
    M963 S1 
    M400 P1500 
    M964 
    T1100 
    G0 F6000 X40.000 Y54.500 Z0.000 
    M960 S0 P1
    M973 S1
    M400 P800
    M971 S6 P0
    M973 S2 P16000
    M400 P500 
    G0 Z0.000 F12000
    M960 S0 P0
    M960 S1 P1 
    G0 Y37.50 
    M400 P200
    M971 S5 P1 
    M960 S0 P0
    M960 S2 P1 
    G0 Y54.50 
    M400 P200 
    M971 S5 P3 
    G0 Z0.500 F12000
    M960 S0 P0
    M960 S1 P1 
    G0 Y37.50 
    M400 P200
    M971 S5 P2 
    M960 S0 P0
    M960 S2 P1 
    G0 Y54.50 
    M400 P500 
    M971 S5 P4 
    M963 S1 
    M400 P1500 
    M964 
    T1100 
    G1 Z3 F3000 

    M400
    M500 ; save cali data

    M104 S{nozzle_temperature[initial_extruder]} ; rise nozzle temp now ,to reduce temp waiting time.

    T1100 
    M400 P400 
    M960 S0 P0
    G0 F30000.000 Y22.000 X65.000 Z0.000
    M400 P400 
    M960 S1 P1 
    M400 P50 

    M969 S1 N3 A2000 
    G0 F360.000 X181.000 Z0.000
    M980.3 A70.000 B{outer_wall_volumetric_speed/(1.75*1.75/4*3.14)*60/4} C5.000 D{outer_wall_volumetric_speed/(1.75*1.75/4*3.14)*60} E5.000 F175.000 H1.000 I0.000 J0.020 K0.040
    M400 P100 
    G0 F20000
    G0 Z1 ; rise nozzle up
    T1000 ; change to nozzle space
    G0 X45.000 Y16.000 F30000 ; move to test line pos
    M969 S0 ; turn off scanning
    M960 S0 P0


    G1 Z2 F20000 
    T1000 
    G0 X45.000 Y16.000 F30000 E0
    M109 S{nozzle_temperature[initial_extruder]}
    G0 Z0.3
    G1 F1500.000 E3.600 
    G1 X65.000 E1.24726 F{outer_wall_volumetric_speed/(0.3*0.5)/ 4 * 60}
    G1 X70.000 E0.31181 F{outer_wall_volumetric_speed/(0.3*0.5)/ 4 * 60} 
    G1 X75.000 E0.31181 F{outer_wall_volumetric_speed/(0.3*0.5)    * 60}  
    G1 X80.000 E0.31181 F{outer_wall_volumetric_speed/(0.3*0.5)/ 4 * 60} 
    G1 X85.000 E0.31181 F{outer_wall_volumetric_speed/(0.3*0.5)    * 60}  
    G1 X90.000 E0.31181 F{outer_wall_volumetric_speed/(0.3*0.5)/ 4 * 60} 
    G1 X95.000 E0.31181 F{outer_wall_volumetric_speed/(0.3*0.5)    * 60}  
    G1 X100.000 E0.31181 F{outer_wall_volumetric_speed/(0.3*0.5)/ 4 * 60} 
    G1 X105.000 E0.31181 F{outer_wall_volumetric_speed/(0.3*0.5)    * 60}  
    G1 X110.000 E0.31181 F{outer_wall_volumetric_speed/(0.3*0.5)/ 4 * 60} 
    G1 X115.000 E0.31181 F{outer_wall_volumetric_speed/(0.3*0.5)    * 60}  
    G1 X120.000 E0.31181 F{outer_wall_volumetric_speed/(0.3*0.5)/ 4 * 60} 
    G1 X125.000 E0.31181 F{outer_wall_volumetric_speed/(0.3*0.5)    * 60}  
    G1 X130.000 E0.31181 F{outer_wall_volumetric_speed/(0.3*0.5)/ 4 * 60} 
    G1 X135.000 E0.31181 F{outer_wall_volumetric_speed/(0.3*0.5)    * 60}

    ; see if extrude cali success, if not ,use default value
    M1002 judge_last_extrude_cali_success
    M622 J0
        M400
        M900 K0.02 M{outer_wall_volumetric_speed/(1.75*1.75/4*3.14)*0.02}
    M623 

    G1 X140.000 E0.31181 F{outer_wall_volumetric_speed/(0.3*0.5)/ 4 * 60} 
    G1 X145.000 E0.31181 F{outer_wall_volumetric_speed/(0.3*0.5)    * 60}  
    G1 X150.000 E0.31181 F{outer_wall_volumetric_speed/(0.3*0.5)/ 4 * 60} 
    G1 X155.000 E0.31181 F{outer_wall_volumetric_speed/(0.3*0.5)    * 60}  
    G1 X160.000 E0.31181 F{outer_wall_volumetric_speed/(0.3*0.5)/ 4 * 60} 
    G1 X165.000 E0.31181 F{outer_wall_volumetric_speed/(0.3*0.5)    * 60}  
    G1 X170.000 E0.31181 F{outer_wall_volumetric_speed/(0.3*0.5)/ 4 * 60} 
    G1 X175.000 E0.31181 F{outer_wall_volumetric_speed/(0.3*0.5)    * 60}  
    G1 X180.000 E0.31181 F{outer_wall_volumetric_speed/(0.3*0.5)/ 4 * 60} 
    G1 X185.000 E0.31181 F{outer_wall_volumetric_speed/(0.3*0.5)    * 60} 
    G1 X190.000 E0.31181 F{outer_wall_volumetric_speed/(0.3*0.5)/ 4 * 60} 
    G1 X195.000 E0.31181 F{outer_wall_volumetric_speed/(0.3*0.5)    * 60} 
    G1 X200.000 E0.31181 F{outer_wall_volumetric_speed/(0.3*0.5)/ 4 * 60} 
    G1 X205.000 E0.31181 F{outer_wall_volumetric_speed/(0.3*0.5)    * 60} 
    G1 X210.000 E0.31181 F{outer_wall_volumetric_speed/(0.3*0.5)/ 4 * 60} 
    G1 X215.000 E0.31181 F{outer_wall_volumetric_speed/(0.3*0.5)    * 60} 
    G1 X220.000 E0.31181 F{outer_wall_volumetric_speed/(0.3*0.5)/ 4 * 60} 
    G1 X225.000 E0.31181 F{outer_wall_volumetric_speed/(0.3*0.5)    * 60} 
    M973 S4 

M623

;========turn off light and wait extrude temperature =============
M1002 gcode_claim_action : 0
M973 S4 ; turn off scanner
M400 ; wait all motion done before implement the emprical L parameters
;M900 L500.0 ; Empirical parameters
M109 S[nozzle_temperature_initial_layer]
M960 S1 P0 ; turn off laser
M960 S2 P0 ; turn off laser
M106 S0 ; turn off fan
M106 P2 S0 ; turn off big fan 
M106 P3 S0 ; turn off chamber fan

M975 S1 ; turn on mech mode supression
G90 
M83
T1000
G1 X128.0 Y253.0 Z0.2 F6000.0;Move to start position
M109 S{nozzle_temperature_initial_layer[initial_extruder]}
G0 X253 E6.4 F{outer_wall_volumetric_speed/(0.3*0.6)    * 60} 
G0 Y128 E6.4
G0 X252.5
G0 Y252.5 E6.4
G0 X128 E6.4