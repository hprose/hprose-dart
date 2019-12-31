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
| LastModified: Dec 31, 2019                               |
| Author: Ma Bingyao <andot@hprose.com>                    |
|                                                          |
\*________________________________________________________*/

part of hprose.io;

class DateTimeSerializer extends ReferenceSerializer<DateTime> {
  static final AbstractSerializer<DateTime> instance = DateTimeSerializer();
  @override
  void write(Writer writer, DateTime value) {
    super.write(writer, value);
    ValueWriter.writeDateTime(writer.stream, value);
  }
}
