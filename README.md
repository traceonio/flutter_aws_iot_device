A simple wrapper around [MQTT](https://pub.dartlang.org/packages/mqtt_client) to talk to the AWS IoT backend.

## Usage

First you'll need to get Cognito credentials. We're using the Websocket way to talk to AWS and it needs the access key, secret key and session token.

You can use the [amazon_cognito_identity_dart](https://pub.dartlang.org/packages/amazon_cognito_identity_dart) library to get Cognito credentials.

```dart
import 'package:aws_iot_device/aws_iot_device.dart';
main() async {
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
```

What about private keys and the like? Well, using Cognito credentials means you don't need that stuff.
