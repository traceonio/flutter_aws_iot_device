import 'dart:io';

import 'package:aws_iot_device/aws_iot_device.dart';

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

  var device = AWSIoTDevice(region, accessKey, secretAccessKey, sessionToken, host);

  try {
    await device.connect(deviceId);
  } on Exception catch (e) {
    print('Failed to connect, status is ${device.connectionStatus}');
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
