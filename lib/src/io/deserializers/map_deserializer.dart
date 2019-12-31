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
| LastModified: Dec 31, 2019                               |
| Author: Ma Bingyao <andot@hprose.com>                    |
|                                                          |
\*________________________________________________________*/

part of hprose.io;

Map<K, V> _readMap<K, V>(
    Reader reader,
    Map<K, V> Function() mapCtor,
    AbstractDeserializer<K> keyDeserializer,
    AbstractDeserializer<V> valueDeserializer) {
  final stream = reader.stream;
  final count = ValueReader.readCount(stream);
  final map = mapCtor();
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
  static final AbstractDeserializer instance = MapDeserializer();
  @override
  Map<K, V> read(Reader reader, int tag) {
    switch (tag) {
      case TagEmpty:
        return <K, V>{};
      case TagMap:
        return _readMap(reader, () => <K, V>{}, Deserializer.getInstance<K>(),
            Deserializer.getInstance<V>());
      case TagObject:
        return ReferenceReader.readDynamicObject(reader);
      default:
        return super.read(reader, tag);
    }
  }
}
