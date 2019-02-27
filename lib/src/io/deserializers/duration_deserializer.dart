/*--------------------------------------------------------*\
|                                                          |
|                          hprose                          |
|                                                          |
| Official WebSite: https://hprose.com                     |
|                                                          |
| duration_serializer.dart                                 |
|                                                          |
| hprose DurationDeserializer for Dart.                    |
|                                                          |
| LastModified: Feb 27, 2019                               |
| Author: Ma Bingyao <andot@hprose.com>                    |
|                                                          |
\*________________________________________________________*/

part of hprose.io;

class DurationDeserializer extends BaseDeserializer<Duration> {
  static final AbstractDeserializer<Duration> instance =
      new DurationDeserializer();
  @override
  Duration read(Reader reader, int tag) {
    final stream = reader.stream;
    switch (tag) {
      case TagDate:
        return new Duration(
            microseconds:
                ReferenceReader.readDateTime(reader).microsecondsSinceEpoch);
      case TagTime:
        return new Duration(
            microseconds:
                ReferenceReader.readTime(reader).microsecondsSinceEpoch);
      case TagInteger:
      case TagLong:
        return new Duration(microseconds: ValueReader.readInt(stream));
      case TagDouble:
        return new Duration(
            microseconds: ValueReader.readDouble(stream).floor());
      default:
        if (tag >= 0x30 && tag <= 0x39) {
          return new Duration(microseconds: tag - 0x30);
        }
        return super.read(reader, tag);
    }
  }
}
