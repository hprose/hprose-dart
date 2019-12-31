/*--------------------------------------------------------*\
|                                                          |
|                          hprose                          |
|                                                          |
| Official WebSite: https://hprose.com                     |
|                                                          |
| object_serializer.ts                                     |
|                                                          |
| hprose Object Serializer for Dart.                       |
|                                                          |
| LastModified: Dec 31, 2019                               |
| Author: Ma Bingyao <andot@hprose.com>                    |
|                                                          |
\*________________________________________________________*/

part of hprose.io;

class ObjectSerializer extends ReferenceSerializer {
  static final AbstractSerializer instance = ObjectSerializer();
  @override
  void write(Writer writer, dynamic value) {
    final stream = writer.stream;
    final Map<String, dynamic> data = value.toJson();
    final n = data.length;
    final name = TypeManager.getName(value.runtimeType.toString());
    final r = writer.writeClass(name, () {
      stream.writeByte(TagClass);
      ValueWriter.writeStringBody(stream, name);
      if (n > 0) stream.writeAsciiString(n.toString());
      stream.writeByte(TagOpenbrace);
      for (final k in data.keys) {
        stream.writeByte(TagString);
        ValueWriter.writeStringBody(stream, k);
      }
      stream.writeByte(TagClosebrace);
      writer.addReferenceCount(n);
    });
    super.write(writer, value);
    stream.writeByte(TagObject);
    stream.writeAsciiString(r.toString());
    stream.writeByte(TagOpenbrace);
    for (final v in data.values) {
      writer.serialize(v);
    }
    stream.writeByte(TagClosebrace);
  }
}
