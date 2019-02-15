/*--------------------------------------------------------*\
|                                                          |
|                          hprose                          |
|                                                          |
| Official WebSite: https://hprose.com                     |
|                                                          |
| dynamic_object_serializer.ts                             |
|                                                          |
| hprose DynamicObject Serializer for Dart.                |
|                                                          |
| LastModified: Feb 15, 2019                               |
| Author: Ma Bingyao <andot@hprose.com>                    |
|                                                          |
\*________________________________________________________*/

part of hprose.io;

class DynamicObjectSerializer extends ReferenceSerializer<DynamicObject> {
  static final AbstractSerializer instance = new DynamicObjectSerializer();
  void write(Writer writer, DynamicObject value) {
    final stream = writer.stream;
    final n = value.length;
    final name = value.getName();
    final r = writer.writeClass(name, () {
      stream.writeByte(TagClass);
      writeStringBody(stream, name);
      if (n > 0) stream.writeAsciiString(n.toString());
      stream.writeByte(TagOpenbrace);
      for (final k in value.keys) {
        stream.writeByte(TagString);
        writeStringBody(stream, k);
      }
      stream.writeByte(TagClosebrace);
      writer.addReferenceCount(n);
    });
    super.write(writer, value);
    stream.writeByte(TagObject);
    stream.writeAsciiString(r.toString());
      stream.writeByte(TagOpenbrace);
      for (final v in value.values) {
        writer.serialize(v);
      }
      stream.writeByte(TagClosebrace);
  }
}
