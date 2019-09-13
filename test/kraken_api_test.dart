import 'package:http/http.dart';
import 'package:http/testing.dart';
import 'package:test/test.dart';
import 'package:kraken_api/kraken_api.dart';

void main() {
  test('test methods', () {
    expect('${Methods.TIME}', '/0/public/Time');
    expect('${Methods.BALANCE}', '/0/private/Balance');
  });

  test('test api sign calculation', () async {
    Client client = MockClient((request) async {
      return Response(request.headers['API-SIGN'], 200);
    });
    KrakenApi api = KrakenApi('', '');
    api.client = client;

    String nonce = '"1568383937667000"';
    await api.callPrivate(Methods.BALANCE.toString(), nonce).then((response) {
      expect(response, 'vycuwQPKES3B5BylGP4jV7XaI+/NNpng7anh0QGnaOERt9kbO8Uv2Epuho1nutMT/yQMUwat0kDYUOJRfsPWgA==');
    });
  });
}
