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

  http.Client client = http.Client();

  KrakenApi(this.apiKey, this.secretKey);

  Future<String> call(Methods method, {Map<String, String> parameters}) {
    if (method._private) {
      String nonce = _generateNonce();
      return callPrivate(method.toString(), nonce, parameters: parameters);
    }
    return callPublic(method.toString(), parameters: parameters);
  }

  Future<String> callPublic(String path,
      {Map<String, String> parameters}) async {
    var url = '$URL$path';
    if (parameters != null) {
      url += '?';
      parameters.forEach((k, v) => url += '$k=$v&');
    }
    var response = await client.get(url);
    return response.body;
  }

  Future<String> callPrivate(String method, String nonce,
      {Map<String, String> parameters}) {
    String path = method.toString();

    String postData = _createPostData(nonce, parameters);
    String apiSign = _createApiSign(path, postData, nonce);

    return _doRequest(URL + path, apiKey, apiSign, postData);
  }

  String _generateNonce() {
    return '${DateTime.now().millisecondsSinceEpoch}000';
  }

  String _createPostData(String nonce, Map parameters) {
    String postData = 'nonce=$nonce&';
    parameters?.forEach((k, v) => postData += '$k=$v&');
    return postData;
  }

  String _createApiSign(String path, String postData, String nonce) {
    // create sha256
    String message = nonce + postData;
    List<int> bytes = utf8.encode(message);
    Digest data = sha256.convert(bytes);

    // create hmac
    List<int> key = base64.decode(secretKey);
    List<int> hmacInput = List();
    hmacInput.addAll(utf8.encode(path));
    hmacInput.addAll(data.bytes);
    Hmac hmacSha512 = new Hmac(sha512, key);
    Digest digest = hmacSha512.convert(hmacInput);

    return base64.encode(digest.bytes);
  }

  Future<String> _doRequest(
      String url, String apiKey, String apiSign, String postData) async {
    var response = await client.post(
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
  
  @override
  toString() => '/$API_VERSION/$_type/$_value';

  get _type {
    if (_private) return 'private';
    return 'public';
  }

  // Public methods
  static const TIME = const Methods._internal('Time');
  static const ASSETS = const Methods._internal('Assets');
  static const ASSET_PAIRS = const Methods._internal('AssetPairs');
  static const TICKER = const Methods._internal('Ticker');
  static const OHLC = const Methods._internal('OHLC');
  static const DEPTH = const Methods._internal('Depth');
  static const TRADES = const Methods._internal('Trades');
  static const SPREAD = const Methods._internal('Spread');

  // Private methods
  static const BALANCE = const Methods._internal('Balance', true);
  static const TRADE_BALANCE = const Methods._internal('TradeBalance', true);
  static const OPEN_ORDERS = const Methods._internal('OpenOrders', true);
  static const CLOSED_ORDERS = const Methods._internal('ClosedOrders', true);
  static const QUERY_ORDERS = const Methods._internal('QueryOrders', true);
  static const TRADES_HISTORY = const Methods._internal('TradesHistory', true);
  static const QUERY_TRADES = const Methods._internal('QueryTrades', true);
  static const OPEN_POSITIONS = const Methods._internal('OpenPositions', true);
  static const LEDGERS = const Methods._internal('Ledgers', true);
  static const QUERY_LEDGERS = const Methods._internal('QueryLedgers', true);
  static const TRADE_VOLUME = const Methods._internal('TradeVolume', true);
  static const ADD_EXPORT = const Methods._internal('AddExport', true);
  static const EXPORT_STATUS = const Methods._internal('ExportStatus', true);
  static const RETRIEVE_EXPORT =
      const Methods._internal('RetrieveExport', true);
  static const REMOVE_EXPORT = const Methods._internal('RemoveExport', true);
  static const ADD_ORDER = const Methods._internal('AddOrder', true);
  static const CANCEL_ORDER = const Methods._internal('CancelOrder', true);
}
