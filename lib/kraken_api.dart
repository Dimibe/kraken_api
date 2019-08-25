library kraken_api;

import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class KrakenApi {
  void makeKrakenRequest() async {
    String url = 'https://api.kraken.com';
    String path = '/0/private/Balance';
    String apiKey = 'j8t3C5EOojF8DLmcvRiNV5RIipmv5jZKgtBeJlqvLTQS2YX8mhI9qUBG';
    String secretKey =
        '1JIRjxSK5wIyusSijjiB36IYGBRfF+vpIWjWvBe/MiOfCiLvQiDPn3Iq4tE5xcLjdKVgPybUvhkeKqx/qYHzUw==';
    // generate nonce
    String _nonce = '${DateTime.now().millisecondsSinceEpoch}000';
    print('Nonce: ' + _nonce);
    //generate post data
    String postData = 'asset=ZEUR&nonce=$_nonce&';
    print('postData: $postData');
    //create sha-256
    String message = _nonce + postData;
    print('message: $message');
    List<int> bytes = utf8.encode(message);
    Digest data = sha256.convert(bytes);
    // set path
    List<int> pathBytes = utf8.encode(path);
    // decode secret key
    List<int> key = base64.decode(secretKey);
    //create hmac
    List<int> xx = List();
    xx.addAll(pathBytes);
    xx.addAll(data.bytes);
    Hmac hmacSha512 = new Hmac(sha512, key);
    Digest digest = hmacSha512.convert(xx);

    String apiSign = base64.encode(digest.bytes);
    print('API-Sign: $apiSign');

    _sendRequest(url + path, apiKey, apiSign, postData);
  }

  void _sendRequest(
      String url, String apiKey, String apiSign, String postData) async {
    var response = await http.post(
      url,
      encoding: Encoding.getByName('utf-8'),
      headers: {
        HttpHeaders.contentTypeHeader:
            'application/x-www-form-urlencoded;charset=utf-8',
        HttpHeaders.userAgentHeader: 'dart_test',
        HttpHeaders.connectionHeader: 'keep-alive',
        HttpHeaders.cacheControlHeader: 'no-cache',
        HttpHeaders.acceptHeader: '*/*',
        HttpHeaders.acceptCharsetHeader: 'utf-8',
        'API-Key': apiKey,
        'API-Sign': apiSign,
      },
      body: postData,
    );
    print('Response Status: ${response.statusCode}');
    print('Response Body: ${response.body}');
  }
}
