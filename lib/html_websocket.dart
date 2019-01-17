library html_websocket;

import 'package:aws_iot_device/src/socket_connection.dart';
import 'package:mqtt/mqtt_connection_html_websocket.dart';
import 'package:mqtt/mqtt_shared.dart';

class HTMLWebSocket extends SocketConnection {
	@override
	VirtualMqttConnection getConnection(String url) {
		return MqttConnectionHtmlWebSocket.setOptions(url, 'mqttv3.1');
	}
}
