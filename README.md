# Kraken API
[![Pub](https://img.shields.io/pub/v/kraken_api.svg)](https://pub.dev/packages/kraken_api)
![CI](https://github.com/Dimibe/kraken_api/workflows/CI/badge.svg?branch=master)

Dart Library for the Kraken API. (https://www.kraken.com/features/api).

## Getting Started

 Add the package to your pubspec.yaml:

 ```yaml
 kraken_api: ^1.0.2
 ```
 
 In your dart file, import the library:

 ```Dart
import 'package:kraken_api/kraken_api.dart';
 ``` 

 ## Usage

First create an `KrakenApi` instance:

 ```Dart
 KrakenApi api = KrakenApi('apiKey', 'secretKey');
 ```

 The constructor requires the API-Key and the Secret-Key which  should be both generated on the kraken website. 

 For accessing the kraken API use the `call` method.
 As the first parameter pass the method which should be called. A list of all available requests is added at the end. 
 Request parameters can be added to the request by the `parameters` parameter:

```Dart
Future<String> response = api.call(Methods.TRADE_BALANCE, parameters: {'asset': 'ZEUR'});
```

Hint: To see which parameters can be applied to which API calls take a look at the [Kraken API](https://www.kraken.com/features/api).

The `call` method returns the response body as an `Future<String>` which can be accessed through e.g.: 
```Dart
response.then(
    (body) {
        Map<String, dynamic> tradeBalances = jsonDecode(body)['result'];
        return tradeBalances;
    },
);
 ```

 ## API

 Public methods:

```Dart
Methods.TIME 
Methods.ASSETS
Methods.ASSET_PAIRS 
Methods.TICKER 
Methods.OHLC 
Methods.DEPTH 
Methods.TRADES
Methods.SPREAD 
```

Private methods:

```Dart
Methods.BALANCE
Methods.TRADE_BALANCE
Methods.OPEN_ORDERS 
Methods.CLOSED_ORDERS 
Methods.QUERY_ORDERS
Methods.TRADES_HISTORY 
Methods.QUERY_TRADES 
Methods.OPEN_POSITIONS 
Methods.LEDGERS 
Methods.QUERY_LEDGERS
Methods.TRADE_VOLUME 
Methods.ADD_EXPORT
Methods.EXPORT_STATUS 
Methods.RETRIEVE_EXPORT 
Methods.REMOVE_EXPORT 
Methods.ADD_ORDER
Methods.CANCEL_ORDER 
```

