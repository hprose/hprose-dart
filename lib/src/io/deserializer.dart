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
| LastModified: Dec 31, 2019                               |
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
    register<Object>(DynamicDeserializer.instance);
    register<DynamicObject>(DynamicObjectDeserializer.instance);
    register<num>(NumDeserializer.instance);
    register<int>(IntDeserializer.instance);
    register<double>(DoubleDeserializer.instance);
    register<BigInt>(BigIntDeserializer.instance);
    register<Duration>(DurationDeserializer.instance);
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
    register<Exception>(ExceptionDeserializer.instance);
    register<List>(ListDeserializer.instance);
    register<List<Object>>(ListDeserializer<Object>());
    register<List<DynamicObject>>(ListDeserializer<DynamicObject>());
    register<List<num>>(ListDeserializer<num>());
    register<List<int>>(ListDeserializer<int>());
    register<List<double>>(ListDeserializer<double>());
    register<List<BigInt>>(ListDeserializer<BigInt>());
    register<List<bool>>(ListDeserializer<bool>());
    register<List<Duration>>(ListDeserializer<Duration>());
    register<List<String>>(ListDeserializer<String>());
    register<List<DateTime>>(ListDeserializer<DateTime>());
    register<List<Uint8List>>(ListDeserializer<Uint8List>());
    register<List<List>>(ListDeserializer<List>());
    register<List<List<Object>>>(ListDeserializer<List<Object>>());
    register<List<Map>>(ListDeserializer<Map>());
    register<List<Map<Object, dynamic>>>(
        ListDeserializer<Map<Object, dynamic>>());
    register<List<Map<Object, Object>>>(
        ListDeserializer<Map<Object, Object>>());
    register<List<Map<String, dynamic>>>(
        ListDeserializer<Map<String, dynamic>>());
    register<List<Map<String, Object>>>(
        ListDeserializer<Map<String, Object>>());
    register<List<Map<int, dynamic>>>(ListDeserializer<Map<int, dynamic>>());
    register<List<Map<int, Object>>>(ListDeserializer<Map<int, Object>>());
    register<List<List<List>>>(ListDeserializer<List<List>>());
    register<List<List<List<Object>>>>(ListDeserializer<List<List<Object>>>());
    register<List<List<Map>>>(ListDeserializer<List<Map>>());
    register<List<List<Map<Object, dynamic>>>>(
        ListDeserializer<List<Map<Object, dynamic>>>());
    register<List<List<Map<Object, Object>>>>(
        ListDeserializer<List<Map<Object, Object>>>());
    register<List<List<Map<String, dynamic>>>>(
        ListDeserializer<List<Map<String, dynamic>>>());
    register<List<List<Map<String, Object>>>>(
        ListDeserializer<List<Map<String, Object>>>());
    register<List<List<Map<int, dynamic>>>>(
        ListDeserializer<List<Map<int, dynamic>>>());
    register<List<List<Map<int, Object>>>>(
        ListDeserializer<List<Map<int, Object>>>());
    register<Set>(SetDeserializer.instance);
    register<Set<Object>>(SetDeserializer<Object>());
    register<Set<num>>(SetDeserializer<num>());
    register<Set<int>>(SetDeserializer<int>());
    register<Set<double>>(SetDeserializer<double>());
    register<Set<String>>(SetDeserializer<String>());
    register<Map>(MapDeserializer.instance);
    register<Map<Object, dynamic>>(MapDeserializer<Object, dynamic>());
    register<Map<Object, Object>>(MapDeserializer<Object, Object>());
    register<Map<String, dynamic>>(MapDeserializer<String, dynamic>());
    register<Map<String, Object>>(MapDeserializer<String, Object>());
    register<Map<String, int>>(MapDeserializer<String, int>());
    register<Map<String, bool>>(MapDeserializer<String, bool>());
    register<Map<int, dynamic>>(MapDeserializer<int, dynamic>());
    register<Map<int, Object>>(MapDeserializer<int, Object>());
  }

  void register<T>(AbstractDeserializer deserializer) {
    _deserializers[T.toString()] = deserializer;
  }

  bool isRegister<T>() {
    return _deserializers.containsKey(T.toString());
  }

  AbstractDeserializer<T> getInstance<T>() {
    return get(T.toString());
  }

  AbstractDeserializer get(String type) {
    if (type == null || type.isEmpty) {
      return DynamicDeserializer.instance;
    }
    if (_deserializers.containsKey(type)) {
      return _deserializers[type];
    }
    throw UnsupportedError(
        'Unsupported to deserialize $type data, because $type deserializer is not registered.');
  }
}

final _Deserializer Deserializer = _Deserializer();
