extends Control

enum ClientMessageKind {
    UpdateUsers,
    SendChatMessage
}

enum ServerMessageKind {
    SendChatMessage
}

class ChatServer:
    extends SxNetServerHandler

    signal users_updated(users: Dictionary)

    var _logger: SxLog.Logger
    var _users: Dictionary = {}  # int -> String

    func _init(peer_: SxNetServerPeer) -> void:
        super._init(peer_)
        name = "ChatServer"
        _logger = SxLog.get_logger("ChatServer")

    func _ready() -> void:
        super._ready()
        _logger.info("ChatServer spawned at %s", [get_path()])

    func _update_user_list() -> void:
        users_updated.emit(_users)
        protocol.send_to_all_clients(
            ClientMessageKind.UpdateUsers, _users
        )

    func _send_server_message_to_all(message: Variant) -> void:
        protocol.send_to_all_clients(
            ClientMessageKind.SendChatMessage,
            {"source": "server", "message": message}
        )

    func _send_server_message_to_client(peer_id: int, message: Variant) -> void:
        protocol.send_to_client(
            peer_id,
            ClientMessageKind.SendChatMessage,
            {"source": "server", "message": message}
        )

    func _send_client_message_to_all(peer_id: int, message: Variant) -> void:
        protocol.send_to_all_clients(
            ClientMessageKind.SendChatMessage,
            {"source": "client", "message": message, "peer_id": peer_id}
        )

    func _peer_connected(id: int) -> void:
        # Set a default username
        _users[id] = "Unknown"

        _update_user_list()
        _send_server_message_to_all("User %s entered the chat" % _users[id])

    func _peer_disconnected(id: int) -> void:
        var username = _users[id]
        _users.erase(id)

        _update_user_list()
        _send_server_message_to_all("User %s left the chat" % username)

    func _handle_command_message(peer_id: int, message: String) -> void:
        var message_split := message.split(" ", true, 1)  # Only split the first space
        var command := message_split[0]

        if command == "username":
            if len(message_split) == 1:
                _send_server_message_to_client(peer_id, "Missing argument to /username command.")
                return

            var remaining := message_split[1]
            var prev_username := _users[peer_id] as String
            _users[peer_id] = remaining
            _logger.info("Peer #%d updated its username to %s", [peer_id, remaining])

            _update_user_list()
            _send_server_message_to_all("User %s changed its username to %s" % [prev_username, remaining])

        else:
            _send_server_message_to_client(peer_id, "Unknown command /%s." % [command])

    func _on_message(peer_id: int, kind: Variant, payload: Variant) -> void:
        if kind == ServerMessageKind.SendChatMessage:
            var message := payload["message"] as String
            if message[0] == "/":
                _handle_command_message(peer_id, message.substr(1))
            else:
                _send_client_message_to_all(peer_id, message)


class ChatClient:
    extends SxNetClientHandler

    signal users_updated(users: Dictionary)
    signal message_received(message: Dictionary)

    var _users: Dictionary = {}
    var _logger: SxLog.Logger

    func _init(peer_: SxNetClientPeer) -> void:
        super._init(peer_)

        name = "ChatClient"
        _logger = SxLog.get_logger("ChatClient")

    func _ready() -> void:
        super._ready()
        _logger.info("ChatClient spawned at %s", [get_path()])

    func _on_message(kind: Variant, payload: Variant) -> void:
        if kind == ClientMessageKind.UpdateUsers:
            _users = payload
            users_updated.emit(_users)

        elif kind == ClientMessageKind.SendChatMessage:
            message_received.emit(payload)


@onready var _connect_panel := %ConnectPanel as Panel

@onready var _server_panel := %ServerPanel as Panel
@onready var _server_port_input := %ServerPortInput as LineEdit
@onready var _server_max_players_input := %ServerMaxPlayersInput as LineEdit
@onready var _server_host_button := %ServerHostButton as Button
@onready var _server_connected_clients_tree := %ServerConnectedClientsTree as Tree
@onready var _server_use_websockets_input := %ServerUseWebsocketsInput as CheckBox

@onready var _client_panel := %ClientPanel as Panel
@onready var _client_server_address_input := %ClientServerAddressInput as LineEdit
@onready var _client_join_button := %ClientJoinButton as Button
@onready var _client_chat_content := %ClientChatContent as RichTextLabel
@onready var _client_chat_edit := %ClientChatEdit as LineEdit
@onready var _client_connected_clients_tree := %ClientConnectedClientsTree as Tree
@onready var _client_use_websockets_input := %ClientUseWebsocketsInput as CheckBox


func _ready() -> void:
    _server_host_button.pressed.connect(func(): _spawn_server())
    _client_join_button.pressed.connect(func(): _spawn_client())

    _client_chat_edit.editable = false

    _server_panel.visible = false
    _client_panel.visible = false

    if OS.get_name() == "Web":
        _server_port_input.editable = false
        _server_max_players_input.editable = false
        _server_host_button.disabled = true
        _server_use_websockets_input.disabled = true

func _spawn_server() -> void:
    var port := int(_server_port_input.text)
    var max_players := int(_server_max_players_input.text)

    var server := SxNetServerPeer.new()
    server.started.connect(func():
        var chat_server := ChatServer.new(server)
        chat_server.users_updated.connect(func(users):
            _server_connected_clients_tree.clear()
            _server_connected_clients_tree.hide_root = true
            var root := _server_connected_clients_tree.create_item()

            for user_key in users:
                var user := users[user_key] as String
                var item := _server_connected_clients_tree.create_item(root)
                item.set_text(0, user)
        )

        server.add_child(chat_server)
    )
    server.port = port
    server.max_clients = max_players
    server.use_websockets = _server_use_websockets_input.button_pressed
    add_child(server)

    _server_port_input.editable = false
    _server_max_players_input.editable = false
    _server_host_button.disabled = true

    _server_panel.visible = true

func _spawn_client() -> void:
    var address_full := _client_server_address_input.text
    var address_parts := address_full.split(":")
    var ip_address = address_parts[0]
    var port = int(address_parts[1])

    var client := SxNetClientPeer.new()
    client.connected_to_server.connect(func():
        var protocol = client.protocol

        var chat_client := ChatClient.new(client)
        chat_client.users_updated.connect(func(users):
            _client_connected_clients_tree.clear()
            _client_connected_clients_tree.hide_root = true
            var root := _client_connected_clients_tree.create_item()

            for user_key in users:
                var user := users[user_key] as String
                var item := _client_connected_clients_tree.create_item(root)
                item.set_text(0, user)
        )

        chat_client.message_received.connect(func(message):
            var source := message["source"] as String
            var content := message["message"] as String
            if source == "client":
                var username = chat_client._users[message["peer_id"] as int] as String
                _client_chat_content.text += "[i]%s[/i]: %s\n" % [username, content]
            else:
                _client_chat_content.text += "[i]%s[/i]\n" % content
        )

        client.add_child(chat_client)

        _connect_panel.visible = false
        _client_chat_edit.editable = true
        _client_panel.visible = true

        _client_chat_edit.text_submitted.connect(func(message):
            protocol.send_to_server(ServerMessageKind.SendChatMessage, {"message": message})
            _client_chat_edit.text = ""
        )
    )

    client.connection_failed.connect(func():
        _client_server_address_input.editable = true
        _client_join_button.disabled = false
    )

    client.server_disconnected.connect(func():
        _connect_panel.visible = false
        _client_server_address_input.editable = true
        _client_join_button.disabled = false
    )

    client.server_address = ip_address
    client.server_port = port
    client.use_websockets = _client_use_websockets_input.button_pressed
    add_child(client)

    _client_server_address_input.editable = false
    _client_join_button.disabled = true
