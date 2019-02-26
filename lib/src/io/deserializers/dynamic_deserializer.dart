/*--------------------------------------------------------*\
|                                                          |
|                          hprose                          |
|                                                          |
| Official WebSite: https://hprose.com                     |
|                                                          |
| dynamic_deserializer.dart                                |
|                                                          |
| hprose DynamicDeserializer for Dart.                     |
|                                                          |
| LastModified: Feb 17, 2019                               |
| Author: Ma Bingyao <andot@hprose.com>                    |
|                                                          |
\*________________________________________________________*/

part of hprose.io;

class DynamicDeserializer extends BaseDeserializer {
  static final AbstractDeserializer instance = new DynamicDeserializer();
  @override
  read(Reader reader, int tag) {
    if (tag >= 0x30 && tag <= 0x39) {
      return tag - 0x30;
    }
    final stream = reader.stream;
    switch (tag) {
      case TagInteger:
        return ValueReader.readInt(stream);
      case TagLong:
        switch (reader.longType) {
          case LongType.Int:
            return ValueReader.readInt(stream);
          case LongType.BigInt:
            return BigInt.parse(stream.readUntil(TagSemicolon));
          case LongType.String:
            return stream.readUntil(TagSemicolon);
        }
        break;
      case TagDouble:
        return ValueReader.readDouble(stream);
      case TagString:
        return ReferenceReader.readString(reader);
      case TagBytes:
        return ReferenceReader.readBytes(reader);
      case TagTrue:
        return true;
      case TagFalse:
        return false;
      case TagEmpty:
        return '';
      case TagNaN:
        return double.nan;
      case TagInfinity:
        return ValueReader.readInfinity(stream);
      case TagDate:
        return ReferenceReader.readDateTime(reader);
      case TagTime:
        return ReferenceReader.readTime(reader);
      case TagGuid:
        return ReferenceReader.readGuid(reader);
      case TagUTF8Char:
        return stream.readString(1);
      case TagList:
        return ReferenceReader.readList(reader);
      case TagMap:
        return ReferenceReader.readMap(reader);
      case TagObject:
        final DynamicObject obj = ReferenceReader.readDynamicObject(reader);
        final constructor = TypeManager.getConstructor(obj.getName());
        if (constructor != null) {
          return constructor(obj);
        }
        return obj;
      case TagError:
        return new Exception(reader.deserialize<String>());
      default:
        return super.read(reader, tag);
    }
  }
}
