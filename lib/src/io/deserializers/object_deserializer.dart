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

class ObjectDeserializer extends BaseDeserializer {
  final String name;
  ObjectDeserializer(this.name);
  @override
  dynamic read(Reader reader, int tag) {
    switch (tag) {
      case TagMap:
        return ReferenceReader.readMapAsObject(reader, name);
      case TagObject:
        return ReferenceReader.readObject(reader, name);
      default:
        return super.read(reader, tag);
    }
  }
}
