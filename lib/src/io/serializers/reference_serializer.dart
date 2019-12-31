/*--------------------------------------------------------*\
|                                                          |
|                          hprose                          |
|                                                          |
| Official WebSite: https://hprose.com                     |
|                                                          |
| reference_serializer.ts                                  |
|                                                          |
| hprose reference Serializer for Dart.                    |
|                                                          |
| LastModified: Dec 31, 2019                               |
| Author: Ma Bingyao <andot@hprose.com>                    |
|                                                          |
\*________________________________________________________*/

part of hprose.io;

class ReferenceSerializer<T> extends BaseSerializer<T> {
  @override
  void write(Writer writer, T value) => writer.setReference(value);
  @override
  void serialize(Writer writer, T value) {
    if (!writer.writeReference(value)) write(writer, value);
  }
}
