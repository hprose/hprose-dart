/*--------------------------------------------------------*\
|                                                          |
|                          hprose                          |
|                                                          |
| Official WebSite: https://hprose.com                     |
|                                                          |
| dynamic_object_deserializer.dart                         |
|                                                          |
| hprose DynamicObjectDeserializer for Dart.               |
|                                                          |
| LastModified: Feb 17, 2019                               |
| Author: Ma Bingyao <andot@hprose.com>                    |
|                                                          |
\*________________________________________________________*/

part of hprose.io;

class DynamicObjectDeserializer extends BaseDeserializer<DynamicObject> {
  static final AbstractDeserializer instance = new DynamicObjectDeserializer();
  @override
  DynamicObject read(Reader reader, int tag) {
    switch (tag) {
      case TagMap:
        return ReferenceReader.readMapAsDynamicObject(reader);
      case TagObject:
        return ReferenceReader.readDynamicObject(reader);
      default:
        return super.read(reader, tag);
    }
  }
}
