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
 * LastModified: Feb 14, 2016                             *
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

  static dynamic unserialize(dynamic bytes, [bool simple = false]) {
    if (bytes is! BytesIO) {
      bytes = new BytesIO(bytes);
    }
    return new Reader(bytes, simple).unserialize();
  }
}

Uint8List serialize(dynamic value, [bool simple = false]) {
  return Formatter.serialize(value, simple).bytes;
}
dynamic unserialize(dynamic bytes, [bool simple = false]) {
  return Formatter.unserialize(bytes, simple);
}
