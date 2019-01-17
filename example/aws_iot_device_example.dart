import 'dart:io';

import 'package:aws_iot_device/aws_iot_device.dart';
import 'package:aws_iot_device/io_websocket.dart';

main() async {
  const region = 'us-east-1';

  //These you will get from Cognito
  const accessKey = '';
  const secretAccessKey = '';
  const sessionToken = '';

  //This is your host. It's probably something like 'abcde191919-ats'
  const host = '';

  //This is the ID of the AWS IoT device
  const deviceId = '123-123-123-123';

  //Specify the type to choose a different socket type to use. HTML Websockets, Websockets and Sockets are supported
  var device = AWSIoTDevice(region, accessKey, secretAccessKey, sessionToken, host, connection: IOWebSocket());

  try {
    await device.connect(deviceId);
  } on Exception catch (e) {
    print('Failed to connect, status is ${device}');
    exit(-1);
  }

  device.messages.listen((message) {
    print('Received message on topic "${message.item1}", message is "${message.item2}"');
  });

  //The MQTT topic you want to subscribe to
  const topic = '';

  device.subscribe(topic);

  device.publishMessage(topic, 'Hi!');
}
