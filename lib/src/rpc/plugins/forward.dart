/*--------------------------------------------------------*\
|                                                          |
|                          hprose                          |
|                                                          |
| Official WebSite: https://hprose.com                     |
|                                                          |
| forward.dart                                             |
|                                                          |
| Forward plugin for Dart.                                 |
|                                                          |
| LastModified: Mar 29, 2020                               |
| Author: Ma Bingyao <andot@hprose.com>                    |
|                                                          |
\*________________________________________________________*/

part of hprose.rpc.plugins;

class Forward {
  Client _client;
  Duration timeout;
  Forward([List<String> uris]) {
    _client = Client(uris);
  }

  Future<Uint8List> ioHandler(
      Uint8List request, Context context, NextIOHandler next) {
    final clientContext = ClientContext(timeout: timeout);
    clientContext.init(_client);
    return _client.request(request, clientContext);
  }

  Future invokeHandler(
      String name, List args, Context context, NextInvokeHandler next) async {
    final clientContext = ClientContext(timeout: timeout);
    clientContext.requestHeaders.addAll(context.requestHeaders);
    final result = await _client.invoke(name, args, clientContext);
    context.responseHeaders.addAll(clientContext.responseHeaders);
    return result;
  }

  void use<Handler>(Handler handler) {
    _client.use(handler);
  }

  void unuse<Handler>(Handler handler) {
    _client.unuse(handler);
  }
}
