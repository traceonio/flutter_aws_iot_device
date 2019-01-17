library connection;

import 'package:mqtt/mqtt_shared.dart';

abstract class SocketConnection {
	VirtualMqttConnection getConnection(String url);
}
