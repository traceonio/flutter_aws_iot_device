library aws_iot_device;

import 'dart:async';

import 'package:amazon_cognito_identity_dart/sig_v4.dart';
import 'package:aws_iot_device/src/socket_connection.dart';
import 'package:tuple/tuple.dart';
import 'package:mqtt/mqtt_shared.dart';

enum QOS {
	level0,
	level1,
	level2,
	level3,
}

class AWSIoTDevice<E extends SocketConnection> {
	final _SERVICE_NAME = 'iotdevicegateway';
	final _AWS4_REQUEST = 'aws4_request';
	final _AWS4_HMAC_SHA256 = 'AWS4-HMAC-SHA256';
	final _SCHEME = 'wss://';

	E _connection;
	String _region;
	String _accessKeyId;
	String _secretAccessKey;
	String _sessionToken;
	String _host;
	bool _logging;

	var _onDisconnected;

	Map<String, int> _topics = Map<String, int>();


	MqttClient _client;

	StreamController<Tuple2<String, String>> _messagesController =
	StreamController<Tuple2<String, String>>();

	Stream<Tuple2<String, String>> get messages => _messagesController.stream;

	AWSIoTDevice(
		this._region,
		this._accessKeyId,
		this._secretAccessKey,
		this._sessionToken,
		String host,
		{
			E connection,
			bool logging = false,
			var onDisconnected = null,
		}) {

		_connection = connection;
		_logging = logging;
		_onDisconnected = onDisconnected;

		if (host.contains('amazonaws.com')) {
			_host = host.split('.').first;
		} else {
			_host = host;
		}
	}

	Future<Null> connect(String clientId) async {
		if (_client == null) {
			_prepare(clientId);
		}

		try {
			await _client.connect(_handleDisconnected);
		} on Exception catch (e) {
			_client.disconnect();
			throw e;
		}
	}

	_handleDisconnected() {
		if (_onDisconnected != null) {
			_onDisconnected();
		}
	}

	_prepare(String clientId) {
		final url = _prepareWebSocketUrl();
		;
		_client = MqttClient(_connection.getConnection(url), clientID: clientId, qos: QOS_0);
		_client.debugMessage = _logging;
	}

	_prepareWebSocketUrl() {
		if (_region == null) {
			throw new Exception('Invalid region');
		}

		if (_accessKeyId == null) {
			throw new Exception('Invalid accessKeyId');
		}

		if (_secretAccessKey == null) {
			throw new Exception('Invalid secretAccessKey');
		}

		if (_sessionToken == null) {
			throw new Exception('Invalid sessionToken');
		}

		if (_host == null) {
			throw new Exception('Invalid host');
		}

		final sigv4 = SigV4();
		final now = _generateDatetime(); //'20190103T172404Z'; //
		final hostname = _buildHostname();

		final List creds = [
			this._accessKeyId,
			_getDate(now),
			this._region,
			this._SERVICE_NAME,
			this._AWS4_REQUEST,
		];

		const payload = '';

		const path = '/mqtt';

		final queryParams = Map<String, String>.from({
			'X-Amz-Algorithm': _AWS4_HMAC_SHA256,
			'X-Amz-Credential': creds.join('/'),
			'X-Amz-Date': now,
			'X-Amz-SignedHeaders': 'host',
		});

		final canonicalQueryString = sigv4.buildCanonicalQueryString(queryParams);
		final request = sigv4.buildCanonicalRequest(
			'GET',
			path,
			queryParams,
			Map.from({
				'host': hostname,
			}),
			payload);

		final hashedCanonicalRequest = sigv4.hashCanonicalRequest(request);
		final stringToSign = sigv4.buildStringToSign(
			now,
			sigv4.buildCredentialScope(now, _region, _SERVICE_NAME),
			hashedCanonicalRequest);

		final signingKey = sigv4.calculateSigningKey(
			_secretAccessKey, now, _region, _SERVICE_NAME);

		final signature = sigv4.calculateSignature(signingKey, stringToSign);

		final finalParams =
			'${canonicalQueryString}&X-Amz-Signature=${signature}&X-Amz-Security-Token=${Uri.encodeComponent(_sessionToken)}';

		return '${_SCHEME}${hostname}${path}?${finalParams}';
	}

	String _generateDatetime() {
		return new DateTime.now()
			.toUtc()
			.toString()
			.replaceAll(new RegExp(r'\.\d*Z$'), 'Z')
			.replaceAll(new RegExp(r'[:-]|\.\d{3}'), '')
			.split(' ')
			.join('T');
	}

	String _getDate(String dateTime) {
		return dateTime.substring(0, 8);
	}

	String _buildHostname() {
		return '${_host}.iot.${_region}.amazonaws.com';
	}

	Future publishMessage(String topic, String payload) {
		return _client.publish(topic, payload);
	}

	void disconnect() {
		return _client.disconnect();
	}

	Future subscribe(String topic, [QOS qosLevel = QOS.level1]) async {
		final result = await _client?.subscribe(topic, _translateQOS(qosLevel), _onMessage);
		_topics[topic] = result.messageID;
		return result;
	}

	unsubscribe(String topic) {
		if (!_topics.containsKey(topic)) {
			return;
		}
		final messageId = _topics[topic];
		_client?.unsubscribe(topic, messageId);
	}

	_onMessage(String topic, data) {
		_messagesController.add(Tuple2<String, String>(topic, data));
	}

	int _translateQOS(QOS qos) {
		switch(qos) {
			case QOS.level0:
				return QOS_0;
			case QOS.level1:
				return QOS_1;
			case QOS.level2:
				return QOS_2;
			case QOS.level3:
				return QOS_ALL;
			default:
				throw new Exception('Invalid QOS type');

		}
	}
}
