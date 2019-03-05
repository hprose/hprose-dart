library hprose_rpc_tests;

import 'dart:async';
import 'dart:io';
import 'package:test/test.dart';
import 'package:hprose/io.dart';
import 'package:hprose/rpc.dart';

String hello(String name) {
  return 'hello $name';
}

Future<int> sum(int a, int b, [int c = 0, int d = 10]) async {
  await Future.delayed(new Duration(milliseconds: 1));
  return a + b + c + d;
}

String getAddress(String name, ServiceContext context) {
  return '$name : ${context.host}';
}

class User {
  String name;
  int age;
  bool male;
  User([this.name, this.age, this.male]);
  factory User.fromJson(Map<String, dynamic> json) {
    return new User(json['name'], json['age'], json['male']);
  }
  Map<String, dynamic> toJson() =>
      {'name': this.name, 'age': this.age, 'male': this.male};
}

User createUser(String name, {int age, bool male, Context context}) {
  final serviceContext = context as ServiceContext;
  print('${serviceContext.host}:${serviceContext.port}');
  return new User(name, age, male);
}

void main() {
  TypeManager.register((data) => User.fromJson(data),
      {'name': String, 'age': int, 'male': bool});

  test('rpc', () async {
    DefaultServiceCodec.instance.debug = true;
    final service = new Service();
    service.addMethod(hello);
    service.addMethod(sum);
    service.addMethod(getAddress);
    service.addMethod(createUser);
    final server = new MockServer('127.0.0.1');
    service.bind(server);
    final client = new Client(['mock://127.0.0.1']);
    final proxy = client.useService();
    expect(await proxy.hello<String>('world'), equals('hello world'));
    final r1 = proxy.sum<int>(1, 2);
    final r2 = proxy.sum<int>(1, 2, 3);
    expect(await r1, equals(13));
    expect(await r2, equals(16));
    expect(await proxy.sum<int>(r1, r2, 3, 4), equals(36));
    expect(await proxy.sum<int>(1, 2, 3, 4), equals(10));
    expect(await proxy.sum(1, 2, 3, 4, 5), equals(10));
    await expectLater(
        proxy.sum(1, 2, 3, 4,
            new ClientContext(timeout: new Duration(microseconds: 1))),
        throwsException);
    expect(await proxy.getAddress<String>('localhost'),
        equals('localhost : 127.0.0.1'));
    User user = await proxy.createUser<User>('张三', age: 18, male: true);
    expect(user.name, equals('张三'));
    expect(user.age, equals(18));
    expect(user.male, equals(true));
    await proxy.createUser<User>('张三', age: 18, male: true);
    await proxy.createUser<User>('张三', age: 18, male: true);
    await client.abort();
    await proxy.createUser<User>('张三', age: 18, male: true);
    await proxy.createUser<User>('张三', age: 18, male: true);
    await proxy.createUser<User>('张三', age: 18, male: true);
    server.close();
  });

  test('http rpc', () async {
    DefaultServiceCodec.instance.debug = true;
    final service = new Service();
    service.addMethod(hello);
    service.addMethod(sum);
    service.addMethod(getAddress);
    service.addMethod(createUser);
    final server = await HttpServer.bind('127.0.0.1', 8000);
    service.bind(server);
    final client = new Client(['http://127.0.0.1:8000/']);
    client.http.maxConnectionsPerHost = 1;
    final proxy = client.useService();
    expect(await proxy.hello<String>('world'), equals('hello world'));
    final r1 = proxy.sum<int>(1, 2);
    final r2 = proxy.sum<int>(1, 2, 3);
    expect(await r1, equals(13));
    expect(await r2, equals(16));
    expect(await proxy.sum<int>(r1, r2, 3, 4), equals(36));
    expect(await proxy.sum<int>(1, 2, 3, 4), equals(10));
    expect(await proxy.sum(1, 2, 3, 4, 5), equals(10));
    await expectLater(
        proxy.sum(1, 2, 3, 4,
            new ClientContext(timeout: new Duration(microseconds: 1))),
        throwsException);
    expect(await proxy.getAddress<String>('localhost'),
        equals('localhost : 127.0.0.1'));
    User user = await proxy.createUser<User>('张三', age: 18, male: true);
    expect(user.name, equals('张三'));
    expect(user.age, equals(18));
    expect(user.male, equals(true));
    await proxy.createUser<User>('张三', age: 18, male: true);
    await proxy.createUser<User>('张三', age: 18, male: true);
    await client.abort();
    await proxy.createUser<User>('张三', age: 18, male: true);
    await proxy.createUser<User>('张三', age: 18, male: true);
    await proxy.createUser<User>('张三', age: 18, male: true);
    server.close();
  });

  test('tcp rpc', () async {
    DefaultServiceCodec.instance.debug = true;
    final service = new Service();
    service.addMethod(hello);
    service.addMethod(sum);
    service.addMethod(getAddress);
    service.addMethod(createUser);
    final server = await ServerSocket.bind('127.0.0.1', 8412);
    service.bind(server);
    final client = new Client(['tcp://127.0.0.1/']);
    final proxy = client.useService();
    expect(await proxy.hello<String>('world'), equals('hello world'));
    final r1 = proxy.sum<int>(1, 2);
    final r2 = proxy.sum<int>(1, 2, 3);
    expect(await r1, equals(13));
    expect(await r2, equals(16));
    expect(await proxy.sum<int>(r1, r2, 3, 4), equals(36));
    expect(await proxy.sum<int>(1, 2, 3, 4), equals(10));
    expect(await proxy.sum(1, 2, 3, 4, 5), equals(10));
    await expectLater(
        proxy.sum(1, 2, 3, 4,
            new ClientContext(timeout: new Duration(microseconds: 1))),
        throwsException);
    expect(await proxy.getAddress<String>('localhost'),
        equals('localhost : 127.0.0.1'));
    User user = await proxy.createUser<User>('张三', age: 18, male: true);
    expect(user.name, equals('张三'));
    expect(user.age, equals(18));
    expect(user.male, equals(true));
    await proxy.createUser<User>('张三', age: 18, male: true);
    await proxy.createUser<User>('张三', age: 18, male: true);
    await client.abort();
    await proxy.createUser<User>('张三', age: 18, male: true);
    await proxy.createUser<User>('张三', age: 18, male: true);
    await proxy.createUser<User>('张三', age: 18, male: true);
    server.close();
  });

  test('udp rpc', () async {
    DefaultServiceCodec.instance.debug = true;
    final service = new Service();
    service.addMethod(hello);
    service.addMethod(sum);
    service.addMethod(getAddress);
    service.addMethod(createUser);
    final server = await RawDatagramSocket.bind('127.0.0.1', 8412);
    service.bind(server);
    final client = new Client(['udp://127.0.0.1/']);
    final proxy = client.useService();
    expect(await proxy.hello<String>('world'), equals('hello world'));
    final r1 = proxy.sum<int>(1, 2);
    final r2 = proxy.sum<int>(1, 2, 3);
    expect(await r1, equals(13));
    expect(await r2, equals(16));
    expect(await proxy.sum<int>(r1, r2, 3, 4), equals(36));
    expect(await proxy.sum<int>(1, 2, 3, 4), equals(10));
    expect(await proxy.sum(1, 2, 3, 4, 5), equals(10));
    await expectLater(
        proxy.sum(1, 2, 3, 4,
            new ClientContext(timeout: new Duration(microseconds: 1))),
        throwsException);
    expect(await proxy.getAddress<String>('localhost'),
        equals('localhost : 127.0.0.1'));
    User user = await proxy.createUser<User>('张三', age: 18, male: true);
    expect(user.name, equals('张三'));
    expect(user.age, equals(18));
    expect(user.male, equals(true));
    await proxy.createUser<User>('张三', age: 18, male: true);
    await proxy.createUser<User>('张三', age: 18, male: true);
    await client.abort();
    await proxy.createUser<User>('张三', age: 18, male: true);
    await proxy.createUser<User>('张三', age: 18, male: true);
    await proxy.createUser<User>('张三', age: 18, male: true);
    server.close();
  });

  test('websocket rpc', () async {
    DefaultServiceCodec.instance.debug = true;
    final service = new Service();
    service.addMethod(hello);
    service.addMethod(sum);
    service.addMethod(getAddress);
    service.addMethod(createUser);
    final server = await HttpServer.bind('127.0.0.1', 8001);
    service.bind(server);
    final client = new Client(['ws://127.0.0.1:8001/']);
    final proxy = client.useService();
    expect(await proxy.hello<String>('world'), equals('hello world'));
    final r1 = proxy.sum<int>(1, 2);
    final r2 = proxy.sum<int>(1, 2, 3);
    expect(await r1, equals(13));
    expect(await r2, equals(16));
    expect(await proxy.sum<int>(r1, r2, 3, 4), equals(36));
    expect(await proxy.sum<int>(1, 2, 3, 4), equals(10));
    expect(await proxy.sum(1, 2, 3, 4, 5), equals(10));
    await expectLater(
        proxy.sum(1, 2, 3, 4,
            new ClientContext(timeout: new Duration(microseconds: 1))),
        throwsException);
    expect(await proxy.getAddress<String>('localhost'),
        equals('localhost : 127.0.0.1'));
    User user = await proxy.createUser<User>('张三', age: 18, male: true);
    expect(user.name, equals('张三'));
    expect(user.age, equals(18));
    expect(user.male, equals(true));
    await proxy.createUser<User>('张三', age: 18, male: true);
    await proxy.createUser<User>('张三', age: 18, male: true);
    await client.abort();
    await proxy.createUser<User>('张三', age: 18, male: true);
    await proxy.createUser<User>('张三', age: 18, male: true);
    await proxy.createUser<User>('张三', age: 18, male: true);
    server.close();
  });

}
