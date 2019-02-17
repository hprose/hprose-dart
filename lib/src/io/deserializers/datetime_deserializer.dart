/*--------------------------------------------------------*\
|                                                          |
|                          hprose                          |
|                                                          |
| Official WebSite: https://hprose.com                     |
|                                                          |
| datetime_serializer.dart                                 |
|                                                          |
| hprose DateTimeDeserializer for Dart.                    |
|                                                          |
| LastModified: Feb 16, 2019                               |
| Author: Ma Bingyao <andot@hprose.com>                    |
|                                                          |
\*________________________________________________________*/

part of hprose.io;

class DateTimeDeserializer extends BaseDeserializer<DateTime> {
  static final AbstractDeserializer<DateTime> instance =
      new DateTimeDeserializer();
  @override
  DateTime read(Reader reader, int tag) {
    final stream = reader.stream;
    switch (tag) {
      case TagDate:
        return ReferenceReader.readDateTime(reader);
      case TagTime:
        return ReferenceReader.readTime(reader);
      case TagInteger:
      case TagLong:
        return new DateTime.fromMillisecondsSinceEpoch(
            ValueReader.readInt(stream));
      case TagDouble:
        return new DateTime.fromMillisecondsSinceEpoch(
            ValueReader.readDouble(stream).floor());
      case TagString:
        return DateTime.parse(ReferenceReader.readString(reader));
      case TagTrue:
        return new DateTime.fromMillisecondsSinceEpoch(1);
      case TagFalse:
      case TagEmpty:
        return new DateTime.fromMillisecondsSinceEpoch(0);
      default:
        if (tag >= 0x30 && tag <= 0x39) {
          return new DateTime.fromMillisecondsSinceEpoch(tag - 0x30);
        }
        return super.read(reader, tag);
    }
  }
}
