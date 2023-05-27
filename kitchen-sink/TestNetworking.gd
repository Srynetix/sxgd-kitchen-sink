extends Control

const SERVER_PORT := 54329

var logger := SxLog.get_logger("TestNetworking")

@onready var _start_server_btn := %StartServer as Button
@onready var _start_listen_server_btn := %StartListenServer as Button
@onready var _start_client_btn := %StartClient as Button
@onready var _status_lbl := %Status as Label

var _listen_server: SxListenServerPeer
var _server: SxServerPeer
var _client: SxClientPeer

func _start_server() -> void:
    _server = SxServerPeer.new()
    _server.server_port = SERVER_PORT
    _server.max_players = 2
    _server.rpc_service = MainRpcService
    add_child(_server)

    _server.players_updated.connect(_on_server_players_updated)

    _start_server_btn.disabled = true
    _start_listen_server_btn.disabled = true
    _start_client_btn.disabled = true

func _start_client() -> void:
    _client = SxClientPeer.new()
    _client.server_port = SERVER_PORT
    _client.server_address = "127.0.0.1"
    add_child(_client)

    _client.connected_to_server.connect(_on_client_connected)
    _client.connection_failed.connect(_on_connection_failed)

    _start_client_btn.disabled = true

    _status_lbl.text = "Client connecting..."

func _exit_tree() -> void:
    if _server:
        _server.set_quit_status(true)

func _on_server_players_updated(players: Dictionary) -> void:
    logger.info("Players updated %s" % players)

func _on_client_connected() -> void:
    _status_lbl.text = "Client connected to server"

func _on_connection_failed() -> void:
    _status_lbl.text = "Client connection failed"

    _client.queue_free()
    _start_client_btn.disabled = false

func _start_listen_server() -> void:
    _listen_server = SxListenServerPeer.new()
    _listen_server.server_port = SERVER_PORT
    _listen_server.max_players = 2
    add_child(_listen_server)

    _server = _listen_server.get_server()
    _server.players_updated.connect(_on_server_players_updated)

    _start_server_btn.disabled = true
    _start_listen_server_btn.disabled = true

    _status_lbl.text = "Server is ready"

func _show_logs():
    GameDebugTools.show_tools()
    GameDebugTools.show_specific_panel(GameDebugTools.PanelType.LOG)
