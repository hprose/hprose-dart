library hprose_rpc_tests;

import 'package:test/test.dart';
import 'package:hprose/rpc_core.dart';

void main() {
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