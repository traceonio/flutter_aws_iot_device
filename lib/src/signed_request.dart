library signed_request;

import 'package:amazon_cognito_identity_dart/cognito.dart';
import 'package:amazon_cognito_identity_dart/sig_v4.dart';

getSignedRequest(
	CognitoCredentials credentials,
	String region,
	String endpoint,
	String path,
	{
		String method = 'GET',
		Map headers,
		Map<String, String> queryParams,
		String body = null,
	}) {
	return getSignedRequestWithStrings(
		credentials.accessKeyId, credentials.secretAccessKey,
		credentials.sessionToken, region, endpoint, path, method: method,
		headers: headers,
		queryParams: queryParams,
		body: body);
}

getSignedRequestWithStrings(
	String accessKeyId,
	String secretAccessKey,
	String sessionToken,
	String region,
	String endpoint,
	String path,
	{
		String method = 'GET',
		Map headers,
		Map<String, String> queryParams,
		String body = null,
	}) {
	final awsSigV4Client = AwsSigV4Client(
		accessKeyId,
		secretAccessKey,
		endpoint,
		sessionToken: sessionToken,
		region: region,
	);

	return SigV4Request(awsSigV4Client,
		method: method,
		path: path,
		headers: headers != null ? headers : Map(),
		queryParams: queryParams != null ? queryParams : Map(),
		body: body,
	);
}
