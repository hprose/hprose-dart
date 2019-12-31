/*--------------------------------------------------------*\
|                                                          |
|                          hprose                          |
|                                                          |
| Official WebSite: https://hprose.com                     |
|                                                          |
| bigint_deserializer.dart                                 |
|                                                          |
| hprose BigIntDeserializer for Dart.                      |
|                                                          |
| LastModified: Dec 31, 2019                               |
| Author: Ma Bingyao <andot@hprose.com>                    |
|                                                          |
\*________________________________________________________*/

part of hprose.io;

class BigIntDeserializer extends BaseDeserializer<BigInt> {
  static final AbstractDeserializer<BigInt> instance = BigIntDeserializer();
  @override
  BigInt read(Reader reader, int tag) {
    if (tag >= 0x30 && tag <= 0x39) {
      return BigInt.from(tag - 0x30);
    }
    final stream = reader.stream;
    switch (tag) {
      case TagInteger:
      case TagLong:
        return BigInt.from(ValueReader.readInt(stream));
      case TagDouble:
        return BigInt.from(ValueReader.readDouble(stream));
      case TagTrue:
        return BigInt.one;
      case TagFalse:
      case TagEmpty:
        return BigInt.zero;
      case TagString:
        return BigInt.parse(ReferenceReader.readString(reader));
      case TagUTF8Char:
        return BigInt.from(stream.readString(1).codeUnitAt(1));
      case TagDate:
        return BigInt.from(
            ReferenceReader.readDateTime(reader).millisecondsSinceEpoch);
      case TagTime:
        return BigInt.from(
            ReferenceReader.readTime(reader).millisecondsSinceEpoch);
      default:
        return super.read(reader, tag);
    }
  }
}
