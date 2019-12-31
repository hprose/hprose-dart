/*--------------------------------------------------------*\
|                                                          |
|                          hprose                          |
|                                                          |
| Official WebSite: https://hprose.com                     |
|                                                          |
| int_serializer.ts                                        |
|                                                          |
| hprose int Serializer for Dart.                          |
|                                                          |
| LastModified: Dec 31, 2019                               |
| Author: Ma Bingyao <andot@hprose.com>                    |
|                                                          |
\*________________________________________________________*/

part of hprose.io;

class NumSerializer extends BaseSerializer<num> {
  static final AbstractSerializer<num> instance = NumSerializer();
  @override
  void write(Writer writer, num value) => value is int
      ? ValueWriter.writeInteger(writer.stream, value)
      : ValueWriter.writeDouble(writer.stream, value);
}
