/**********************************************************\
|                                                          |
|                          hprose                          |
|                                                          |
| Official WebSite: http://www.hprose.com/                 |
|                   http://www.hprose.org/                 |
|                                                          |
\**********************************************************/
/**********************************************************\
 *                                                        *
 * formatter.dart                                         *
 *                                                        *
 * hprose formatter for Dart.                             *
 *                                                        *
 * LastModified: Mar 3, 2015                              *
 * Author: Ma Bingyao <andot@hprose.com>                  *
 *                                                        *
\**********************************************************/
part of hprose.io;

BytesIO serialize(dynamic value, [bool simple = false]) {
  BytesIO bytes = new BytesIO();
  Writer writer = new Writer(bytes, simple);
  writer.serialize(value);
  return bytes;
}

dynamic unserialize(BytesIO bytes, [bool simple = false]) {
  return new Reader(bytes, simple).unserialize();
}

BytesIO _serialize(dynamic value, [bool simple = false]) {
  return serialize(value, simple);
}

dynamic _unserialize(BytesIO bytes, [bool simple = false]) {
  return unserialize(bytes, simple);
}

abstract class Formatter {
  static Uint8List serialize(dynamic value, [bool simple = false]) {
    return _serialize(value, simple).takeBytes();
  }
  static dynamic unserialize(Uint8List bytes, [bool simple = false]) {
    return _unserialize(new BytesIO(bytes), simple);
  }
}

