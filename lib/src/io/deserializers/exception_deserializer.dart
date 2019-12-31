/*--------------------------------------------------------*\
|                                                          |
|                          hprose                          |
|                                                          |
| Official WebSite: https://hprose.com                     |
|                                                          |
| exception_deserializer.dart                              |
|                                                          |
| hprose ExceptionDeserializer for Dart.                   |
|                                                          |
| LastModified: Dec 31, 2019                               |
| Author: Ma Bingyao <andot@hprose.com>                    |
|                                                          |
\*________________________________________________________*/

part of hprose.io;

class ExceptionDeserializer extends BaseDeserializer<Exception> {
  static final AbstractDeserializer instance = ExceptionDeserializer();
  @override
  Exception read(Reader reader, int tag) {
    switch (tag) {
      case TagError:
        return Exception(reader.deserialize<String>());
      default:
        return super.read(reader, tag);
    }
  }
}
