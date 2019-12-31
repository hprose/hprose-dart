/*--------------------------------------------------------*\
|                                                          |
|                          hprose                          |
|                                                          |
| Official WebSite: https://hprose.com                     |
|                                                          |
| list_deserializer.dart                                   |
|                                                          |
| hprose List Deserializer for Dart.                       |
|                                                          |
| LastModified: Dec 31, 2019                               |
| Author: Ma Bingyao <andot@hprose.com>                    |
|                                                          |
\*________________________________________________________*/

part of hprose.io;

List<T> _readList<T>(Reader reader, List<T> Function(int count) listCtor,
    AbstractDeserializer<T> deserializer) {
  final stream = reader.stream;
  final count = ValueReader.readCount(stream);
  final list = listCtor(count);
  reader.addReference(list);
  for (var i = 0; i < count; ++i) {
    list[i] = deserializer.deserialize(reader);
  }
  stream.readByte();
  return list;
}

class ListDeserializer<T> extends BaseDeserializer<List<T>> {
  static final AbstractDeserializer instance = ListDeserializer();
  @override
  List<T> read(Reader reader, int tag) {
    switch (tag) {
      case TagEmpty:
        return <T>[];
      case TagList:
        return _readList(
            reader, (count) => List<T>(count), Deserializer.getInstance<T>());
      default:
        return super.read(reader, tag);
    }
  }
}
