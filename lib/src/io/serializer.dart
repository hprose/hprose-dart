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
| LastModified: Feb 14, 2019                               |
| Author: Ma Bingyao <andot@hprose.com>                    |
|                                                          |
\*________________________________________________________*/

part of hprose.io;

abstract class AbstractSerializer<T> {
  void write(Writer writer, T value);
  void serialize(Writer writer, T value);
}

class _Serializer {
  final Map<Type, AbstractSerializer> _serializers = {};

  _Serializer() {
    register<dynamic>(DynamicSerializer.instance);
    register<Null>(BaseSerializer.instance);
    register<Function>(BaseSerializer.instance);
    register<num>(NumSerializer.instance);
    register<int>(IntSerializer.instance);
    register<double>(DoubleSerializer.instance);
    register<BigInt>(BigIntSerializer.instance);
    register<bool>(BoolSerializer.instance);
    register<String>(StringSerializer.instance);
    register<DateTime>(DateTimeSerializer.instance);
    register<DynamicObject>(DynamicObjectSerializer.instance);
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
    register<Error>(ErrorSerializer.instance);
    register<Exception>(ErrorSerializer.instance);
    final intIterableSerializer = new IterableSerializer<int>();
    final doubleIterableSerializer = new IterableSerializer<double>();
    final numIterableSerializer = new IterableSerializer<num>();
    final stringIterableSerializer = new IterableSerializer<String>();
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
    register<Int32x4List>(new IterableSerializer<Int32x4>());
    register<Float32x4List>(new IterableSerializer<Float32x4>());
    register<Float64x2List>(new IterableSerializer<Float64x2>());
    register<List<BigInt>>(new IterableSerializer<BigInt>());
    register<List<bool>>(new IterableSerializer<bool>());
    register<List<DateTime>>(new IterableSerializer<DateTime>());
    register<List<Uint8List>>(new IterableSerializer<Uint8List>());
    register<List<List>>(new IterableSerializer<List>());
    register<List<Map>>(new IterableSerializer<Map>());
    register<List<Map<String, dynamic>>>(
        new IterableSerializer<Map<String, dynamic>>());
    register<List<Map<int, dynamic>>>(
        new IterableSerializer<Map<int, dynamic>>());
    register<List<List<List>>>(new IterableSerializer<List<List>>());
    register<List<List<Map>>>(new IterableSerializer<List<Map>>());
    register<List<List<Map<String, dynamic>>>>(
        new IterableSerializer<List<Map<String, dynamic>>>());
    register<List<List<Map<int, dynamic>>>>(
        new IterableSerializer<List<Map<int, dynamic>>>());
    register<Map<int, dynamic>>(new MapSerializer<int, dynamic>());
    register<Map<String, dynamic>>(new MapSerializer<String, dynamic>());
  }

  void register<T>(AbstractSerializer serializer) {
    _serializers[T] = serializer;
  }

  AbstractSerializer getInstance(Type type, dynamic value) {
    final serializer = _serializers[type];
    if (serializer == null) {
      if (value is Map) {
        return MapSerializer.instance;
      } else if (value is Iterable) {
        return IterableSerializer.instance;
      } else if (value is Error || value is Exception) {
        return ErrorSerializer.instance;
      }
    }
    return serializer;
  }
}

final _Serializer Serializer = _Serializer();
