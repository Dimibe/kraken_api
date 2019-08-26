library kraken_api;

import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

const String URL = 'https://api.kraken.com';
const API_VERSION = '0';

class KrakenApi {
  final String apiKey;
  final String secretKey;

  KrakenApi(this.apiKey, this.secretKey);

  Future<String> call(Methods method, {Map<String, String> parameters}) {
    if (method._private) {
      return _privateRequest(method, parameters: parameters);
    }
    return _publicRequest(method, parameters: parameters);
  }

  Future<String> _publicRequest(Methods method,
      {Map<String, String> parameters}) async {
    String path = method.toString();
    var url = '$URL$path';
    if (parameters != null) {
      url += '?';
      parameters.forEach((k, v) => url += '$k=$v&');
    }
    print(url);
    var response = await http.get(url);
    return response.body;
  }

  Future<String> _privateRequest(Methods method,
      {Map<String, String> parameters}) {
    String path = method.toString();
    String _nonce = '${DateTime.now().millisecondsSinceEpoch}000';
    String postData = 'nonce=$_nonce&';
    parameters?.forEach((k, v) => postData += '$k=$v&');

    // create sha256
    String message = _nonce + postData;
    List<int> bytes = utf8.encode(message);
    Digest data = sha256.convert(bytes);

    List<int> key = base64.decode(secretKey);
    List<int> hmacInput = List();
    hmacInput.addAll(utf8.encode(path));
    hmacInput.addAll(data.bytes);

    // create hmac
    Hmac hmacSha512 = new Hmac(sha512, key);
    Digest digest = hmacSha512.convert(hmacInput);

    String apiSign = base64.encode(digest.bytes);
    return _doRequest(URL + path, apiKey, apiSign, postData);
  }

  Future<String> _doRequest(
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
    return response.body;
  }
}

class Methods {
  final String _value;
  final bool _private;
  const Methods._internal(this._value, [this._private = false]);
  toString() => '/$API_VERSION/$_type/$_value';

  get _type {
    if (_private) return 'private';
    return 'public';
  }

  // Public
  static const TIME = const Methods._internal('Time');
  static const ASSETS = const Methods._internal('Assets');
  static const ASSET_PAIRS = const Methods._internal('AssetPairs');
  static const TICKER = const Methods._internal('Ticker');
  static const OHLC = const Methods._internal('OHLC');
  static const DEPTH = const Methods._internal('Depth');
  static const TRADES = const Methods._internal('Trades');
  static const SPREAD = const Methods._internal('Spread');

  // Private
  static const BALANCE = const Methods._internal('Balance', true);
  static const TRADE_BALANCE = const Methods._internal('TradeBalance', true);
  static const OPEN_ORDERS = const Methods._internal('OpenOrders', true);
  static const CLOSED_ORDERS = const Methods._internal('ClosedOrders', true);
}
