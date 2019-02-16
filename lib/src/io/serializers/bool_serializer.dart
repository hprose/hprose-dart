/*--------------------------------------------------------*\
|                                                          |
|                          hprose                          |
|                                                          |
| Official WebSite: https://hprose.com                     |
|                                                          |
| bool_serializer.ts                                       |
|                                                          |
| hprose bool Serializer for Dart.                         |
|                                                          |
| LastModified: Feb 14, 2019                               |
| Author: Ma Bingyao <andot@hprose.com>                    |
|                                                          |
\*________________________________________________________*/

part of hprose.io;

class BoolSerializer extends BaseSerializer<bool> {
  static final AbstractSerializer<bool> instance = new BoolSerializer();
  @override
  void write(Writer writer, bool value) =>
      writer.stream.writeByte(value ? TagTrue : TagFalse);
}
