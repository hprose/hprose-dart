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

class IntSerializer extends BaseSerializer<int> {
  static final AbstractSerializer<int> instance = new IntSerializer();
  void write(Writer writer, int value) => writeInteger(writer.stream, value);
}
