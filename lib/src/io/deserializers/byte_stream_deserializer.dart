/*--------------------------------------------------------*\
|                                                          |
|                          hprose                          |
|                                                          |
| Official WebSite: https://hprose.com                     |
|                                                          |
| byte_stream_deserializer.dart                            |
|                                                          |
| hprose ByteStreamDeserializer for Dart.                  |
|                                                          |
| LastModified: Feb 16, 2019                               |
| Author: Ma Bingyao <andot@hprose.com>                    |
|                                                          |
\*________________________________________________________*/

part of hprose.io;

class ByteStreamDeserializer extends BaseDeserializer<ByteStream> {
  static final AbstractDeserializer<ByteStream> instance =
      new ByteStreamDeserializer();
  @override
  ByteStream read(Reader reader, int tag) {
    final stream = reader.stream;
    switch (tag) {
      case TagBytes:
        return new ByteStream.fromUint8List(ReferenceReader.readBytes(reader));
      case TagEmpty:
        return new ByteStream(0);
      case TagString:
        return new ByteStream.fromString(ReferenceReader.readString(reader));
      case TagUTF8Char:
        return new ByteStream.fromString(stream.readString(1));
      case TagList:
        return new ByteStream.fromUint8List(_readList(
            reader, (count) => new Uint8List(count), IntDeserializer.instance));
      default:
        return super.read(reader, tag);
    }
  }
}
