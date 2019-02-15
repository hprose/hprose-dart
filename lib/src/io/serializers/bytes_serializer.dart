/*--------------------------------------------------------*\
|                                                          |
|                          hprose                          |
|                                                          |
| Official WebSite: https://hprose.com                     |
|                                                          |
| bytes_serializer.ts                                      |
|                                                          |
| hprose bytes Serializer for Dart.                        |
|                                                          |
| LastModified: Feb 14, 2019                               |
| Author: Ma Bingyao <andot@hprose.com>                    |
|                                                          |
\*________________________________________________________*/

part of hprose.io;

class BytesSerializer extends ReferenceSerializer<dynamic> {
  static final AbstractSerializer instance = new BytesSerializer();
  void write(Writer writer, dynamic value) {
    super.write(writer, value);
    final stream = writer.stream;
    stream.writeByte(TagBytes);
    final n = (value is ByteBuffer) ? value.lengthInBytes : value.length;
    if (n > 0) stream.writeAsciiString(n.toString());
    stream.writeByte(TagQuote);
    stream.write(value);
    stream.writeByte(TagQuote);
  }
}