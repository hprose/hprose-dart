/*--------------------------------------------------------*\
|                                                          |
|                          hprose                          |
|                                                          |
| Official WebSite: https://hprose.com                     |
|                                                          |
| base_serializer.dart                                     |
|                                                          |
| hprose BaseDeserializer for Dart.                        |
|                                                          |
| LastModified: Dec 31, 2019                               |
| Author: Ma Bingyao <andot@hprose.com>                    |
|                                                          |
\*________________________________________________________*/

part of hprose.io;

class BaseDeserializer<T> implements AbstractDeserializer<T> {
  static final AbstractDeserializer instance = BaseDeserializer();
  String type = T.toString();
  BaseDeserializer([String type]) {
    if (type != null) this.type = type;
  }
  @override
  T read(Reader reader, int tag) {
    switch (tag) {
      case TagNull:
        return null;
      case TagRef:
        return reader.readReference();
      case TagClass:
        reader.readClass();
        return deserialize(reader);
      case TagError:
        throw Exception(reader.deserialize<String>());
    }
    throw Exception('Cannot convert ${tagToString(tag)} to ${type}.');
  }

  @override
  T deserialize(Reader reader) => read(reader, reader.stream.readByte());
}
