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
| LastModified: Dec 31, 2019                               |
| Author: Ma Bingyao <andot@hprose.com>                    |
|                                                          |
\*________________________________________________________*/

part of hprose.io;

class ByteStreamDeserializer extends BaseDeserializer<ByteStream> {
  static final AbstractDeserializer<ByteStream> instance =
      ByteStreamDeserializer();
  @override
  ByteStream read(Reader reader, int tag) {
    final stream = reader.stream;
    switch (tag) {
      case TagBytes:
        return ByteStream.fromUint8List(ReferenceReader.readBytes(reader));
      case TagEmpty:
        return ByteStream(0);
      case TagString:
        return ByteStream.fromString(ReferenceReader.readString(reader));
      case TagUTF8Char:
        return ByteStream.fromString(stream.readString(1));
      case TagList:
        return ByteStream.fromUint8List(_readList(
            reader, (count) => Uint8List(count), IntDeserializer.instance));
      default:
        return super.read(reader, tag);
    }
  }
}
