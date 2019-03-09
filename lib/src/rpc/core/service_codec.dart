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
| LastModified: Feb 27, 2019                               |
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
  static DefaultServiceCodec instance = new DefaultServiceCodec();
  bool debug = false;
  bool simple = false;
  LongType longType = LongType.Int;
  @override
  Uint8List encode(result, ServiceContext context) {
    final stream = new ByteStream();
    final writer = new Writer(stream, simple: simple);
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

  Method _decodeMethod(String fullname, ServiceContext context) {
    final service = context.service;
    final method = service.get(fullname);
    if (method == null) {
      throw new Exception('Can\'t find this method ${fullname}().');
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
    var args = new List<dynamic>.filled(n, null, growable: true);
    if (method.contextInPositionalArguments) {
      ppl--;
      n--;
    }
    n = min(count, n);
    for (int i = 0; i < n; ++i) {
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
          throw new ArgumentError(
              'Invalid argument, expected named parameters, but positional parameter found.');
        }
        var size = ValueReader.readCount(stream);
        reader.addReference(null);
        var namedArgs = new Map<Symbol, dynamic>();
        for (int j = 0; j < size; ++j) {
          var name = reader.deserialize<String>();
          if (method.namedParameterTypes.containsKey(name)) {
            var value = Deserializer.get(method.namedParameterTypes[name])
                .deserialize(reader);
            namedArgs[new Symbol(name)] = value;
          } else {
            reader.deserialize();
          }
        }
        stream.readByte();
        if (method.contextInNamedArguments) {
          namedArgs[new Symbol('context')] = context;
        }
        args[i] = namedArgs;
      }
    }
    if (method.contextInPositionalArguments) {
      args[ppl] = context;
    }
    return args;
  }

  @override
  RequestInfo decode(Uint8List request, ServiceContext context) {
    if (request.isEmpty) {
      _decodeMethod('~', context);
      return new RequestInfo('~', []);
    }
    final stream = new ByteStream.fromUint8List(request);
    var reader = new Reader(stream);
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
        final fullname = reader.deserialize<String>();
        final args =
            _decodeArguments(_decodeMethod(fullname, context), reader, context);
        return new RequestInfo(fullname, args);
      case TagEnd:
        _decodeMethod('~', context);
        return new RequestInfo('~', []);
      default:
        throw new Exception('Invalid request:\r\n${stream.toString()}');
    }
  }
}
