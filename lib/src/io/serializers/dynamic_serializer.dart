/*--------------------------------------------------------*\
|                                                          |
|                          hprose                          |
|                                                          |
| Official WebSite: https://hprose.com                     |
|                                                          |
| dynamic_serializer.ts                                    |
|                                                          |
| hprose dynamic Serializer for Dart.                      |
|                                                          |
| LastModified: Dec 31, 2019                               |
| Author: Ma Bingyao <andot@hprose.com>                    |
|                                                          |
\*________________________________________________________*/

part of hprose.io;

class DynamicSerializer implements AbstractSerializer {
  static final AbstractSerializer instance = DynamicSerializer();
  @override
  void write(Writer writer, dynamic value) {
    if (value == null) {
      writer.stream.writeByte(TagNull);
    } else {
      Serializer.get(value.runtimeType.toString(), value).write(writer, value);
    }
  }

  @override
  void serialize(Writer writer, dynamic value) {
    if (value == null) {
      writer.stream.writeByte(TagNull);
    } else {
      Serializer.get(value.runtimeType.toString(), value)
          .serialize(writer, value);
    }
  }
}
