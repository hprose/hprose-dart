/*--------------------------------------------------------*\
|                                                          |
|                          hprose                          |
|                                                          |
| Official WebSite: https://hprose.com                     |
|                                                          |
| serializer.dart                                          |
|                                                          |
| hprose Serializer for Dart.                              |
|                                                          |
| LastModified: Dec 31, 2019                               |
| Author: Ma Bingyao <andot@hprose.com>                    |
|                                                          |
\*________________________________________________________*/

part of hprose.io;

abstract class AbstractSerializer<T> {
  void write(Writer writer, T value);
  void serialize(Writer writer, T value);
}

class _Serializer {
  final Map<String, AbstractSerializer> _serializers = {};

  _Serializer() {
    register<dynamic>(DynamicSerializer.instance);
    register<Object>(DynamicSerializer.instance);
    register<DynamicObject>(DynamicObjectSerializer.instance);
    register<Null>(BaseSerializer.instance);
    register<Function>(BaseSerializer.instance);
    register<num>(NumSerializer.instance);
    register<int>(IntSerializer.instance);
    register<double>(DoubleSerializer.instance);
    register<BigInt>(BigIntSerializer.instance);
    register<bool>(BoolSerializer.instance);
    register<Duration>(DurationSerializer.instance);
    register<String>(StringSerializer.instance);
    register<DateTime>(DateTimeSerializer.instance);
    register<Map>(MapSerializer.instance);
    register<List>(IterableSerializer.instance);
    register<Set>(IterableSerializer.instance);
    register<Iterable>(IterableSerializer.instance);
    register<ByteBuffer>(BytesSerializer.instance);
    register<Uint8List>(BytesSerializer.instance);
    register<Uint8ClampedList>(BytesSerializer.instance);
    register<ByteStream>(BytesSerializer.instance);
    register<Int32x4>(Int32x4Serializer.instance);
    register<Float32x4>(Float32x4Serializer.instance);
    register<Float64x2>(Float64x2Serializer.instance);
    register<Error>(ExceptionSerializer.instance);
    register<Exception>(ExceptionSerializer.instance);
    final objectIterableSerializer = IterableSerializer<Object>();
    final intIterableSerializer = IterableSerializer<int>();
    final doubleIterableSerializer = IterableSerializer<double>();
    final numIterableSerializer = IterableSerializer<num>();
    final stringIterableSerializer = IterableSerializer<String>();
    register<List<Object>>(objectIterableSerializer);
    register<Set<Object>>(objectIterableSerializer);
    register<List<int>>(intIterableSerializer);
    register<Set<int>>(intIterableSerializer);
    register<Int8List>(intIterableSerializer);
    register<Int16List>(intIterableSerializer);
    register<Int32List>(intIterableSerializer);
    register<Int64List>(intIterableSerializer);
    register<Uint16List>(intIterableSerializer);
    register<Uint32List>(intIterableSerializer);
    register<Uint64List>(intIterableSerializer);
    register<List<double>>(doubleIterableSerializer);
    register<Set<double>>(doubleIterableSerializer);
    register<Float32List>(doubleIterableSerializer);
    register<Float64List>(doubleIterableSerializer);
    register<List<num>>(numIterableSerializer);
    register<Set<num>>(numIterableSerializer);
    register<List<String>>(stringIterableSerializer);
    register<Set<String>>(stringIterableSerializer);
    register<Int32x4List>(IterableSerializer<Int32x4>());
    register<Float32x4List>(IterableSerializer<Float32x4>());
    register<Float64x2List>(IterableSerializer<Float64x2>());
    register<List<BigInt>>(IterableSerializer<BigInt>());
    register<List<bool>>(IterableSerializer<bool>());
    register<List<DateTime>>(IterableSerializer<DateTime>());
    register<List<Duration>>(IterableSerializer<Duration>());
    register<List<Uint8List>>(IterableSerializer<Uint8List>());
    register<List<List>>(IterableSerializer<List>());
    register<List<Map>>(IterableSerializer<Map>());
    register<List<Map<String, dynamic>>>(
        IterableSerializer<Map<String, dynamic>>());
    register<List<Map<int, dynamic>>>(IterableSerializer<Map<int, dynamic>>());
    register<List<List<List>>>(IterableSerializer<List<List>>());
    register<List<List<Map>>>(IterableSerializer<List<Map>>());
    register<List<List<Map<String, dynamic>>>>(
        IterableSerializer<List<Map<String, dynamic>>>());
    register<List<List<Map<int, dynamic>>>>(
        IterableSerializer<List<Map<int, dynamic>>>());
    register<Map<int, dynamic>>(MapSerializer<int, dynamic>());
    register<Map<String, dynamic>>(MapSerializer<String, dynamic>());
  }

  void register<T>(AbstractSerializer serializer) {
    _serializers[T.toString()] = serializer;
  }

  bool isRegister<T>() {
    return _serializers.containsKey(T.toString());
  }

  AbstractSerializer<dynamic> getInstance<T>(dynamic value) {
    return get(T.toString(), value);
  }

  AbstractSerializer get(String type, dynamic value) {
    if (type == null || type.isEmpty) {
      return DynamicSerializer.instance;
    }
    final serializer = _serializers[type];
    if (serializer == null) {
      if (value is Map) {
        return MapSerializer.instance;
      } else if (value is Iterable) {
        return IterableSerializer.instance;
      } else if (value is Error || value is Exception) {
        return ExceptionSerializer.instance;
      }
      return ObjectSerializer.instance;
    }
    return serializer;
  }
}

final _Serializer Serializer = _Serializer();
