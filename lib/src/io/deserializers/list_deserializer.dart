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
| LastModified: Feb 16, 2019                               |
| Author: Ma Bingyao <andot@hprose.com>                    |
|                                                          |
\*________________________________________________________*/

part of hprose.io;

T _readList<T>(
    Reader reader, T listCtor(int count), AbstractDeserializer deserializer) {
  final stream = reader.stream;
  final count = ValueReader.readCount(stream);
  dynamic list = listCtor(count);
  reader.addReference(list);
  for (var i = 0; i < count; ++i) {
    list[i] = deserializer.deserialize(reader);
  }
  stream.readByte();
  return list;
}

class ListDeserializer<T> extends BaseDeserializer<List<T>> {
  static final AbstractDeserializer instance = new ListDeserializer();
  @override
  List<T> read(Reader reader, int tag) {
    switch (tag) {
      case TagEmpty:
        return new List<T>(0);
      case TagList:
        return _readList(
            reader, (count) => new List<T>(count), Deserializer.getInstance(T));
      default:
        return super.read(reader, tag);
    }
  }
}
