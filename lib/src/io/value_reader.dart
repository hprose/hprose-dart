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
| LastModified: Feb 14, 2019                               |
| Author: Ma Bingyao <andot@hprose.com>                    |
|                                                          |
\*________________________________________________________*/

part of hprose.io;

int readInt(ByteStream stream, {int tag: TagSemicolon}) {
  final String s = stream.readUntil(tag);
  if (s.isEmpty) return 0;
  return int.parse(s, radix: 10);
}

double readDouble(ByteStream stream) =>
    double.parse(stream.readUntil(TagSemicolon));

double readInfinity(ByteStream stream) =>
    ((stream.readByte() == TagNeg) ? double.negativeInfinity : double.infinity);

int readCount(ByteStream stream) {
  return readInt(stream, tag: TagOpenbrace);
}

int readLength(ByteStream stream) {
  return readInt(stream, tag: TagQuote);
}

String readString(ByteStream stream) {
  final int n = readLength(stream);
  final String result = stream.readString(n);
  stream.readByte();
  return result;
}

Uint8List readBytes(ByteStream stream) {
  final int n = readLength(stream);
  final Uint8List result = stream.read(n);
  stream.readByte();
  return result;
}

String readAsciiString(ByteStream stream) {
  final int n = readLength(stream);
  final String result = stream.readAsciiString(n);
  stream.readByte();
  return result;
}

String readGuid(ByteStream stream) {
  stream.readByte();
  final String result = stream.readAsciiString(36);
  stream.readByte();
  return result;
}

int read4Digit(ByteStream stream) {
  int n = stream.readByte() - 0x30;
  n = n * 10 + stream.readByte() - 0x30;
  n = n * 10 + stream.readByte() - 0x30;
  return n * 10 + stream.readByte() - 0x30;
}

int read2Digit(ByteStream stream) {
  int n = stream.readByte() - 0x30;
  return n * 10 + stream.readByte() - 0x30;
}

List<int> readMillisecond(ByteStream stream) {
  int microsecond = 0;
  int millisecond = stream.readByte() - 0x30;
  millisecond = millisecond * 10 + stream.readByte() - 0x30;
  millisecond = millisecond * 10 + stream.readByte() - 0x30;
  int tag = stream.readByte();
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

DateTime readTime(ByteStream stream) {
  final int hour = read2Digit(stream);
  final int minute = read2Digit(stream);
  final int second = read2Digit(stream);
  int millisecond = 0;
  int microsecond = 0;
  int tag = stream.readByte();
  if (tag == TagPoint) {
    List<int> result = readMillisecond(stream);
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

DateTime readDateTime(ByteStream stream) {
  final int year = read4Digit(stream);
  final int month = read2Digit(stream);
  final int day = read2Digit(stream);
  int tag = stream.readByte();
  if (tag == TagTime) {
    final int hour = read2Digit(stream);
    final int minute = read2Digit(stream);
    final int second = read2Digit(stream);
    int millisecond = 0;
    int microsecond = 0;
    tag = stream.readByte();
    if (tag == TagPoint) {
      List<int> result = readMillisecond(stream);
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
