/*--------------------------------------------------------*\
|                                                          |
|                          hprose                          |
|                                                          |
| Official WebSite: https://hprose.com                     |
|                                                          |
| num_serializer.dart                                      |
|                                                          |
| hprose NumDeserializer for Dart.                         |
|                                                          |
| LastModified: Dec 31, 2019                               |
| Author: Ma Bingyao <andot@hprose.com>                    |
|                                                          |
\*________________________________________________________*/

part of hprose.io;

class NumDeserializer extends BaseDeserializer<num> {
  static final AbstractDeserializer<num> instance = NumDeserializer();
  @override
  num read(Reader reader, int tag) {
    if (tag >= 0x30 && tag <= 0x39) {
      return tag - 0x30;
    }
    final stream = reader.stream;
    switch (tag) {
      case TagInteger:
      case TagLong:
        return ValueReader.readInt(stream);
      case TagDouble:
        return ValueReader.readDouble(stream);
      case TagNaN:
        return double.nan;
      case TagInfinity:
        return ValueReader.readInfinity(stream);
      case TagTrue:
        return 1;
      case TagFalse:
      case TagEmpty:
        return 0;
      case TagString:
        return num.parse(ReferenceReader.readString(reader));
      case TagUTF8Char:
        return stream.readString(1).codeUnitAt(1);
      case TagDate:
        return ReferenceReader.readDateTime(reader).millisecondsSinceEpoch;
      case TagTime:
        return ReferenceReader.readTime(reader).millisecondsSinceEpoch;
      default:
        return super.read(reader, tag);
    }
  }
}
