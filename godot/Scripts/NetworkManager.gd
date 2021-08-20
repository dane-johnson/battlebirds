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
	get_tree().connect("network_peer_disconnected", self, "delete_remote_player")
	get_tree().connect("server_disconnected", self, "shutdown_game")
	
func is_local(node):
	return node.is_network_master()

func init_remote_player(peer_id):
	var remote_player = player_prefab.instance()
	setup_player(remote_player, peer_id, false)
	## Give the remote player control of their player objects
	## (Maybe not a great idea, fix this if I ever become famous)
	remote_player.set_network_master(peer_id)
	PlayerManager.add_child(remote_player)
	rpc_id(peer_id, "sync_player", local_player.name, local_player.mode)

remote func sync_player(name, mode):
	var remote_player = PlayerManager.get_player_by_name(name)
	if mode == remote_player.SOLDIER:
		remote_player.spawn()

func delete_remote_player(peer_id):
	var remote_player = get_node("Player-" + (str(peer_id)))
	remove_child(remote_player)
	remote_player.queue_free()

func init_local_player():
	local_player = player_prefab.instance()
	setup_player(local_player, id, true)
	local_player.set_network_master(id)
	PlayerManager.add_child(local_player)

func host_game():
	peer = NetworkedMultiplayerENet.new()
	peer.create_server(SERVER_PORT, MAX_PLAYERS)
	get_tree().network_peer = peer
	server = true
	id = peer.get_unique_id() ## This should be 1 unless Godot changes it
	init_local_player()

func join_game(ip):
	peer = NetworkedMultiplayerENet.new()
	peer.create_client(ip, SERVER_PORT)
	get_tree().network_peer = peer
	server = false
	## Id is arbitrary large number negotiated with server
	id = peer.get_unique_id()
	init_local_player()

func shutdown_game():
	get_tree().quit()
	
static func setup_player(player, peer_id, local):
	player.set_name("Player-" + str(peer_id)) ## Must use naming convention for network sync
