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

  /// Constructs a KrakenApi object with given api key and secret key.
  KrakenApi(this.apiKey, this.secretKey);

  /// creates and executes a request to the kraken api.
  /// Returns the api call result.
  Future<String> call(Methods method, {Map<String, String> parameters}) {
    if (method._private) {
      String nonce = _generateNonce();
      return callPrivate(method.toString(), nonce, parameters: parameters);
    }
    return callPublic(method.toString(), parameters: parameters);
  }

  // Creates and executes a public market data request
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

  /// Creates and executes a private user request
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
    return Uri.encodeFull(postData);
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
    Hmac hmacSha512 = Hmac(sha512, key);
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

  /// Get server time
  /// Result: Server's time
  static const TIME = Methods._internal('Time');

  /// Get asset info
  /// Result: array of asset names and their info
  static const ASSETS = Methods._internal('Assets');

  /// Get tradable asset pairs
  /// Result: array of pair names and their info
  static const ASSET_PAIRS = Methods._internal('AssetPairs');

  /// Get ticker information
  /// Result: array of pair names and their ticker info
  static const TICKER = Methods._internal('Ticker');

  /// Get OHLC data
  /// Result: array of pair name and OHLC data
  static const OHLC = Methods._internal('OHLC');

  /// Get order book
  /// Result: array of pair name and market depth
  static const DEPTH = Methods._internal('Depth');

  /// Get recent trades
  /// Result: array of pair name and recent trade data
  static const TRADES = Methods._internal('Trades');

  /// Get recent spread data
  /// Result: array of pair name and recent spread data
  static const SPREAD = Methods._internal('Spread');

  /// Get account balance
  /// Result: array of asset names and balance amount
  static const BALANCE = Methods._internal('Balance', true);

  /// Get trade balance
  /// Result: array of trade balance info
  static const TRADE_BALANCE = Methods._internal('TradeBalance', true);

  /// Get open orders
  /// Result: array of order info in open array with txid as the key
  static const OPEN_ORDERS = Methods._internal('OpenOrders', true);

  /// Get closed orders
  /// Result: array of order info
  static const CLOSED_ORDERS = Methods._internal('ClosedOrders', true);

  /// Query orders info
  /// Result: associative array of orders info
  static const QUERY_ORDERS = Methods._internal('QueryOrders', true);

  /// Get trades history
  /// Result: array of trade info
  static const TRADES_HISTORY = Methods._internal('TradesHistory', true);

  /// Query trades info
  /// Result: associative array of trades info
  static const QUERY_TRADES = Methods._internal('QueryTrades', true);

  /// Get open positions
  /// Result: associative array of open position info
  static const OPEN_POSITIONS = Methods._internal('OpenPositions', true);

  /// Get ledgers info
  /// Result: associative array of ledgers info
  static const LEDGERS = Methods._internal('Ledgers', true);

  /// Query ledgers
  /// Result: associative array of ledgers info
  static const QUERY_LEDGERS = Methods._internal('QueryLedgers', true);

  /// Get trade volume
  /// Result: associative array
  static const TRADE_VOLUME = Methods._internal('TradeVolume', true);

  /// Request export report
  /// Result: report id
  static const ADD_EXPORT = Methods._internal('AddExport', true);

  /// Get export states
  /// Result: array of reports and their info
  static const EXPORT_STATUS = Methods._internal('ExportStatus', true);

  /// Get export report
  /// Result: binary zip archive containing the report
  static const RETRIEVE_EXPORT = Methods._internal('RetrieveExport', true);

  /// Remove export report
  /// Result: bool with result of call
  static const REMOVE_EXPORT = Methods._internal('RemoveExport', true);

  /// Add standard order
  /// Result:
  /// descr = order description info
  /// order = order description
  /// close = conditional close order description (if conditional close set)
  /// txid = array of transaction ids for order (if order was added successfully)
  static const ADD_ORDER = Methods._internal('AddOrder', true);

  /// Cancel open order
  /// Result:
  /// count = number of orders canceled
  /// pending = if set, order(s) is/are pending cancellation
  static const CANCEL_ORDER = Methods._internal('CancelOrder', true);
}
