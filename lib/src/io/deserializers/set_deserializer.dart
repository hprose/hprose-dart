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
| LastModified: Dec 31, 2019                               |
| Author: Ma Bingyao <andot@hprose.com>                    |
|                                                          |
\*________________________________________________________*/

part of hprose.io;

Set<T> _readSet<T>(Reader reader, Set<T> Function() setCtor,
    AbstractDeserializer<T> deserializer) {
  final stream = reader.stream;
  final count = ValueReader.readCount(stream);
  final set = setCtor();
  reader.addReference(set);
  for (var i = 0; i < count; ++i) {
    set.add(deserializer.deserialize(reader));
  }
  stream.readByte();
  return set;
}

class SetDeserializer<T> extends BaseDeserializer<Set<T>> {
  static final AbstractDeserializer instance = SetDeserializer();
  @override
  Set<T> read(Reader reader, int tag) {
    switch (tag) {
      case TagEmpty:
        return <T>{};
      case TagList:
        return _readSet(reader, () => <T>{}, Deserializer.getInstance<T>());
      default:
        return super.read(reader, tag);
    }
  }
}
