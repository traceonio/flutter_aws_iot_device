library io_socket;

import 'package:aws_iot_device/src/socket_connection.dart';
import 'package:mqtt/mqtt_connection_io_socket.dart';
import 'package:mqtt/mqtt_shared.dart';

class IOSocket extends SocketConnection {
	@override
	VirtualMqttConnection getConnection(String url) {
		return MqttConnectionIOSocket.setOptions(host: url, port: 443);
	}
}
