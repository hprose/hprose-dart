/*--------------------------------------------------------*\
|                                                          |
|                          hprose                          |
|                                                          |
| Official WebSite: https://hprose.com                     |
|                                                          |
| typed_data_serializer.ts                                 |
|                                                          |
| hprose TypedData Serializer for Dart.                    |
|                                                          |
| LastModified: Dec 31, 2019                               |
| Author: Ma Bingyao <andot@hprose.com>                    |
|                                                          |
\*________________________________________________________*/

part of hprose.io;

class Int32x4Serializer extends ReferenceSerializer<Int32x4> {
  static final AbstractSerializer<Int32x4> instance = Int32x4Serializer();
  @override
  void write(Writer writer, Int32x4 value) {
    super.write(writer, value);
    final stream = writer.stream;
    stream.writeByte(TagList);
    stream.writeByte(0x34);
    stream.writeByte(TagOpenbrace);
    final serializer = IntSerializer.instance;
    serializer.serialize(writer, value.x);
    serializer.serialize(writer, value.y);
    serializer.serialize(writer, value.z);
    serializer.serialize(writer, value.w);
    stream.writeByte(TagClosebrace);
  }
}

class Float32x4Serializer extends ReferenceSerializer<Float32x4> {
  static final AbstractSerializer<Float32x4> instance = Float32x4Serializer();
  @override
  void write(Writer writer, Float32x4 value) {
    super.write(writer, value);
    final stream = writer.stream;
    stream.writeByte(TagList);
    stream.writeByte(0x34);
    stream.writeByte(TagOpenbrace);
    final serializer = DoubleSerializer.instance;
    serializer.serialize(writer, value.x);
    serializer.serialize(writer, value.y);
    serializer.serialize(writer, value.z);
    serializer.serialize(writer, value.w);
    stream.writeByte(TagClosebrace);
  }
}

class Float64x2Serializer extends ReferenceSerializer<Float64x2> {
  static final AbstractSerializer<Float64x2> instance = Float64x2Serializer();
  @override
  void write(Writer writer, Float64x2 value) {
    super.write(writer, value);
    final stream = writer.stream;
    stream.writeByte(TagList);
    stream.writeByte(0x32);
    stream.writeByte(TagOpenbrace);
    final serializer = DoubleSerializer.instance;
    serializer.serialize(writer, value.x);
    serializer.serialize(writer, value.y);
    stream.writeByte(TagClosebrace);
  }
}
