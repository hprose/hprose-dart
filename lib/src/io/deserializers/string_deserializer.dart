/*--------------------------------------------------------*\
|                                                          |
|                          hprose                          |
|                                                          |
| Official WebSite: https://hprose.com                     |
|                                                          |
| string_deserializer.dart                                 |
|                                                          |
| hprose StringDeserializer for Dart.                      |
|                                                          |
| LastModified: Feb 16, 2019                               |
| Author: Ma Bingyao <andot@hprose.com>                    |
|                                                          |
\*________________________________________________________*/

part of hprose.io;

class StringDeserializer extends BaseDeserializer<String> {
  static final AbstractDeserializer<String> instance = new StringDeserializer();
  @override
  String read(Reader reader, int tag) {
    if (tag >= 0x30 && tag <= 0x39) {
      return String.fromCharCode(tag);
    }
    final stream = reader.stream;
    switch (tag) {
      case TagInteger:
      case TagLong:
      case TagDouble:
        return stream.readUntil(TagSemicolon);
      case TagNaN:
        return 'NaN';
      case TagInfinity:
        return ValueReader.readInfinity(stream).toString();
      case TagTrue:
        return 'true';
      case TagFalse:
        return 'false';
      case TagEmpty:
        return '';
      case TagString:
        return ReferenceReader.readString(reader);
      case TagGuid:
        return ReferenceReader.readGuid(reader);
      case TagUTF8Char:
        return stream.readString(1);
      case TagBytes:
        return ReferenceReader.readAsciiString(reader);
      case TagDate:
        return ReferenceReader.readDateTime(reader).toString();
      case TagTime:
        return ReferenceReader.readTime(reader).toString();
      case TagList:
        return ReferenceReader.readList(reader).join('');
      default:
        return super.read(reader, tag);
    }
  }
}
