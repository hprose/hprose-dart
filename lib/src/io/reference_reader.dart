/*--------------------------------------------------------*\
|                                                          |
|                          hprose                          |
|                                                          |
| Official WebSite: https://hprose.com                     |
|                                                          |
| reference_reader.dart                                    |
|                                                          |
| hprose reference reader for Dart.                        |
|                                                          |
| LastModified: Dec 31, 2019                               |
| Author: Ma Bingyao <andot@hprose.com>                    |
|                                                          |
\*________________________________________________________*/

part of hprose.io;

class ReferenceReader {
  static Uint8List readBytes(Reader reader) {
    final result = ValueReader.readBytes(reader.stream);
    reader.addReference(result);
    return result;
  }

  static String readAsciiString(Reader reader) {
    final result = ValueReader.readAsciiString(reader.stream);
    reader.addReference(result);
    return result;
  }

  static String readString(Reader reader) {
    final result = ValueReader.readString(reader.stream);
    reader.addReference(result);
    return result;
  }

  static String readGuid(Reader reader) {
    final result = ValueReader.readGuid(reader.stream);
    reader.addReference(result);
    return result;
  }

  static DateTime readDateTime(Reader reader) {
    final result = ValueReader.readDateTime(reader.stream);
    reader.addReference(result);
    return result;
  }

  static DateTime readTime(Reader reader) {
    final result = ValueReader.readTime(reader.stream);
    reader.addReference(result);
    return result;
  }

  static List<T> readList<T>(Reader reader) {
    final stream = reader.stream;
    final count = ValueReader.readCount(stream);
    final list = List<T>(count);
    reader.addReference(list);
    for (var i = 0; i < count; ++i) {
      list[i] = reader.deserialize<T>();
    }
    stream.readByte();
    return list;
  }

  static Set<T> readSet<T>(Reader reader) {
    final stream = reader.stream;
    final count = ValueReader.readCount(stream);
    final s = <T>{};
    reader.addReference(s);
    for (var i = 0; i < count; ++i) {
      s.add(reader.deserialize<T>());
    }
    stream.readByte();
    return s;
  }

  static Map<K, V> readMap<K, V>(Reader reader) {
    final stream = reader.stream;
    final count = ValueReader.readCount(stream);
    final map = <K, V>{};
    reader.addReference(map);
    for (var i = 0; i < count; ++i) {
      final key = reader.deserialize<K>();
      final value = reader.deserialize<V>();
      map[key] = value;
    }
    stream.readByte();
    return map;
  }

  static dynamic readDynamicObject(Reader reader) {
    final stream = reader.stream;
    final index = ValueReader.readInt(stream, tag: TagOpenbrace);
    final typeInfo = reader.getTypeInfo(index);
    final obj = DynamicObject(typeInfo.name);
    reader.addReference(obj);
    final names = typeInfo.names;
    final types = typeInfo.types;
    final count = names.length;
    for (var i = 0; i < count; ++i) {
      obj[names[i]] = Deserializer.get(types[i].toString()).deserialize(reader);
    }
    stream.readByte();
    return obj;
  }

  static dynamic readObject(Reader reader, String type) {
    final obj = readDynamicObject(reader);
    final constructor = TypeManager.getConstructor(type);
    return constructor(obj);
  }

  static dynamic readMapAsDynamicObject(Reader reader) {
    final stream = reader.stream;
    final count = ValueReader.readCount(stream);
    final obj = DynamicObject();
    reader.addReference(obj);
    for (var i = 0; i < count; ++i) {
      final key = reader.deserialize<String>();
      final value = reader.deserialize();
      obj[key] = value;
    }
    stream.readByte();
    return obj;
  }

  static dynamic readMapAsObject(Reader reader, String type) {
    final obj = readMapAsDynamicObject(reader);
    final constructor = TypeManager.getConstructor(type);
    return constructor(obj);
  }
}
