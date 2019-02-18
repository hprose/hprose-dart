/*--------------------------------------------------------*\
|                                                          |
|                          hprose                          |
|                                                          |
| Official WebSite: https://hprose.com                     |
|                                                          |
| set_deserializer.dart                                    |
|                                                          |
| hprose Set Deserializer for Dart.                        |
|                                                          |
| LastModified: Feb 16, 2019                               |
| Author: Ma Bingyao <andot@hprose.com>                    |
|                                                          |
\*________________________________________________________*/

part of hprose.io;

T _readSet<T>(Reader reader, T setCtor(), AbstractDeserializer deserializer) {
  final stream = reader.stream;
  final count = ValueReader.readCount(stream);
  dynamic list = setCtor();
  reader.addReference(list);
  for (var i = 0; i < count; ++i) {
    list[i] = deserializer.deserialize(reader);
  }
  stream.readByte();
  return list;
}

class SetDeserializer<T> extends BaseDeserializer<Set<T>> {
  static final AbstractDeserializer instance = new SetDeserializer();
  @override
  Set<T> read(Reader reader, int tag) {
    switch (tag) {
      case TagEmpty:
        return new Set<T>();
      case TagList:
        return _readSet(
            reader, () => new Set<T>(), Deserializer.getInstance(T));
      default:
        return super.read(reader, tag);
    }
  }
}
