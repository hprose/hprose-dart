@TestOn("browser")
library hprose_browser_tests;
import 'package:test/test.dart';
import 'package:hprose/browser.dart';

void main() {
  test('BrowserHttpClient', () {
    HttpClient client = new HttpClient("http://hprose.com/example/index.php");
    client.hello("World").then((result) {
      expect(result, equals("Hello World"));
    });
    client.testError().catchError((e) {
      expect(e.message, equals("Can't find this function testError()."));
    });
    Map<String, String> m = {"a": "A", "b": "B"};
    List<dynamic> args = [m];
    client.invoke('swapKeyAndValue', args, true, Serialized, true).then((result) {
      expect(
          args,
          equals([
            {"A": "a", "B": "b"}
          ]));
      expect(Formatter.serialize(Formatter.unserialize(result)).toString(), equals("m2{uAuauBub}"));
    });
  });
  (() async {
    HttpClient client = new HttpClient("http://hprose.com/example/index.php");
    var result = await client.sum(1, 2);
    expect(result, equals(3));
  })();
}
