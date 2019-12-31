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
| LastModified: Dec 31, 2019                               |
| Author: Ma Bingyao <andot@hprose.com>                    |
|                                                          |
\*________________________________________________________*/

part of hprose.io;

class BaseSerializer<T> implements AbstractSerializer<T> {
  static final AbstractSerializer instance = BaseSerializer();
  @override
  void write(Writer writer, T value) => writer.stream.writeByte(TagNull);
  @override
  void serialize(Writer writer, T value) => write(writer, value);
}
