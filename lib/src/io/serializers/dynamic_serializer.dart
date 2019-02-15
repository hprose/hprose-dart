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
| LastModified: Feb 15, 2019                               |
| Author: Ma Bingyao <andot@hprose.com>                    |
|                                                          |
\*________________________________________________________*/

part of hprose.io;

class DynamicSerializer extends AbstractSerializer {
  static final AbstractSerializer instance = new DynamicSerializer();
  void write(Writer writer, dynamic value) {
    if (value == null) {
      writer.stream.writeByte(TagNull);
    } else {
      Serializer.getInstance(value.runtimeType, value).write(writer, value);
    }
  }
  void serialize(Writer writer, dynamic value) {
    if (value == null) {
      writer.stream.writeByte(TagNull);
    } else {
      Serializer.getInstance(value.runtimeType, value).serialize(writer, value);
    }
  }
}
