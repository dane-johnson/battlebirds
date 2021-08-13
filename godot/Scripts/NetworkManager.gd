extends Node

const SERVER_PORT = 8008
const MAX_PLAYERS = 4

const player_prefab = preload("res://Player/Player.tscn")

var peer
var server = false
var id
var local_player

func _ready():
	## Hook up network signals
	get_tree().connect("network_peer_connected", self, "init_remote_player")
	
func is_local(node):
	return node.is_network_master()

func init_remote_player(peer_id):
	var remote_player = player_prefab.instance()
	setup_player(remote_player, peer_id, false)
	## Give the remote player control of their player objects
	## (Maybe not a great idea, fix this if I ever become famous)
	remote_player.set_network_master(peer_id)
	add_child(remote_player)

func init_local_player():
	local_player = player_prefab.instance()
	setup_player(local_player, id, true)
	local_player.set_network_master(id)
	add_child(local_player)

func host_game():
	peer = NetworkedMultiplayerENet.new()
	peer.create_server(SERVER_PORT, MAX_PLAYERS)
	get_tree().network_peer = peer
	server = true
	id = peer.get_unique_id() ## This should be 1 unless godot changes it
	init_local_player()

func join_game(ip):
	peer = NetworkedMultiplayerENet.new()
	peer.create_client(ip, SERVER_PORT)
	get_tree().network_peer = peer
	server = false
	## Id is arbitrary large number negotiated with server
	id = peer.get_unique_id()
	init_local_player()
	
static func setup_player(player, peer_id, local):
	player.set_name("Player-" + str(peer_id)) ## Must use naming convention for network sync
	player.local = local
