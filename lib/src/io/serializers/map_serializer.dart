/*--------------------------------------------------------*\
|                                                          |
|                          hprose                          |
|                                                          |
| Official WebSite: https://hprose.com                     |
|                                                          |
| map_serializer.ts                                        |
|                                                          |
| hprose Map Serializer for Dart.                          |
|                                                          |
| LastModified: Feb 15, 2019                               |
| Author: Ma Bingyao <andot@hprose.com>                    |
|                                                          |
\*________________________________________________________*/

part of hprose.io;

class MapSerializer<K, V> extends ReferenceSerializer<Map<K, V>> {
  static final AbstractSerializer instance = new MapSerializer();
  void write(Writer writer, Map<K, V> value) {
    super.write(writer, value);
    final stream = writer.stream;
    stream.writeByte(TagMap);
    final n = value.length;
    if (n > 0) stream.writeAsciiString(n.toString());
    stream.writeByte(TagOpenbrace);
    AbstractSerializer keySerializer = Serializer.getInstance(K, value.keys.first);
    AbstractSerializer valueSerializer = Serializer.getInstance(V, value.values.first);
    for (final entry in value.entries) {
      keySerializer.serialize(writer, entry.key);
      valueSerializer.serialize(writer, entry.value);
    }
    stream.writeByte(TagClosebrace);
  }
}
