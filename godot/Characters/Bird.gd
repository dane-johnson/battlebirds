extends Spatial


func takeoff():
	$AnimationPlayer.play("ActivateThrusters")
	$AnimationPlayer.play_backwards("FanOpen")
	
func land():
	$AnimationPlayer.play_backwards("ActivateThrusters")
	$AnimationPlayer.play("FanOpen")
