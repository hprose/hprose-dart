library hprose_example;

import 'dart:async';
import 'dart:io';
import 'package:hprose/hprose.dart';

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

void main() async {
  TypeManager.register((data) => User.fromJson(data),
      {'name': String, 'age': int, 'male': bool});
  final service = new Service();
  service
    ..addMethod(hello)
    ..addMethod(sum)
    ..addMethod(getAddress)
    ..addMethod(createUser);
  final server = await HttpServer.bind('127.0.0.1', 8000);
  service.bind(server);
  final client = new Client(['http://127.0.0.1:8000/']);
  final proxy = client.useService();
  print(await proxy.hello<String>('world'));
  final r1 = proxy.sum<int>(1, 2);
  final r2 = proxy.sum<int>(1, 2, 3);
  print(await proxy.sum<int>(r1, r2, 3, 4));
  print(await proxy.getAddress<String>('localhost'));
  User user = await proxy.createUser<User>('张三', age: 18, male: true);
  print(user);
  server.close();
}
