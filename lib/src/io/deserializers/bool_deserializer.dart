/*--------------------------------------------------------*\
|                                                          |
|                          hprose                          |
|                                                          |
| Official WebSite: https://hprose.com                     |
|                                                          |
| bool_deserializer.dart                                   |
|                                                          |
| hprose BoolDeserializer for Dart.                        |
|                                                          |
| LastModified: Feb 16, 2019                               |
| Author: Ma Bingyao <andot@hprose.com>                    |
|                                                          |
\*________________________________________________________*/

part of hprose.io;

class BoolDeserializer extends BaseDeserializer<bool> {
  static final AbstractDeserializer<bool> instance = new BoolDeserializer();
  @override
  bool read(Reader reader, int tag) {
    final stream = reader.stream;
    switch (tag) {
      case TagTrue:
        return true;
      case 0x30:
      case TagFalse:
      case TagEmpty:
      case TagNaN:
        return false;
      case TagInteger:
      case TagLong:
        return ValueReader.readInt(stream) != 0;
      case TagDouble:
        return ValueReader.readDouble(stream) != 0;
      case TagString:
        return bool.fromEnvironment(ReferenceReader.readString(reader));
      case TagUTF8Char:
        return '0\0'.indexOf(stream.readString(1)) == -1;
      case TagInfinity:
        stream.readByte();
        return true;
      default:
        if (tag >= 0x31 && tag <= 0x39) {
          return true;
        }
        return super.read(reader, tag);
    }
  }
}
