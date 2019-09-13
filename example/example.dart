import 'dart:convert';

import 'package:kraken_api/kraken_api.dart';

void main() {
  var api = KrakenApi('apiKey', 'secretKey');
  Future<String> response =
      api.call(Methods.TRADE_BALANCE, parameters: {'asset': 'ZEUR'});

  response.then(
    (body) {
      Map<String, dynamic> tradeBalances = jsonDecode(body)['result'];
      return tradeBalances;
    },
  );
}
