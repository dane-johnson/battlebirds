extends Control

func _ready():
	$HostButton.connect("pressed", self, "host_game")
	$JoinButton.connect("pressed", self, "join_game")

func host_game():
	NetworkManager.host_game()
	LevelSelector.load("Demo")
	hide()

func join_game():
	pass
