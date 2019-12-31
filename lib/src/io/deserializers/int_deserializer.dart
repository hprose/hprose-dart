/*--------------------------------------------------------*\
|                                                          |
|                          hprose                          |
|                                                          |
| Official WebSite: https://hprose.com                     |
|                                                          |
| int_serializer.dart                                      |
|                                                          |
| hprose IntDeserializer for Dart.                         |
|                                                          |
| LastModified: Dec 31, 2019                               |
| Author: Ma Bingyao <andot@hprose.com>                    |
|                                                          |
\*________________________________________________________*/

part of hprose.io;

class IntDeserializer extends BaseDeserializer<int> {
  static final AbstractDeserializer<int> instance = IntDeserializer();
  @override
  int read(Reader reader, int tag) {
    if (tag >= 0x30 && tag <= 0x39) {
      return tag - 0x30;
    }
    final stream = reader.stream;
    switch (tag) {
      case TagInteger:
      case TagLong:
        return ValueReader.readInt(stream);
      case TagDouble:
        return (ValueReader.readDouble(stream)).floor();
      case TagTrue:
        return 1;
      case TagFalse:
      case TagEmpty:
        return 0;
      case TagString:
        return int.parse(ReferenceReader.readString(reader));
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
