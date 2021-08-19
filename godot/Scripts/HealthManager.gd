extends Node

signal hurt
signal dead

export(int) var max_health = 100

onready var current_health = max_health

func is_dead():
	return current_health <= 0

remotesync func hurt(dmg):
	if is_dead(): return
	emit_signal("hurt", dmg)
	if current_health - dmg <= 0:
		current_health = 0
		emit_signal("dead")
	else:
		current_health -= dmg

func revive():
	current_health = max_health
