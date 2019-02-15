/*--------------------------------------------------------*\
|                                                          |
|                          hprose                          |
|                                                          |
| Official WebSite: https://hprose.com                     |
|                                                          |
| base_serializer.dart                                     |
|                                                          |
| hprose BaseSerializer for Dart.                          |
|                                                          |
| LastModified: Feb 14, 2019                               |
| Author: Ma Bingyao <andot@hprose.com>                    |
|                                                          |
\*________________________________________________________*/

part of hprose.io;

class BaseSerializer<T> implements AbstractSerializer<T> {
  static final AbstractSerializer instance = new BaseSerializer();
  void write(Writer writer, T value) => writer.stream.writeByte(TagNull);
  void serialize(Writer writer, T value) => write(writer, value);
}
