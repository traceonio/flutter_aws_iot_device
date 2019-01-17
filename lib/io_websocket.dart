library io_websocket;

import 'package:aws_iot_device/src/socket_connection.dart';
import 'package:mqtt/mqtt_connection_io_websocket.dart';
import 'package:mqtt/mqtt_shared.dart';

class IOWebSocket extends SocketConnection {
	@override
	VirtualMqttConnection getConnection(String url) {
		return MqttConnectionIOWebSocket.setOptions(url);
	}
}
