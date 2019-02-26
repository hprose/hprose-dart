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
| LastModified: Feb 27, 2019                               |
| Author: Ma Bingyao <andot@hprose.com>                    |
|                                                          |
\*________________________________________________________*/

part of hprose.io;

class ExceptionDeserializer extends BaseDeserializer<Exception> {
  static final AbstractDeserializer instance = new ExceptionDeserializer();
  @override
  read(Reader reader, int tag) {
    switch (tag) {
      case TagError:
        return new Exception(reader.deserialize<String>());
      default:
        return super.read(reader, tag);
    }
  }
}
