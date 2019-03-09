/*--------------------------------------------------------*\
|                                                          |
|                          hprose                          |
|                                                          |
| Official WebSite: https://hprose.com                     |
|                                                          |
| value_reader.dart                                        |
|                                                          |
| hprose value reader for Dart.                            |
|                                                          |
| LastModified: Feb 16, 2019                               |
| Author: Ma Bingyao <andot@hprose.com>                    |
|                                                          |
\*________________________________________________________*/

part of hprose.io;

class ValueReader {
  static int readInt(ByteStream stream, {int tag: TagSemicolon}) {
    final s = stream.readUntil(tag);
    if (s.isEmpty) return 0;
    return int.parse(s, radix: 10);
  }

  static double readDouble(ByteStream stream) =>
      double.parse(stream.readUntil(TagSemicolon));

  static double readInfinity(ByteStream stream) =>
      ((stream.readByte() == TagNeg)
          ? double.negativeInfinity
          : double.infinity);

  static int readCount(ByteStream stream) {
    return readInt(stream, tag: TagOpenbrace);
  }

  static int readLength(ByteStream stream) {
    return readInt(stream, tag: TagQuote);
  }

  static String readString(ByteStream stream) {
    final n = readLength(stream);
    final result = stream.readString(n);
    stream.readByte();
    return result;
  }

  static Uint8List readBytes(ByteStream stream) {
    final n = readLength(stream);
    final result = stream.read(n);
    stream.readByte();
    return result;
  }

  static String readAsciiString(ByteStream stream) {
    final n = readLength(stream);
    final result = stream.readAsciiString(n);
    stream.readByte();
    return result;
  }

  static String readGuid(ByteStream stream) {
    stream.readByte();
    final result = stream.readAsciiString(36);
    stream.readByte();
    return result;
  }

  static int read4Digit(ByteStream stream) {
    var n = stream.readByte() - 0x30;
    n = n * 10 + stream.readByte() - 0x30;
    n = n * 10 + stream.readByte() - 0x30;
    return n * 10 + stream.readByte() - 0x30;
  }

  static int read2Digit(ByteStream stream) {
    var n = stream.readByte() - 0x30;
    return n * 10 + stream.readByte() - 0x30;
  }

  static List<int> readMillisecond(ByteStream stream) {
    var microsecond = 0;
    var millisecond = stream.readByte() - 0x30;
    millisecond = millisecond * 10 + stream.readByte() - 0x30;
    millisecond = millisecond * 10 + stream.readByte() - 0x30;
    var tag = stream.readByte();
    if ((tag >= 0x30) && (tag <= 0x39)) {
      microsecond = tag - 0x30;
      microsecond = microsecond * 10 + stream.readByte() - 0x30;
      microsecond = microsecond * 10 + stream.readByte() - 0x30;
      tag = stream.readByte();
      if ((tag >= 0x30) && (tag <= 0x39)) {
        stream.skip(2);
        tag = stream.readByte();
      }
    }
    return [millisecond, microsecond, tag];
  }

  static DateTime readTime(ByteStream stream) {
    final hour = read2Digit(stream);
    final minute = read2Digit(stream);
    final second = read2Digit(stream);
    var millisecond = 0;
    var microsecond = 0;
    var tag = stream.readByte();
    if (tag == TagPoint) {
      final result = readMillisecond(stream);
      millisecond = result[0];
      microsecond = result[1];
      tag = result[2];
    }
    if (tag == TagUTC) {
      return new DateTime.utc(
          1970, 1, 1, hour, minute, second, millisecond, microsecond);
    }
    return new DateTime(
        1970, 1, 1, hour, minute, second, millisecond, microsecond);
  }

  static DateTime readDateTime(ByteStream stream) {
    final year = read4Digit(stream);
    final month = read2Digit(stream);
    final day = read2Digit(stream);
    var tag = stream.readByte();
    if (tag == TagTime) {
      final hour = read2Digit(stream);
      final minute = read2Digit(stream);
      final second = read2Digit(stream);
      var millisecond = 0;
      var microsecond = 0;
      tag = stream.readByte();
      if (tag == TagPoint) {
        final result = readMillisecond(stream);
        millisecond = result[0];
        microsecond = result[1];
        tag = result[2];
      }
      if (tag == TagUTC) {
        return new DateTime.utc(
            year, month, day, hour, minute, second, millisecond, microsecond);
      }
      return new DateTime(
          year, month, day, hour, minute, second, millisecond, microsecond);
    }
    if (tag == TagUTC) {
      return new DateTime.utc(year, month, day);
    }
    return new DateTime(year, month, day);
  }
}
