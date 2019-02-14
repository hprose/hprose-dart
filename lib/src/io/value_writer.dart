/*--------------------------------------------------------*\
|                                                          |
|                          hprose                          |
|                                                          |
| Official WebSite: https://hprose.com                     |
|                                                          |
| value_writer.dart                                        |
|                                                          |
| hprose value writer for Dart.                            |
|                                                          |
| LastModified: Feb 14, 2019                               |
| Author: Ma Bingyao <andot@hprose.com>                    |
|                                                          |
\*________________________________________________________*/

part of hprose.io;

final BigInt _zero = BigInt.zero;
final BigInt _nine = new BigInt.from(9);

void writeInteger(ByteStream stream, int value) {
  if (0 <= value && value <= 9) {
    stream.writeByte(0x30 + value);
  } else {
    if (value < -2147483648 || value > 2147483647) {
      stream.writeByte(TagLong);
    } else {
      stream.writeByte(TagInteger);
    }
    stream.writeAsciiString(value.toString());
    stream.writeByte(TagSemicolon);
  }
}

void writeDouble(ByteStream stream, double value) {
  if (value.isNaN) {
    stream.writeByte(TagNaN);
  } else if (value.isFinite) {
    stream.writeByte(TagDouble);
    stream.writeAsciiString(value.toString());
    stream.writeByte(TagSemicolon);
  } else {
    stream.writeByte(TagInfinity);
    stream.writeByte((value > 0) ? TagPos : TagNeg);
  }
}

void writeBigInt(ByteStream stream, BigInt value) {
  if (_zero <= value && value <= _nine) {
    stream.writeByte(0x30 + value.toInt());
  } else {
    stream.writeByte(TagLong);
    stream.writeAsciiString(value.toString());
    stream.writeByte(TagSemicolon);
  }
}

void writeStringBody(ByteStream stream, String value) {
  final int n = value.length;
  if (n > 0) stream.writeAsciiString(n.toString());
  stream.writeByte(TagQuote);
  stream.writeString(value);
  stream.writeByte(TagQuote);
}

void writeDateTime(ByteStream stream, DateTime value) {
  final int year = value.year;
  final int month = value.month;
  final int day = value.day;
  final int hour = value.hour;
  final int minute = value.minute;
  final int second = value.second;
  final int millisecond = value.millisecond;
  final int microsecond = value.microsecond;
  if ((hour == 0) &&
      (minute == 0) &&
      (second == 0) &&
      (millisecond == 0) &&
      (microsecond == 0)) {
    _writeDate(stream, year, month, day);
  } else if ((year == 1970) && (month == 1) && (day == 1)) {
    _writeTime(stream, hour, minute, second, millisecond, microsecond);
  } else {
    _writeDate(stream, year, month, day);
    _writeTime(stream, hour, minute, second, millisecond, microsecond);
  }
  stream.writeByte(value.isUtc ? TagUTC : TagSemicolon);
}

void _writeDate(ByteStream stream, int year, int month, int day) {
  Uint8List date = new Uint8List(9);
  date[0] = TagDate;
  date[1] = 0x30 + (year ~/ 1000 % 10);
  date[2] = 0x30 + (year ~/ 100 % 10);
  date[3] = 0x30 + (year ~/ 10 % 10);
  date[4] = 0x30 + (year % 10);
  date[5] = 0x30 + (month ~/ 10 % 10);
  date[6] = 0x30 + (month % 10);
  date[7] = 0x30 + (day ~/ 10 % 10);
  date[8] = 0x30 + (day % 10);
  stream.write(date);
}

void _writeTime(ByteStream stream, int hour, int minute, int second,
    int millisecond, int microsecond) {
  Uint8List time = new Uint8List(14);
  time[0] = TagTime;
  time[1] = 0x30 + (hour ~/ 10 % 10);
  time[2] = 0x30 + (hour % 10);
  time[3] = 0x30 + (minute ~/ 10 % 10);
  time[4] = 0x30 + (minute % 10);
  time[5] = 0x30 + (second ~/ 10 % 10);
  time[6] = 0x30 + (second % 10);
  time[7] = TagPoint;
  time[8] = 0x30 + (millisecond ~/ 100 % 10);
  time[9] = 0x30 + (millisecond ~/ 10 % 10);
  time[10] = 0x30 + (millisecond % 10);
  time[11] = 0x30 + (microsecond ~/ 100 % 10);
  time[12] = 0x30 + (microsecond ~/ 10 % 10);
  time[13] = 0x30 + (microsecond % 10);
  if (microsecond == 0) {
    time = new Uint8List.view(time.buffer, 0, 11);
  }
  if (millisecond == 0) {
    time = new Uint8List.view(time.buffer, 0, 7);
  }
  stream.write(time);
}
