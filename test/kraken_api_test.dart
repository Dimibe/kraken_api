import 'package:http/http.dart';
import 'package:http/testing.dart';
import 'package:test/test.dart';
import 'package:kraken_api/kraken_api.dart';

void main() {
  test('test request url building', () async {
    Client client = MockClient((request) async {
      return Response(request.url.toString(), 200);
    });
    KrakenApi api = KrakenApi('', '');
    api.client = client;

    await api.call(Methods.BALANCE).then((response) {
      expect(response, 'https://api.kraken.com/0/private/Balance');
    });

    await api.call(Methods.TIME).then((response) {
      expect(response, 'https://api.kraken.com/0/public/Time');
    });
  });

  test('test api sign calculation', () async {
    Client client = MockClient((request) async {
      return Response(request.headers['API-SIGN']!, 200);
    });
    KrakenApi api = KrakenApi('', '');
    api.client = client;

    String nonce = '"1568383937667000"';
    await api.callPrivate(Methods.BALANCE.toString(), nonce).then((response) {
      expect(response,
          'bmKZ9bNEGGJR/KDEPfzsNfkIk3EtBqYLcK+D8YWrX/ovq8vCTiPx7IBaulceM2Kl0qf6i/ByVRAGEbfifEsWnw==');
    });
  });
}
