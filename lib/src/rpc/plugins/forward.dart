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

  void _forwardHttpResponseHeaders(
      Context context, ClientContext clientContext) {
    if (clientContext.containsKey('httpResponseHeaders')) {
      context['httpResponseHeaders'] = clientContext['httpResponseHeaders'];
    }
    if (clientContext.containsKey('httpStatusCode')) {
      context['httpStatusCode'] = clientContext['httpStatusCode'];
    }
  }

  void _forwardHttpRequestHeaders(
      Context context, ClientContext clientContext) {
    if (context.containsKey('httpRequestHeaders')) {
      clientContext['httpRequestHeaders'] = context['httpRequestHeaders'];
    }
  }

  Future<Uint8List> ioHandler(
      Uint8List request, Context context, NextIOHandler next) async {
    final clientContext = ClientContext(timeout: timeout);
    clientContext.init(_client);
    _forwardHttpRequestHeaders(context, clientContext);
    final response = await _client.request(request, clientContext);
    _forwardHttpResponseHeaders(context, clientContext);
    return response;
  }

  Future invokeHandler(
      String name, List args, Context context, NextInvokeHandler next) async {
    final clientContext = ClientContext(timeout: timeout);
    _forwardHttpRequestHeaders(context, clientContext);
    clientContext.requestHeaders.addAll(context.requestHeaders);
    final result = await _client.invoke(name, args, clientContext);
    context.responseHeaders.addAll(clientContext.responseHeaders);
    _forwardHttpResponseHeaders(context, clientContext);
    return result;
  }

  void use<Handler>(Handler handler) {
    _client.use(handler);
  }

  void unuse<Handler>(Handler handler) {
    _client.unuse(handler);
  }
}
