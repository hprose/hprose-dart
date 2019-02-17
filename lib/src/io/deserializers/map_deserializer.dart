/*--------------------------------------------------------*\
|                                                          |
|                          hprose                          |
|                                                          |
| Official WebSite: https://hprose.com                     |
|                                                          |
| map_deserializer.dart                                    |
|                                                          |
| hprose Map Deserializer for Dart.                        |
|                                                          |
| LastModified: Feb 16, 2019                               |
| Author: Ma Bingyao <andot@hprose.com>                    |
|                                                          |
\*________________________________________________________*/

part of hprose.io;

T _readMap<T>(Reader reader, T mapCtor(), AbstractDeserializer keyDeserializer,
    AbstractDeserializer valueDeserializer) {
  final stream = reader.stream;
  final count = ValueReader.readCount(stream);
  dynamic map = mapCtor();
  reader.addReference(map);
  for (var i = 0; i < count; ++i) {
    final key = keyDeserializer.deserialize(reader);
    final value = valueDeserializer.deserialize(reader);
    map[key] = value;
  }
  stream.readByte();
  return map;
}

class MapDeserializer<K, V> extends BaseDeserializer<Map<K, V>> {
  static final AbstractDeserializer instance = new MapDeserializer();
  @override
  Map<K, V> read(Reader reader, int tag) {
    switch (tag) {
      case TagEmpty:
        return new Map<K, V>();
      case TagMap:
        return _readMap(reader, () => new Map<K, V>(),
            Deserializer.getInstance(K), Deserializer.getInstance(V));
      case TagObject:
        return ReferenceReader.readObject(reader);
      default:
        return super.read(reader, tag);
    }
  }
}
