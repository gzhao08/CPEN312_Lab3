#============================================================
# DE1-SoC pin assignments for clock_control
# (Based on known-working lab2_top_pins.tcl)
#============================================================

# -----------------------
# 50 MHz Clock
# -----------------------
set_location_assignment PIN_AF14 -to default_clk

# -----------------------
# Switches
# -----------------------
set_location_assignment PIN_AC12 -to time_alarm_mode   ;# SW1
set_location_assignment PIN_AB12 -to show_change_mode  ;# SW0
set_location_assignment PIN_AF9  -to set               ;# SW2 (using same bank group as working file)
set_location_assignment PIN_AE12 -to alarm_en          ;# SW9

# -----------------------
# Pushbuttons (active LOW)
# -----------------------
set_location_assignment PIN_AA14 -to dec_digit         ;# KEY0
set_location_assignment PIN_AA15 -to inc_digit         ;# KEY1

# -----------------------
# LEDs
# -----------------------
set_location_assignment PIN_V16 -to alarm_triggered    ;# LEDR0
set_location_assignment PIN_Y21 -to AMPM_out           ;# LEDR9

# -----------------------
# HEX Displays
# -----------------------

# sec_out0 -> HEX0
set_location_assignment PIN_AE26 -to {sec_out0[0]}
set_location_assignment PIN_AE27 -to {sec_out0[1]}
set_location_assignment PIN_AE28 -to {sec_out0[2]}
set_location_assignment PIN_AG27 -to {sec_out0[3]}
set_location_assignment PIN_AF28 -to {sec_out0[4]}
set_location_assignment PIN_AG28 -to {sec_out0[5]}
set_location_assignment PIN_AH28 -to {sec_out0[6]}

# sec_out1 -> HEX1
set_location_assignment PIN_AJ29 -to {sec_out1[0]}
set_location_assignment PIN_AH29 -to {sec_out1[1]}
set_location_assignment PIN_AH30 -to {sec_out1[2]}
set_location_assignment PIN_AG30 -to {sec_out1[3]}
set_location_assignment PIN_AF29 -to {sec_out1[4]}
set_location_assignment PIN_AF30 -to {sec_out1[5]}
set_location_assignment PIN_AD27 -to {sec_out1[6]}

# min_out0 -> HEX2
set_location_assignment PIN_AB23 -to {min_out0[0]}
set_location_assignment PIN_AE29 -to {min_out0[1]}
set_location_assignment PIN_AD29 -to {min_out0[2]}
set_location_assignment PIN_AC28 -to {min_out0[3]}
set_location_assignment PIN_AD30 -to {min_out0[4]}
set_location_assignment PIN_AC29 -to {min_out0[5]}
set_location_assignment PIN_AC30 -to {min_out0[6]}

# min_out1 -> HEX3
set_location_assignment PIN_AD26 -to {min_out1[0]}
set_location_assignment PIN_AC27 -to {min_out1[1]}
set_location_assignment PIN_AD25 -to {min_out1[2]}
set_location_assignment PIN_AC25 -to {min_out1[3]}
set_location_assignment PIN_AB28 -to {min_out1[4]}
set_location_assignment PIN_AB25 -to {min_out1[5]}
set_location_assignment PIN_AB22 -to {min_out1[6]}

# hr_out0 -> HEX4
set_location_assignment PIN_AA24 -to {hr_out0[0]}
set_location_assignment PIN_Y23  -to {hr_out0[1]}
set_location_assignment PIN_Y24  -to {hr_out0[2]}
set_location_assignment PIN_W22  -to {hr_out0[3]}
set_location_assignment PIN_W24  -to {hr_out0[4]}
set_location_assignment PIN_V23  -to {hr_out0[5]}
set_location_assignment PIN_W25  -to {hr_out0[6]}

# hr_out1 -> HEX5
set_location_assignment PIN_V25  -to {hr_out1[0]}
set_location_assignment PIN_AA28 -to {hr_out1[1]}
set_location_assignment PIN_Y27  -to {hr_out1[2]}
set_location_assignment PIN_AB27 -to {hr_out1[3]}
set_location_assignment PIN_AB26 -to {hr_out1[4]}
set_location_assignment PIN_AA26 -to {hr_out1[5]}
set_location_assignment PIN_AA25 -to {hr_out1[6]}

# 1Hz Clock
set_location_assignment PIN_W16 -to clk_1Hz_out

# set unused LEDs to 0
set_location_assignment PIN_V17 -to {unused_leds[0]}   ;# LEDR2
set_location_assignment PIN_V18 -to {unused_leds[1]}   ;# LEDR3
set_location_assignment PIN_W17 -to {unused_leds[2]}   ;# LEDR4
set_location_assignment PIN_W19 -to {unused_leds[3]}   ;# LEDR5
set_location_assignment PIN_Y19 -to {unused_leds[4]}   ;# LEDR6
set_location_assignment PIN_W20 -to {unused_leds[5]}   ;# LEDR7
set_location_assignment PIN_W21 -to {unused_leds[6]}   ;# LEDR8

# -----------------------
# IO Standard
# -----------------------
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to *