/*--------------------------------------------------------*\
|                                                          |
|                          hprose                          |
|                                                          |
| Official WebSite: https://hprose.com                     |
|                                                          |
| duration_serializer.ts                                   |
|                                                          |
| hprose Duration Serializer for Dart.                     |
|                                                          |
| LastModified: Dec 31, 2019                               |
| Author: Ma Bingyao <andot@hprose.com>                    |
|                                                          |
\*________________________________________________________*/

part of hprose.io;

class DurationSerializer extends BaseSerializer<Duration> {
  static final AbstractSerializer<Duration> instance = DurationSerializer();
  @override
  void write(Writer writer, Duration value) =>
      ValueWriter.writeInteger(writer.stream, value.inMicroseconds);
}
