/*--------------------------------------------------------*\
|                                                          |
|                          hprose                          |
|                                                          |
| Official WebSite: https://hprose.com                     |
|                                                          |
| jsonrpc_client_codec.dart                                |
|                                                          |
| JsonRpcClientCodec for Dart.                             |
|                                                          |
| LastModified: Mar 9, 2019                                |
| Author: Ma Bingyao <andot@hprose.com>                    |
|                                                          |
\*________________________________________________________*/

part of hprose.rpc.codec.jsonrpc;

class JsonRpcClientCodec implements ClientCodec {
  static JsonRpcClientCodec instance = new JsonRpcClientCodec();
  int _counter = 0;
  @override
  Uint8List encode(String name, List args, ClientContext context) {
    final request = {'jsonrpc': '2.0', 'id': _counter++, 'method': name};
    if (args.isNotEmpty) {
      request['params'] = args;
    }
    return utf8.encode(json.encode(request));
  }

  @override
  decode(Uint8List response, ClientContext context) {
    final Map<String, dynamic> result = json.decode(utf8.decode(response));
    if (result.containsKey('result')) {
      if (context.returnType == dynamic ||
          result['result'].runtimeType == context.returnType) {
        return result['result'];
      }
      return Formatter.deserialize(Formatter.serialize(result['result']),
          type: context.returnType.toString());
    }
    if (result.containsKey('error')) {
      final Map<String, dynamic> error = result['error'];
      if (error.containsKey('code')) {
        throw new Exception('${error["code"]}:${error["message"]}');
      }
      throw new Exception(error['message'].toString());
    }
    return null;
  }
}
