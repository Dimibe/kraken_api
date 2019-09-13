# Kraken API

Dart Library for the kraken api (https://api.kraken.com/0).

## Getting Started

 Add the package to your pubspec.yaml:

 ```yaml
 kraken_api: ^1.0.0
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
 It's required to pass the method which should be called as the first parameter.
 Request parameters can be added to the request by the `parameters` parameter:

```Dart
  Future<String> response = api.call(Methods.TRADE_BALANCE, parameters: {'asset': 'ZEUR'});
```

Hint: To see which parameters can be applied to which API calls take a look at the [kraken api](https://www.kraken.com/features/api).

The `call` method returns the response body as an `Future<String>` which can be accessed through e.g.: 
```Dart
  response.then(
    (body) {
      Map<String, dynamic> tradeBalances = jsonDecode(body)['result'];
      return tradeBalances;
    },
  );
 ```

