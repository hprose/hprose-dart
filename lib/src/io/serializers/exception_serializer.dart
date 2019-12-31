/*--------------------------------------------------------*\
|                                                          |
|                          hprose                          |
|                                                          |
| Official WebSite: https://hprose.com                     |
|                                                          |
| exception_serializer.ts                                  |
|                                                          |
| hprose ExceptionSerializer for Dart.                     |
|                                                          |
| LastModified: Dec 31, 2019                               |
| Author: Ma Bingyao <andot@hprose.com>                    |
|                                                          |
\*________________________________________________________*/

part of hprose.io;

class ExceptionSerializer extends ReferenceSerializer<dynamic> {
  static final AbstractSerializer instance = ExceptionSerializer();
  @override
  void write(Writer writer, dynamic value) {
    // No reference to Exception
    writer.addReferenceCount(1);
    final stream = writer.stream;
    stream.writeByte(TagError);
    stream.writeByte(TagString);
    String message;
    try {
      message = value.message;
    } catch (e) {
      message = value.toString();
    }
    ValueWriter.writeStringBody(stream, message);
  }
}
