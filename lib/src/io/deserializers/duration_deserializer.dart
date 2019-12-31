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
| LastModified: Dec 31, 2019                               |
| Author: Ma Bingyao <andot@hprose.com>                    |
|                                                          |
\*________________________________________________________*/

part of hprose.io;

class DurationDeserializer extends BaseDeserializer<Duration> {
  static final AbstractDeserializer<Duration> instance = DurationDeserializer();
  @override
  Duration read(Reader reader, int tag) {
    final stream = reader.stream;
    switch (tag) {
      case TagDate:
        return Duration(
            microseconds:
                ReferenceReader.readDateTime(reader).microsecondsSinceEpoch);
      case TagTime:
        return Duration(
            microseconds:
                ReferenceReader.readTime(reader).microsecondsSinceEpoch);
      case TagInteger:
      case TagLong:
        return Duration(microseconds: ValueReader.readInt(stream));
      case TagDouble:
        return Duration(microseconds: ValueReader.readDouble(stream).floor());
      default:
        if (tag >= 0x30 && tag <= 0x39) {
          return Duration(microseconds: tag - 0x30);
        }
        return super.read(reader, tag);
    }
  }
}
