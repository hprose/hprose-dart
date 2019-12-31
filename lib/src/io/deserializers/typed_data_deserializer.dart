/*--------------------------------------------------------*\
|                                                          |
|                          hprose                          |
|                                                          |
| Official WebSite: https://hprose.com                     |
|                                                          |
| typed_data_deserializer.dart                             |
|                                                          |
| hprose TypedData Deserializer for Dart.                  |
|                                                          |
| LastModified: Dec 31, 2019                               |
| Author: Ma Bingyao <andot@hprose.com>                    |
|                                                          |
\*________________________________________________________*/

part of hprose.io;

Int32x4 _readInt32x4(Reader reader) {
  final stream = reader.stream;
  final count = ValueReader.readCount(stream);
  if (count != 4) {
    throw Exception('Cannot convert List($count) to Int32x4.');
  }
  reader.addReference(null);
  final index = reader.lastReferenceIndex;
  final deserializer = IntDeserializer.instance;
  final x = deserializer.deserialize(reader);
  final y = deserializer.deserialize(reader);
  final z = deserializer.deserialize(reader);
  final w = deserializer.deserialize(reader);
  final value = Int32x4(x, y, z, w);
  reader.setReference(index, value);
  stream.readByte();
  return value;
}

Float32x4 _readFloat32x4(Reader reader) {
  final stream = reader.stream;
  final count = ValueReader.readCount(stream);
  if (count != 4) {
    throw Exception('Cannot convert List($count) to Float32x4.');
  }
  reader.addReference(null);
  final index = reader.lastReferenceIndex;
  final deserializer = DoubleDeserializer.instance;
  final x = deserializer.deserialize(reader);
  final y = deserializer.deserialize(reader);
  final z = deserializer.deserialize(reader);
  final w = deserializer.deserialize(reader);
  final value = Float32x4(x, y, z, w);
  reader.setReference(index, value);
  stream.readByte();
  return value;
}

Float64x2 _readFloat64x2(Reader reader) {
  final stream = reader.stream;
  final count = ValueReader.readCount(stream);
  if (count != 2) {
    throw Exception('Cannot convert List($count) to Float64x2.');
  }
  reader.addReference(null);
  final index = reader.lastReferenceIndex;
  final deserializer = DoubleDeserializer.instance;
  final x = deserializer.deserialize(reader);
  final y = deserializer.deserialize(reader);
  final value = Float64x2(x, y);
  reader.setReference(index, value);
  stream.readByte();
  return value;
}

class Uint8ListDeserializer extends BaseDeserializer<Uint8List> {
  static final _emptyList = Uint8List(0);
  static final AbstractDeserializer<Uint8List> instance =
      Uint8ListDeserializer();
  @override
  Uint8List read(Reader reader, int tag) {
    final stream = reader.stream;
    switch (tag) {
      case TagEmpty:
        return _emptyList;
      case TagBytes:
        return ReferenceReader.readBytes(reader);
      case TagString:
        return ByteStream.fromString(ReferenceReader.readString(reader)).bytes;
      case TagUTF8Char:
        return ByteStream.fromString(stream.readString(1)).bytes;
      case TagList:
        return _readList(
            reader, (count) => Uint8List(count), IntDeserializer.instance);
      default:
        return super.read(reader, tag);
    }
  }
}

class Int8ListDeserializer extends BaseDeserializer<Int8List> {
  static final _emptyList = Int8List(0);
  static final AbstractDeserializer<Int8List> instance = Int8ListDeserializer();
  @override
  Int8List read(Reader reader, int tag) {
    final stream = reader.stream;
    Uint8List bytes;
    switch (tag) {
      case TagEmpty:
        return _emptyList;
      case TagBytes:
        bytes = ReferenceReader.readBytes(reader);
        break;
      case TagString:
        bytes = ByteStream.fromString(ReferenceReader.readString(reader)).bytes;
        break;
      case TagUTF8Char:
        bytes = ByteStream.fromString(stream.readString(1)).bytes;
        break;
      case TagList:
        return _readList(
            reader, (count) => Int8List(count), IntDeserializer.instance);
      default:
        return super.read(reader, tag);
    }
    return Int8List.view(
        bytes.buffer, bytes.offsetInBytes, bytes.lengthInBytes);
  }
}

class Uint8ClampedListDeserializer extends BaseDeserializer<Uint8ClampedList> {
  static final _emptyList = Uint8ClampedList(0);
  static final AbstractDeserializer<Uint8ClampedList> instance =
      Uint8ClampedListDeserializer();
  @override
  Uint8ClampedList read(Reader reader, int tag) {
    final stream = reader.stream;
    Uint8List bytes;
    switch (tag) {
      case TagEmpty:
        return _emptyList;
      case TagBytes:
        bytes = ReferenceReader.readBytes(reader);
        break;
      case TagString:
        bytes = ByteStream.fromString(ReferenceReader.readString(reader)).bytes;
        break;
      case TagUTF8Char:
        bytes = ByteStream.fromString(stream.readString(1)).bytes;
        break;
      case TagList:
        return _readList(reader, (count) => Uint8ClampedList(count),
            IntDeserializer.instance);
      default:
        return super.read(reader, tag);
    }
    return Uint8ClampedList.view(
        bytes.buffer, bytes.offsetInBytes, bytes.lengthInBytes);
  }
}

class Int16ListDeserializer extends BaseDeserializer<Int16List> {
  static final _emptyList = Int16List(0);
  static final AbstractDeserializer<Int16List> instance =
      Int16ListDeserializer();
  @override
  Int16List read(Reader reader, int tag) {
    switch (tag) {
      case TagEmpty:
        return _emptyList;
      case TagList:
        return _readList(
            reader, (count) => Int16List(count), IntDeserializer.instance);
      default:
        return super.read(reader, tag);
    }
  }
}

class Int32ListDeserializer extends BaseDeserializer<Int32List> {
  static final _emptyList = Int32List(0);
  static final AbstractDeserializer<Int32List> instance =
      Int32ListDeserializer();
  @override
  Int32List read(Reader reader, int tag) {
    switch (tag) {
      case TagEmpty:
        return _emptyList;
      case TagList:
        return _readList(
            reader, (count) => Int32List(count), IntDeserializer.instance);
      default:
        return super.read(reader, tag);
    }
  }
}

class Int64ListDeserializer extends BaseDeserializer<Int64List> {
  static final _emptyList = Int64List(0);
  static final AbstractDeserializer<Int64List> instance =
      Int64ListDeserializer();
  @override
  Int64List read(Reader reader, int tag) {
    switch (tag) {
      case TagEmpty:
        return _emptyList;
      case TagList:
        return _readList(
            reader, (count) => Int64List(count), IntDeserializer.instance);
      default:
        return super.read(reader, tag);
    }
  }
}

class Uint16ListDeserializer extends BaseDeserializer<Uint16List> {
  static final _emptyList = Uint16List(0);
  static final AbstractDeserializer<Uint16List> instance =
      Uint16ListDeserializer();
  @override
  Uint16List read(Reader reader, int tag) {
    switch (tag) {
      case TagEmpty:
        return _emptyList;
      case TagList:
        return _readList(
            reader, (count) => Uint16List(count), IntDeserializer.instance);
      default:
        return super.read(reader, tag);
    }
  }
}

class Uint32ListDeserializer extends BaseDeserializer<Uint32List> {
  static final _emptyList = Uint32List(0);
  static final AbstractDeserializer<Uint32List> instance =
      Uint32ListDeserializer();
  @override
  Uint32List read(Reader reader, int tag) {
    switch (tag) {
      case TagEmpty:
        return _emptyList;
      case TagList:
        return _readList(
            reader, (count) => Uint32List(count), IntDeserializer.instance);
      default:
        return super.read(reader, tag);
    }
  }
}

class Uint64ListDeserializer extends BaseDeserializer<Uint64List> {
  static final _emptyList = Uint64List(0);
  static final AbstractDeserializer<Uint64List> instance =
      Uint64ListDeserializer();
  @override
  Uint64List read(Reader reader, int tag) {
    switch (tag) {
      case TagEmpty:
        return _emptyList;
      case TagList:
        return _readList(
            reader, (count) => Uint64List(count), IntDeserializer.instance);
      default:
        return super.read(reader, tag);
    }
  }
}

class Float32ListDeserializer extends BaseDeserializer<Float32List> {
  static final _emptyList = Float32List(0);
  static final AbstractDeserializer<Float32List> instance =
      Float32ListDeserializer();
  @override
  Float32List read(Reader reader, int tag) {
    switch (tag) {
      case TagEmpty:
        return _emptyList;
      case TagList:
        return _readList(
            reader, (count) => Float32List(count), DoubleDeserializer.instance);
      default:
        return super.read(reader, tag);
    }
  }
}

class Float64ListDeserializer extends BaseDeserializer<Float64List> {
  static final _emptyList = Float64List(0);
  static final AbstractDeserializer<Float64List> instance =
      Float64ListDeserializer();
  @override
  Float64List read(Reader reader, int tag) {
    switch (tag) {
      case TagEmpty:
        return _emptyList;
      case TagList:
        return _readList(
            reader, (count) => Float64List(count), DoubleDeserializer.instance);
      default:
        return super.read(reader, tag);
    }
  }
}

class Int32x4Deserializer extends BaseDeserializer<Int32x4> {
  static final _zero = Int32x4(0, 0, 0, 0);
  static final AbstractDeserializer<Int32x4> instance = Int32x4Deserializer();
  @override
  Int32x4 read(Reader reader, int tag) {
    switch (tag) {
      case TagEmpty:
        return _zero;
      case TagList:
        return _readInt32x4(reader);
      default:
        return super.read(reader, tag);
    }
  }
}

class Float32x4Deserializer extends BaseDeserializer<Float32x4> {
  static final AbstractDeserializer<Float32x4> instance =
      Float32x4Deserializer();
  @override
  Float32x4 read(Reader reader, int tag) {
    switch (tag) {
      case TagEmpty:
        return Float32x4.zero();
      case TagList:
        return _readFloat32x4(reader);
      default:
        return super.read(reader, tag);
    }
  }
}

class Float64x2Deserializer extends BaseDeserializer<Float64x2> {
  static final AbstractDeserializer<Float64x2> instance =
      Float64x2Deserializer();
  @override
  Float64x2 read(Reader reader, int tag) {
    switch (tag) {
      case TagEmpty:
        return Float64x2.zero();
      case TagList:
        return _readFloat64x2(reader);
      default:
        return super.read(reader, tag);
    }
  }
}

class Int32x4ListDeserializer extends BaseDeserializer<Int32x4List> {
  static final _emptyList = Int32x4List(0);
  static final AbstractDeserializer<Int32x4List> instance =
      Int32x4ListDeserializer();
  @override
  Int32x4List read(Reader reader, int tag) {
    switch (tag) {
      case TagEmpty:
        return _emptyList;
      case TagList:
        return _readList(reader, (count) => Int32x4List(count),
            Int32x4Deserializer.instance);
      default:
        return super.read(reader, tag);
    }
  }
}

class Float32x4ListDeserializer extends BaseDeserializer<Float32x4List> {
  static final _emptyList = Float32x4List(0);
  static final AbstractDeserializer<Float32x4List> instance =
      Float32x4ListDeserializer();
  @override
  Float32x4List read(Reader reader, int tag) {
    switch (tag) {
      case TagEmpty:
        return _emptyList;
      case TagList:
        return _readList(reader, (count) => Float32x4List(count),
            Float32x4Deserializer.instance);
      default:
        return super.read(reader, tag);
    }
  }
}

class Float64x2ListDeserializer extends BaseDeserializer<Float64x2List> {
  static final _emptyList = Float64x2List(0);
  static final AbstractDeserializer<Float64x2List> instance =
      Float64x2ListDeserializer();
  @override
  Float64x2List read(Reader reader, int tag) {
    switch (tag) {
      case TagEmpty:
        return _emptyList;
      case TagList:
        return _readList(reader, (count) => Float64x2List(count),
            Float64x2Deserializer.instance);
      default:
        return super.read(reader, tag);
    }
  }
}
