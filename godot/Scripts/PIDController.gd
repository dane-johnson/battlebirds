extends Node

class_name PIDController

export(float) var setpoint

export(float) var p
export(float) var i
export(float) var d
export(float) var max_power = 10.0

var prev_error = 0
var integral = 0

func angle_difference(a, b):
	return atan2(sin(a - b), cos(a - b))

func update(measured_value, delta):
	var error = angle_difference(setpoint, measured_value)
	var proportional = error
	integral = 0
	integral = clamp(integral + error * delta, -TAU, TAU)
	var derivative = (error - prev_error) / delta
	prev_error = error
	return clamp(p * proportional + i * integral + d * derivative, -max_power, max_power)

## From wikipedia

#previous_error := 0
#integral := 0
#
#loop:
#    error := setpoint − measured_value
#    proportional := error;
#    integral := integral + error × dt
#    derivative := (error − previous_error) / dt
#    output := Kp × proportional + Ki × integral + Kd × derivative
#    previous_error := error
#    wait(dt)
#    goto loop
