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

class IntSerializer extends BaseSerializer<int> {
  static final AbstractSerializer<int> instance = IntSerializer();
  @override
  void write(Writer writer, int value) =>
      ValueWriter.writeInteger(writer.stream, value);
}
