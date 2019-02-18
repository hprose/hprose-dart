/*--------------------------------------------------------*\
|                                                          |
|                          hprose                          |
|                                                          |
| Official WebSite: https://hprose.com                     |
|                                                          |
| deserializer.dart                                        |
|                                                          |
| hprose Deserializer for Dart.                            |
|                                                          |
| LastModified: Feb 16, 2019                               |
| Author: Ma Bingyao <andot@hprose.com>                    |
|                                                          |
\*________________________________________________________*/

part of hprose.io;

Type typeof<T>() => T;

abstract class AbstractDeserializer<T> {
  T read(Reader reader, int tag);
  T deserialize(Reader reader);
}

class _Deserializer {
  final Map<String, AbstractDeserializer> _deserializers = {};

  _Deserializer() {
    register(DynamicDeserializer.instance);
    register<num>(NumDeserializer.instance);
    register<int>(IntDeserializer.instance);
    register<double>(DoubleDeserializer.instance);
    register<BigInt>(BigIntDeserializer.instance);
    register<bool>(BoolDeserializer.instance);
    register<String>(StringDeserializer.instance);
    register<DateTime>(DateTimeDeserializer.instance);
    register<Function>(FunctionDeserializer.instance);
    register<ByteStream>(ByteStreamDeserializer.instance);
    register<Int32x4>(Int32x4Deserializer.instance);
    register<Float32x4>(Float32x4Deserializer.instance);
    register<Float64x2>(Float64x2Deserializer.instance);
    register<Int8List>(Int8ListDeserializer.instance);
    register<Int16List>(Int16ListDeserializer.instance);
    register<Int32List>(Int32ListDeserializer.instance);
    register<Int64List>(Int64ListDeserializer.instance);
    register<Uint8List>(Uint8ListDeserializer.instance);
    register<Uint8ClampedList>(Uint8ClampedListDeserializer.instance);
    register<Uint16List>(Uint16ListDeserializer.instance);
    register<Uint32List>(Uint32ListDeserializer.instance);
    register<Uint64List>(Uint64ListDeserializer.instance);
    register<Float32List>(Float32ListDeserializer.instance);
    register<Float64List>(Float64ListDeserializer.instance);
    register<Int32x4List>(Int32x4ListDeserializer.instance);
    register<Float32x4List>(Float32x4ListDeserializer.instance);
    register<Float64x2List>(Float64x2ListDeserializer.instance);
    register<List>(ListDeserializer.instance);
    register<List<num>>(new ListDeserializer<num>());
    register<List<int>>(new ListDeserializer<int>());
    register<List<double>>(new ListDeserializer<double>());
    register<List<BigInt>>(new ListDeserializer<BigInt>());
    register<List<bool>>(new ListDeserializer<bool>());
    register<List<String>>(new ListDeserializer<String>());
    register<List<DateTime>>(new ListDeserializer<DateTime>());
    register<List<Uint8List>>(new ListDeserializer<Uint8List>());
    register<List<List>>(new ListDeserializer<List>());
    register<List<Map>>(new ListDeserializer<Map>());
    register<List<DynamicObject>>(new ListDeserializer<DynamicObject>());
    register<List<Map<String, dynamic>>>(
        new ListDeserializer<Map<String, dynamic>>());
    register<List<Map<int, dynamic>>>(
        new ListDeserializer<Map<int, dynamic>>());
    register<List<List<List>>>(new ListDeserializer<List<List>>());
    register<List<List<Map>>>(new ListDeserializer<List<Map>>());
    register<List<List<Map<String, dynamic>>>>(
        new ListDeserializer<List<Map<String, dynamic>>>());
    register<List<List<Map<int, dynamic>>>>(
        new ListDeserializer<List<Map<int, dynamic>>>());
    register<Set>(SetDeserializer.instance);
    register<Set<num>>(new SetDeserializer<num>());
    register<Set<int>>(new SetDeserializer<int>());
    register<Set<double>>(new SetDeserializer<double>());
    register<Set<String>>(new SetDeserializer<String>());
    register<Map>(MapDeserializer.instance);
    register<Map<int, dynamic>>(new MapDeserializer<int, dynamic>());
    register<Map<String, dynamic>>(new MapDeserializer<String, dynamic>());
    register<DynamicObject>(DynamicObjectDeserializer.instance);
  }

  void register<T>(AbstractDeserializer deserializer) {
    _deserializers[T.toString()] = deserializer;
  }

  AbstractDeserializer getInstance(Type type) {
    if (type == null) {
      return DynamicDeserializer.instance;
    }
    return _deserializers[type.toString()];
  }
}

final _Deserializer Deserializer = _Deserializer();
