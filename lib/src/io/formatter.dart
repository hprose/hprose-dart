/*--------------------------------------------------------*\
|                                                          |
|                          hprose                          |
|                                                          |
| Official WebSite: https://hprose.com                     |
|                                                          |
| formatter.dart                                           |
|                                                          |
| hprose Formatter for Dart.                               |
|                                                          |
| LastModified: Dec 31, 2019                               |
| Author: Ma Bingyao <andot@hprose.com>                    |
|                                                          |
\*________________________________________________________*/

part of hprose.io;

class Formatter {
  static Uint8List serialize<T>(T value, {bool simple = false}) {
    final stream = ByteStream();
    final writer = Writer(stream, simple: simple);
    writer.serialize(value);
    return stream.bytes;
  }

  static T deserialize<T>(dynamic data, {bool simple = false, String type}) {
    ByteStream stream;
    if (data is ByteStream) {
      stream = data;
    } else if (data is Uint8List) {
      stream = ByteStream.fromUint8List(data);
    } else if (data is ByteBuffer) {
      stream = ByteStream.fromByteBuffer(data);
    } else if (data is Uint8ClampedList) {
      stream = ByteStream.fromUint8ClampedList(data);
    } else if (data is String) {
      stream = ByteStream.fromString(data);
    }
    final reader = Reader(stream, simple: simple);
    if (type == null) {
      return reader.deserialize<T>();
    } else {
      return Deserializer.get(type).deserialize(reader);
    }
  }
}
