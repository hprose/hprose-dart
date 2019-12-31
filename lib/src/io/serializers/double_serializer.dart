/*--------------------------------------------------------*\
|                                                          |
|                          hprose                          |
|                                                          |
| Official WebSite: https://hprose.com                     |
|                                                          |
| double_serializer.ts                                     |
|                                                          |
| hprose double Serializer for Dart.                       |
|                                                          |
| LastModified: Dec 31, 2019                               |
| Author: Ma Bingyao <andot@hprose.com>                    |
|                                                          |
\*________________________________________________________*/

part of hprose.io;

class DoubleSerializer extends BaseSerializer<double> {
  static final AbstractSerializer<double> instance = DoubleSerializer();
  @override
  void write(Writer writer, double value) =>
      ValueWriter.writeDouble(writer.stream, value);
}
