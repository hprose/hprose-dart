/*--------------------------------------------------------*\
|                                                          |
|                          hprose                          |
|                                                          |
| Official WebSite: https://hprose.com                     |
|                                                          |
| double_deserializer.dart                                 |
|                                                          |
| hprose DoubleDeserializer for Dart.                      |
|                                                          |
| LastModified: Dec 31, 2019                               |
| Author: Ma Bingyao <andot@hprose.com>                    |
|                                                          |
\*________________________________________________________*/

part of hprose.io;

class DoubleDeserializer extends BaseDeserializer<double> {
  static final AbstractDeserializer<double> instance = DoubleDeserializer();
  @override
  double read(Reader reader, int tag) {
    if (tag >= 0x30 && tag <= 0x39) {
      return (tag - 0x30).toDouble();
    }
    final stream = reader.stream;
    switch (tag) {
      case TagInteger:
      case TagLong:
        return ValueReader.readInt(stream).toDouble();
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
        return stream.readString(1).codeUnitAt(1).toDouble();
      case TagDate:
        return ReferenceReader.readDateTime(reader)
            .millisecondsSinceEpoch
            .toDouble();
      case TagTime:
        return ReferenceReader.readTime(reader)
            .millisecondsSinceEpoch
            .toDouble();
      default:
        return super.read(reader, tag);
    }
  }
}
