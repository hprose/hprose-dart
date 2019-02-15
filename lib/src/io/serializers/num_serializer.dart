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
| LastModified: Feb 14, 2019                               |
| Author: Ma Bingyao <andot@hprose.com>                    |
|                                                          |
\*________________________________________________________*/

part of hprose.io;

class NumSerializer extends BaseSerializer<num> {
  static final AbstractSerializer<num> instance = new NumSerializer();
  void write(Writer writer, num value) => value is int
      ? writeInteger(writer.stream, value)
      : writeDouble(writer.stream, value);
}
