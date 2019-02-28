library hprose_rpc_tests;

import 'package:test/test.dart';
import 'package:hprose/rpc_core.dart';

String hello(String name) {
  return 'hello $name';
}

void main() {
  test('hello world', () async {
    final service = new Service();
    service.addMethod(hello);
    final server = new MockServer('test');
    service.bind(server);
    final client = new Client(['mock://test']);
    final result = await client.invoke('hello', ['world']);
    expect(result, equals('hello world'));
    server.close();
  });

    test('method', () {
    print(new Method(
            <T>(Map<String, T> a1, int i, {List<Map<T, T>> a2, List a3}) => 10,
            'x')
        .namedParameterTypes);
    print(new Method((int a1, int a2, [double a3 = 12, int a4 = 32]) => a1 + a2 + a3 + a4, 'sum').positionalParameterTypes);
    print(new Method((int a1, int a2, [double a3 = 12, int a4 = 32]) => a1 + a2 + a3 + a4, 'sum').optionalParameterTypes);
    print(new Method(([int a1, int a2, double a3 = 12, int a4 = 32]) => a1 + a2 + a3 + a4, 'sum').positionalParameterTypes);
    print(new Method(([int a1, int a2, double a3 = 12, int a4 = 32]) => a1 + a2 + a3 + a4, 'sum').optionalParameterTypes);
    print(new Method(<T>([T a1, T a2, double a3 = 12, int a4 = 32]) => a3 + a4, 'sum').positionalParameterTypes);
    print(new Method(<T>([T a1, T a2, double a3 = 12, int a4 = 32]) => a3 + a4, 'sum').optionalParameterTypes);
  });

}