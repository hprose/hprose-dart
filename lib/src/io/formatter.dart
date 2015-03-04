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

abstract class Formatter {
  static BytesIO serialize(dynamic value, [bool simple = false]) {
    BytesIO bytes = new BytesIO();
    Writer writer = new Writer(bytes, simple);
    writer.serialize(value);
    return bytes;
  }

  static dynamic unserialize(BytesIO bytes, [bool simple = false]) {
    return new Reader(bytes, simple).unserialize();
  }
}

Uint8List serialize(dynamic value, [bool simple = false]) {
  return Formatter.serialize(value, simple).bytes;
}
dynamic unserialize(Uint8List bytes, [bool simple = false]) {
  return Formatter.unserialize(new BytesIO(bytes), simple);
}
