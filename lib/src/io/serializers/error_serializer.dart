/*--------------------------------------------------------*\
|                                                          |
|                          hprose                          |
|                                                          |
| Official WebSite: https://hprose.com                     |
|                                                          |
| error_serializer.ts                                      |
|                                                          |
| hprose Error Serializer for Dart.                        |
|                                                          |
| LastModified: Feb 14, 2019                               |
| Author: Ma Bingyao <andot@hprose.com>                    |
|                                                          |
\*________________________________________________________*/

part of hprose.io;

class ErrorSerializer extends ReferenceSerializer<dynamic> {
  static final AbstractSerializer instance = new ErrorSerializer();
  @override
  void write(Writer writer, dynamic value) {
    // No reference to Error
    writer.addReferenceCount(1);
    final stream = writer.stream;
    stream.writeByte(TagError);
    stream.writeByte(TagString);
    ValueWriter.writeStringBody(stream, value.toString());
  }
}
