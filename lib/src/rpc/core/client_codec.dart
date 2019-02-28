/*--------------------------------------------------------*\
|                                                          |
|                          hprose                          |
|                                                          |
| Official WebSite: https://hprose.com                     |
|                                                          |
| client_codec.dart                                        |
|                                                          |
| ClientCodec for Dart.                                    |
|                                                          |
| LastModified: Feb 28, 2019                               |
| Author: Ma Bingyao <andot@hprose.com>                    |
|                                                          |
\*________________________________________________________*/

part of hprose.rpc.core;

abstract class ClientCodec {
  Uint8List encode(String name, List args, ClientContext context);
  decode(Uint8List response, ClientContext context);
}

class DefaultClientCodec implements ClientCodec {
  static DefaultClientCodec instance = new DefaultClientCodec();
  bool simple = false;
  LongType longType = LongType.Int;
  @override
  Uint8List encode(String name, List args, ClientContext context) {
    final stream = new ByteStream();
    final writer = new Writer(stream, simple: simple);
    final headers = context.requestHeaders;
    if (simple) {
      headers['simple'] = true;
    }
    if (headers.length > 0) {
      stream.writeByte(TagHeader);
      writer.serialize(headers);
      writer.reset();
    }
    stream.writeByte(TagCall);
    writer.serialize(name);
    if (args.length > 0) {
      writer.reset();
      writer.serialize(args);
    }
    stream.writeByte(TagEnd);
    return stream.takeBytes();
  }

  @override
  decode(Uint8List response, ClientContext context) {
    final stream = new ByteStream.fromUint8List(response);
    final reader = new Reader(stream);
    reader.longType = longType;
    var tag = stream.readByte();
    if (tag == TagHeader) {
      final headers = reader.deserialize<Map<String, dynamic>>();
      context.responseHeaders.addAll(headers);
      reader.reset();
      tag = stream.readByte();
    }
    switch (tag) {
      case TagResult:
        if (context.responseHeaders.containsKey('simple')) {
          reader.simple = true;
        }
        return Deserializer.getInstance(context.returnType).deserialize(reader);
      case TagError:
        throw new Exception(reader.deserialize<String>());
      case TagEnd:
        return null;
      default:
        throw new Exception('Invalid response:\r\n${stream.toString()}');
    }
  }
}
