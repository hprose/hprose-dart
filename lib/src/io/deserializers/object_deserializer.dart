/*--------------------------------------------------------*\
|                                                          |
|                          hprose                          |
|                                                          |
| Official WebSite: https://hprose.com                     |
|                                                          |
| object_deserializer.dart                                 |
|                                                          |
| hprose ObjectDeserializer for Dart.                      |
|                                                          |
| LastModified: Feb 26, 2019                               |
| Author: Ma Bingyao <andot@hprose.com>                    |
|                                                          |
\*________________________________________________________*/

part of hprose.io;

class ObjectDeserializer<T> extends BaseDeserializer<T> {
  ObjectDeserializer(String type) :super(type);
  @override
  T read(Reader reader, int tag) {
    switch (tag) {
      case TagMap:
        return ReferenceReader.readMapAsObject(reader, type);
      case TagObject:
        return ReferenceReader.readObject(reader, type);
      default:
        return super.read(reader, tag);
    }
  }
}
