library hprose_rpc_tests;

import 'dart:async';
import 'dart:io';
import 'package:test/test.dart';
import 'package:hprose/io.dart';
import 'package:hprose/rpc.dart';
import 'package:hprose/plugins.dart';
import 'package:hprose/jsonrpc.dart';

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
    service
      //..use(log.ioHandler)
      ..addMethod(hello)
      ..addMethod(sum)
      ..addMethod(getAddress)
      ..addMethod(createUser);
    final server = new MockServer('127.0.0.1');
    service.bind(server);
    final client = new Client(['mock://127.0.0.1']);
    //client.use(log.invokeHandler);
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

  test('jsonrpc', () async {
    final service = new Service();
    service.codec = JsonRpcServiceCodec.instance;
    service
      //..use(log.ioHandler)
      ..addMethod(hello)
      ..addMethod(sum)
      ..addMethod(getAddress)
      ..addMethod(createUser);
    final server = new MockServer('127.0.0.1');
    service.bind(server);
    final client = new Client(['mock://127.0.0.1']);
    client.codec = JsonRpcClientCodec.instance;
    //client.use(log.invokeHandler);
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
    service
      //..use(log.ioHandler)
      ..addMethod(hello)
      ..addMethod(sum)
      ..addMethod(getAddress)
      ..addMethod(createUser);
    final server = await HttpServer.bind('127.0.0.1', 8000);
    service.bind(server);
    final client = new Client(['http://127.0.0.1:8000/']);
    //client.use(log.invokeHandler);
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
    service
      //..use(log.ioHandler)
      ..addMethod(hello)
      ..addMethod(sum)
      ..addMethod(getAddress)
      ..addMethod(createUser);
    final server = await ServerSocket.bind('127.0.0.1', 8414);
    service.bind(server);
    final client = new Client(['tcp://127.0.0.1:8414/']);
    //client.use(log.invokeHandler);
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
    service
      //..use(log.ioHandler)
      ..addMethod(hello)
      ..addMethod(sum)
      ..addMethod(getAddress)
      ..addMethod(createUser);
    final server = await RawDatagramSocket.bind('127.0.0.1', 8413);
    service.bind(server);
    final client = new Client(['udp://127.0.0.1:8413/']);
    //client.use(log.invokeHandler);
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
    service
      //..use(log.ioHandler)
      ..addMethod(hello)
      ..addMethod(sum)
      ..addMethod(getAddress)
      ..addMethod(createUser);
    final server = await HttpServer.bind('127.0.0.1', 8001);
    service.bind(server);
    final client = new Client(['ws://127.0.0.1:8001/']);
    //client.use(log.invokeHandler);
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

  test('limiter', () async {
    DefaultServiceCodec.instance.debug = true;
    final service = new Service();
    service.addMethod(hello);
    final server = new MockServer('127.0.0.1');
    service.bind(server);
    final client = new Client(['mock://127.0.0.1']);
    final proxy = client.useService();
    client
      ..use(new RateLimiter(20).invokeHandler)
      ..use(new ConcurrentLimiter(100000).handler);
    final begin = new DateTime.now();
    List<Future> tasks = [];
    for (int i = 0; i <= 6; i++) {
      tasks.add(proxy.hello<String>('world'));
    }
    await Future.wait(tasks);
    final end = new DateTime.now();
    print(end.difference(begin));
    server.close();
  });

  test('push', () async {
    final service = new Broker(new Service()).service;
    //service.use(log.ioHandler);
    final server = await HttpServer.bind('127.0.0.1', 8000);
    service.bind(server);
    final client1 = new Client(['http://127.0.0.1:8000/']);
    final prosumer1 = new Prosumer(client1, '1');
    final client2 = new Client(['http://127.0.0.1:8000/']);
    final prosumer2 = new Prosumer(client2, '2');
    await prosumer1.subscribe('test', (message) {
      //print(message);
      //print(message.toJson());
      expect(message.from, equals('2'));
      expect(message.data, equals('hello'));
    });
    await prosumer1.subscribe('test2', (message) {
      //print(message);
      //print(message.toJson());
      expect(message.from, equals('2'));
      expect(message.data, equals('world'));
    });
    await prosumer1.subscribe('test3', (message) {
      //print(message);
      //print(message.toJson());
      expect(message.from, equals('2'));
      expect(message.data.toString(), equals('error'));
    });
    final r1 = prosumer2.push('hello', 'test', '1');
    final r2 = prosumer2.push('hello', 'test', '1');
    final r3 = prosumer2.push('world', 'test2', '1');
    final r4 = prosumer2.push('world', 'test2', '1');
    final r5 = prosumer2.push(new Exception('error'), 'test3', '1');

    await Future.wait([r1, r2, r3, r4, r5]);
    await Future.delayed(const Duration(milliseconds: 10), () async {
      await prosumer1.unsubscribe('test');
      await prosumer1.unsubscribe('test2');
      await prosumer1.unsubscribe('test3');
      server.close();
    });
  });

  test('reverse RPC', () async {
    final service = new Service();
    final caller = new Caller(service);
    //service.use(log.ioHandler);
    final server = new MockServer('127.0.0.1');
    service.bind(server);

    final client = new Client(['mock://127.0.0.1']);
    //client.use(log.invokeHandler);
    final provider = new Provider(client, '1');
    provider.debug = true;
    //provider.use(log.invokeHandler);
    provider.addMethod(hello);
    provider.listen();

    final proxy = caller.useService('1');
    final result1 = proxy.hello<String>('world1');
    final result2 = proxy.hello<String>('world2');
    final result3 = proxy.hello<String>('world3');

    expect(await result1, equals('hello world1'));
    expect(await result2, equals('hello world2'));
    expect(await result3, equals('hello world3'));
    await provider.close();
    server.close();
  });
}
