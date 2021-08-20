extends Node

export(bool) var host

func _ready():
	if host:
		NetworkManager.host_game()
	else:
		NetworkManager.join_game("localhost")
	LevelSelector.load("Demo")
