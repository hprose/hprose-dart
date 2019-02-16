/*--------------------------------------------------------*\
|                                                          |
|                          hprose                          |
|                                                          |
| Official WebSite: https://hprose.com                     |
|                                                          |
| datetime_serializer.ts                                   |
|                                                          |
| hprose DateTime Serializer for Dart.                     |
|                                                          |
| LastModified: Feb 14, 2019                               |
| Author: Ma Bingyao <andot@hprose.com>                    |
|                                                          |
\*________________________________________________________*/

part of hprose.io;

class DateTimeSerializer extends ReferenceSerializer<DateTime> {
  static final AbstractSerializer<DateTime> instance = new DateTimeSerializer();
  @override
  void write(Writer writer, DateTime value) {
    super.write(writer, value);
    writeDateTime(writer.stream, value);
  }
}
