/*--------------------------------------------------------*\
|                                                          |
|                          hprose                          |
|                                                          |
| Official WebSite: https://hprose.com                     |
|                                                          |
| function_deserializer.dart                               |
|                                                          |
| hprose FunctionDeserializer for Dart.                    |
|                                                          |
| LastModified: Dec 31, 2019                               |
| Author: Ma Bingyao <andot@hprose.com>                    |
|                                                          |
\*________________________________________________________*/

part of hprose.io;

class FunctionDeserializer extends BaseDeserializer<Function> {
  static final AbstractDeserializer<Function> instance = FunctionDeserializer();
}
