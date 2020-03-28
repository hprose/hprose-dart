/*--------------------------------------------------------*\
|                                                          |
|                          hprose                          |
|                                                          |
| Official WebSite: https://hprose.com                     |
|                                                          |
| service_codec.dart                                       |
|                                                          |
| ServiceCodec for Dart.                                   |
|                                                          |
| LastModified: Mar 28, 2020                               |
| Author: Ma Bingyao <andot@hprose.com>                    |
|                                                          |
\*________________________________________________________*/

part of hprose.rpc.core;

class RequestInfo {
  final String name;
  final List args;
  RequestInfo(this.name, this.args);
}

abstract class ServiceCodec {
  Uint8List encode(result, ServiceContext context);
  RequestInfo decode(Uint8List request, ServiceContext context);
}

class DefaultServiceCodec extends ServiceCodec {
  static DefaultServiceCodec instance = DefaultServiceCodec();
  var debug = false;
  var simple = false;
  var longType = LongType.Int;
  @override
  Uint8List encode(result, ServiceContext context) {
    final stream = ByteStream();
    final writer = Writer(stream, simple: simple);
    final headers = context.responseHeaders;
    if (simple) {
      headers['simple'] = true;
    }
    if (headers.isNotEmpty) {
      stream.writeByte(TagHeader);
      writer.serialize(headers);
      writer.reset();
    }
    if (result is Error) {
      stream.writeByte(TagError);
      writer
          .serialize(debug ? result.stackTrace.toString() : result.toString());
    } else if (result is Exception) {
      stream.writeByte(TagError);
      writer.serialize(result.toString());
    } else {
      stream.writeByte(TagResult);
      writer.serialize(result);
    }
    stream.writeByte(TagEnd);
    return stream.takeBytes();
  }

  Method _decodeMethod(String name, ServiceContext context) {
    final service = context.service;
    final method = service.get(name);
    if (method == null) {
      throw Exception('Can\'t find this method ${name}().');
    }
    context.method = method;
    return method;
  }

  List _decodeArguments(Method method, Reader reader, ServiceContext context) {
    final stream = reader.stream;
    var tag = stream.readByte();
    if (method.missing) {
      if (tag == TagList) {
        reader.reset();
        return reader.read<List>(tag);
      }
      return [];
    }
    var count = 0;
    if (tag == TagList) {
      reader.reset();
      count = ValueReader.readCount(stream);
      reader.addReference(null);
    }
    var ppl = method.positionalParameterTypes.length;
    var opl = method.optionalParameterTypes.length;
    var n = ppl + opl;
    if (method.hasOptionalArguments) {
      if (count < ppl) {
        n = ppl;
      } else if (count < n) {
        n = count;
      }
    }
    if (method.hasNamedArguments) {
      n = ppl + 1;
    }
    if (method.contextInPositionalArguments) {
      ppl--;
      n--;
    }
    var args = List<dynamic>.filled(n, null, growable: true);
    n = min(count, n);
    for (var i = 0; i < n; ++i) {
      if (i < ppl) {
        args[i] = Deserializer.get(method.positionalParameterTypes[i])
            .deserialize(reader);
      } else if (method.hasOptionalArguments) {
        args[i] = Deserializer.get(method.optionalParameterTypes[i - ppl])
            .deserialize(reader);
      }
      if (i == ppl && method.hasNamedArguments) {
        tag = stream.readByte();
        if (tag != TagMap) {
          throw ArgumentError(
              'Invalid argument, expected named parameters, but positional parameter found.');
        }
        var size = ValueReader.readCount(stream);
        reader.addReference(null);
        var namedArgs = <Symbol, dynamic>{};
        for (var j = 0; j < size; ++j) {
          var name = reader.deserialize<String>();
          if (method.namedParameterTypes.containsKey(name)) {
            var value = Deserializer.get(method.namedParameterTypes[name])
                .deserialize(reader);
            namedArgs[Symbol(name)] = value;
          } else {
            reader.deserialize();
          }
        }
        stream.readByte();
        args[i] = namedArgs;
      }
    }
    return args;
  }

  @override
  RequestInfo decode(Uint8List request, ServiceContext context) {
    if (request.isEmpty) {
      _decodeMethod('~', context);
      return RequestInfo('~', []);
    }
    final stream = ByteStream.fromUint8List(request);
    var reader = Reader(stream);
    reader.longType = longType;
    var tag = stream.readByte();
    if (tag == TagHeader) {
      final headers = reader.deserialize<Map<String, dynamic>>();
      context.requestHeaders.addAll(headers);
      reader.reset();
      tag = stream.readByte();
    }
    switch (tag) {
      case TagCall:
        if (context.requestHeaders.containsKey('simple')) {
          reader.simple = true;
        }
        final name = reader.deserialize<String>();
        final args =
            _decodeArguments(_decodeMethod(name, context), reader, context);
        return RequestInfo(name, args);
      case TagEnd:
        _decodeMethod('~', context);
        return RequestInfo('~', []);
      default:
        throw Exception('Invalid request:\r\n${stream.toString()}');
    }
  }
}
