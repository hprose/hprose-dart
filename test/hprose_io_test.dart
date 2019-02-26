library hprose_io_tests;

import 'dart:collection';
import 'dart:convert';
import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:hprose/io.dart';
import 'package:hprose/rpc_core.dart';

void main() {
  TypeManager.register((data) => User.fromJson(data),
      {'name': String, 'age': int, 'male': bool});

  test('test writeByte & readAsciiString', () {
    final stream = new ByteStream();
    List<int> array = [];
    for (var i = 0; i < 256; ++i) {
      stream.writeByte(i);
      array.add(i);
    }
    expect(stream.readAsciiString(256), equals(String.fromCharCodes(array)));
  });

  test('test writeString & toString', () {
    final stream = new ByteStream();
    stream.writeString('你好🌏');
    expect(stream.toString(), equals('你好🌏'));
  });

  test('test writeInt32BE & readInt32BE', () {
    final stream = new ByteStream();
    stream.writeInt32BE(2147483647);
    stream.writeInt32BE(-2147483648);
    stream.writeInt32BE(-123456);
    stream.writeInt32BE(0);
    stream.writeInt32BE(1);
    stream.writeInt32BE(-1);
    expect(stream.readInt32BE(), equals(2147483647));
    expect(stream.readInt32BE(), equals(-2147483648));
    expect(stream.readInt32BE(), equals(-123456));
    expect(stream.readInt32BE(), equals(0));
    expect(stream.readInt32BE(), equals(1));
    expect(stream.readInt32BE(), equals(-1));
  });

  test('test writeInt32LE & readInt32LE', () {
    final stream = new ByteStream();
    stream.writeInt32LE(2147483647);
    stream.writeInt32LE(-2147483648);
    stream.writeInt32LE(-123456);
    stream.writeInt32LE(0);
    stream.writeInt32LE(1);
    stream.writeInt32LE(-1);

    expect(stream.readInt32LE(), equals(2147483647));
    expect(stream.readInt32LE(), equals(-2147483648));
    expect(stream.readInt32LE(), equals(-123456));
    expect(stream.readInt32LE(), equals(0));
    expect(stream.readInt32LE(), equals(1));
    expect(stream.readInt32LE(), equals(-1));
  });

  test('test writeUInt32BE & readUInt32BE', () {
    final stream = new ByteStream();
    stream.writeUInt32BE(2 ^ 31);
    stream.writeUInt32BE(2 ^ 32 - 1);
    stream.writeUInt32BE(0);
    stream.writeUInt32BE(1);
    expect(stream.readUInt32BE(), equals(2 ^ 31));
    expect(stream.readUInt32BE(), equals(2 ^ 32 - 1));
    expect(stream.readUInt32BE(), equals(0));
    expect(stream.readUInt32BE(), equals(1));
  });

  test('test writeUInt32LE & readUInt32LE', () {
    final stream = new ByteStream();
    stream.writeUInt32LE(2 ^ 31);
    stream.writeUInt32LE(2 ^ 32 - 1);
    stream.writeUInt32LE(0);
    stream.writeUInt32LE(1);
    expect(stream.readUInt32LE(), equals(2 ^ 31));
    expect(stream.readUInt32LE(), equals(2 ^ 32 - 1));
    expect(stream.readUInt32LE(), equals(0));
    expect(stream.readUInt32LE(), equals(1));
  });

  test('test serialize iterable', () {
    final byteList = HashSet<int>.from(<int>[1, 2, 3]);
    final doubleList = <double>[1.2, 3.4, 5.6];
    final list = [0, 1.2, 3.4, 5.6, "hello", byteList, doubleList];
    final stream = new ByteStream();
    final writer = new Writer(stream);
    writer.serialize<DynamicObject>(null);
    writer.serialize(byteList);
    writer.serialize(doubleList);
    writer.serialize(list);
    print(stream.toString());
    final reader = new Reader(stream);
    final n = reader.deserialize<List>();
    final list1 = reader.deserialize<List<int>>();
    final list2 = reader.deserialize<List<double>>();
    final list3 = reader.deserialize<List>();
    print(n);
    print(list1);
    print(list2);
    print(list3);
  });

  test('test serialize dynamic object', () {
    dynamic user = new User();
    user.name = '张三';
    user.age = 18;
    user.male = true;
    dynamic user2 = new DynamicObject('User');
    user2.name = '李四';
    user2.age = 20;
    user2.male = false;
    print(json.encode([user, user2]));
    var data = Formatter.serialize<List>([user, user2]);
    print(utf8.decode(data));
    final users = Formatter.deserialize<List>(data);
    print(json.encode(users));
  });

  test('serialize', () {
    expect(utf8.decode(Formatter.serialize(0)), equals("0"));
    expect(utf8.decode(Formatter.serialize(1)), equals("1"));
    expect(utf8.decode(Formatter.serialize(11)), equals("i11;"));
    expect(utf8.decode(Formatter.serialize(1234567890987654)),
        equals("l1234567890987654;"));
    expect(utf8.decode(Formatter.serialize(-42)), equals("i-42;"));
    expect(utf8.decode(Formatter.serialize(3.14)), equals("d3.14;"));
    expect(utf8.decode(Formatter.serialize(double.nan)), equals("N"));
    expect(utf8.decode(Formatter.serialize(double.infinity)), equals("I+"));
    expect(utf8.decode(Formatter.serialize(double.negativeInfinity)),
        equals("I-"));
    expect(utf8.decode(Formatter.serialize(null)), equals("n"));
    expect(utf8.decode(Formatter.serialize("")), equals("e"));
    expect(utf8.decode(Formatter.serialize("c")), equals("uc"));
    expect(utf8.decode(Formatter.serialize("我")), equals("u我"));
    expect(utf8.decode(Formatter.serialize("我爱你")), equals('s3"我爱你"'));
    expect(utf8.decode(Formatter.serialize("我爱五星红旗🇨🇳")),
        equals('s10"我爱五星红旗🇨🇳"'));
    expect(
        utf8.decode(Formatter.serialize([1, 2, 3, 4, 5])), equals("a5{12345}"));
    expect(utf8.decode(Formatter.serialize(["Jan", "Feb", "Mar", "Mar"])),
        equals('a4{s3"Jan"s3"Feb"s3"Mar"r3;}'));
    expect(
        utf8.decode(
            Formatter.serialize(["Jan", "Feb", "Mar", "Mar"], simple: true)),
        equals('a4{s3"Jan"s3"Feb"s3"Mar"s3"Mar"}'));
    Int32List int32List = new Int32List.fromList([1, 2, 3, 4, 5]);
    expect(utf8.decode(Formatter.serialize(int32List)), equals('a5{12345}'));
    Uint8List uint8List = new Uint8List.fromList([48, 49, 50, 51, 52]);
    expect(utf8.decode(Formatter.serialize(uint8List)), equals('b5"01234"'));
    Map map = {"name": "张三", "age": 28};
    expect(utf8.decode(Formatter.serialize(map)),
        equals('m2{s4"name"s2"张三"s3"age"i28;}'));
    List<Map> mapList = [
      {"name": "张三", "age": 28},
      {"name": "李四", "age": 29},
      {"name": "王二麻子", "age": 30},
    ];
    expect(
        utf8.decode(Formatter.serialize(mapList)),
        equals(
            'a3{m2{s4"name"s2"张三"s3"age"i28;}m2{r2;s2"李四"r4;i29;}m2{r2;s4"王二麻子"r4;i30;}}'));
    expect(
        utf8.decode(Formatter.serialize(mapList, simple: true)),
        equals(
            'a3{m2{s4"name"s2"张三"s3"age"i28;}m2{s4"name"s2"李四"s3"age"i29;}m2{s4"name"s4"王二麻子"s3"age"i30;}}'));
    dynamic user = new User();
    user.name = "张三";
    user.age = 28;
    user.male = true;
    expect(utf8.decode(Formatter.serialize(user)),
        equals('c4"User"3{s4"name"s3"age"s4"male"}o0{s2"张三"i28;t}'));
    dynamic user2 = new User();
    user2.name = "李四";
    user2.age = 29;
    user2.male = true;
    dynamic user3 = new DynamicObject('User');
    user3.name = "王二麻子";
    user3.age = 30;
    user3.male = false;
    List userList = [user, user2, user3, user];
    expect(
        utf8.decode(Formatter.serialize(userList)),
        equals(
            'a4{c4"User"3{s4"name"s3"age"s4"male"}o0{s2"张三"i28;t}o0{s2"李四"i29;t}o0{s4"王二麻子"i30;f}r4;}'));
    expect(
        utf8.decode(Formatter.serialize(userList, simple: true)),
        equals(
            'a4{c4"User"3{s4"name"s3"age"s4"male"}o0{s2"张三"i28;t}o0{s2"李四"i29;t}o0{s4"王二麻子"i30;f}o0{s2"张三"i28;t}}'));
  });

  test('deserialize', () {
    expect(Formatter.deserialize(Formatter.serialize(0)), equals(0));
    expect(Formatter.deserialize(Formatter.serialize(1)), equals(1));
    expect(Formatter.deserialize(Formatter.serialize(11)), equals(11));
    expect(Formatter.deserialize(Formatter.serialize(1234567890987654321)),
        equals(1234567890987654321));
    expect(Formatter.deserialize(Formatter.serialize(-42)), equals(-42));
    expect(Formatter.deserialize(Formatter.serialize(3.14)), equals(3.14));
    expect(Formatter.deserialize(Formatter.serialize(0.0)), equals(0.0));
    expect(Formatter.deserialize(Formatter.serialize(double.nan)).isNaN,
        equals(true));
    expect(Formatter.deserialize(Formatter.serialize(double.infinity)),
        equals(double.infinity));
    expect(Formatter.deserialize(Formatter.serialize(double.negativeInfinity)),
        equals(double.negativeInfinity));
    expect(Formatter.deserialize(Formatter.serialize(null)), equals(null));
    expect(Formatter.deserialize(Formatter.serialize("")), equals(""));
    expect(Formatter.deserialize(Formatter.serialize("c")), equals("c"));
    expect(Formatter.deserialize(Formatter.serialize("我")), equals("我"));
    expect(Formatter.deserialize(Formatter.serialize("我爱你")), equals('我爱你'));
    expect(Formatter.deserialize(Formatter.serialize("我爱五星红旗🇨🇳")),
        equals('我爱五星红旗🇨🇳'));
    expect(Formatter.deserialize(Formatter.serialize([1, 2, 3, 4, 5])),
        equals([1, 2, 3, 4, 5]));
    expect(
        Formatter.deserialize(
            Formatter.serialize(["Jan", "Feb", "Mar", "Mar"])),
        equals(["Jan", "Feb", "Mar", "Mar"]));
    expect(
        Formatter.deserialize(
            Formatter.serialize(["Jan", "Feb", "Mar", "Mar"], simple: true)),
        equals(["Jan", "Feb", "Mar", "Mar"]));
    expect(
        Formatter.deserialize(
            Formatter.serialize(["Jan", "Feb", "Mar", "Mar"], simple: true),
            simple: true),
        equals(["Jan", "Feb", "Mar", "Mar"]));
    Int32List int32List = new Int32List.fromList([1, 2, 3, 4, 5]);
    expect(Formatter.deserialize(Formatter.serialize(int32List)),
        equals(int32List));
    Uint8List uint8List = new Uint8List.fromList([48, 49, 50, 51, 52]);
    expect(Formatter.deserialize(Formatter.serialize(uint8List)),
        equals(uint8List));
    Map map = {"name": "张三", "age": 28};
    expect(Formatter.deserialize(Formatter.serialize(map)), equals(map));
    List<Map> mapList = [
      {"name": "张三", "age": 28},
      {"name": "李四", "age": 29},
      {"name": "王二麻子", "age": 30},
    ];
    expect(
        Formatter.deserialize(Formatter.serialize(mapList)), equals(mapList));
    expect(Formatter.deserialize(Formatter.serialize(mapList, simple: true)),
        equals(mapList));
    expect(
        Formatter.deserialize(Formatter.serialize(mapList, simple: true),
            simple: true),
        equals(mapList));
    dynamic user = new User();
    user.name = "张三";
    user.age = 28;
    user.male = true;
    dynamic user1 = Formatter.deserialize(Formatter.serialize(user));
    expect(user1.name, equals(user.name));
    expect(user1.age, equals(user.age));
    expect(user1.male, equals(user.male));
    dynamic user2 = new User();
    user2.name = "李四";
    user2.age = 29;
    user2.male = true;
    dynamic user3 = new User();
    user3.name = "王二麻子";
    user3.age = 30;
    user3.male = false;
    List userList = [user, user2, user3];
    expect(
        utf8.decode(Formatter.serialize(
                Formatter.deserialize(Formatter.serialize(userList))))
            ,
        equals(utf8.decode(Formatter.serialize(userList))));
    expect(
        Formatter.serialize(
                Formatter.deserialize(
                    Formatter.serialize(userList, simple: true)),
                simple: true)
            .toString(),
        equals(Formatter.serialize(userList, simple: true).toString()));
    expect(
        Formatter.serialize(
                Formatter.deserialize(
                    Formatter.serialize(userList, simple: true),
                    simple: true),
                simple: true)
            .toString(),
        equals(Formatter.serialize(userList, simple: true).toString()));
  });

  test('method', () {
    var stream = new ByteStream();
    print(List);
    print(new Method(stream.takeBytes).positionalParameterTypes);
    print(new Method(Formatter.serialize).namedParameterTypes);
    print(new Method(
            <T>(Map<String, T> a1, int i, {List<Map<T, T>> a2, List a3}) => 10,
            'x')
        .namedParameterTypes);
  });
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
