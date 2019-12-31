/*--------------------------------------------------------*\
|                                                          |
|                          hprose                          |
|                                                          |
| Official WebSite: https://hprose.com                     |
|                                                          |
| client_context.dart                                      |
|                                                          |
| ClientContext for Dart.                                  |
|                                                          |
| LastModified: Dec 31, 2019                               |
| Author: Ma Bingyao <andot@hprose.com>                    |
|                                                          |
\*________________________________________________________*/

part of hprose.rpc.core;

class ClientContext extends Context {
  Client client;
  Uri uri;
  Type returnType;
  Duration timeout;
  ClientContext(
      {this.uri,
      this.returnType,
      this.timeout,
      Map<String, dynamic> requestHeaders,
      Map<String, dynamic> items}) {
    if (requestHeaders != null && requestHeaders.isNotEmpty) {
      this.requestHeaders.addAll(requestHeaders);
    }
    if (items != null && items.isNotEmpty) {
      this.items.addAll(items);
    }
  }
  void init(Client client, Type type) {
    this.client = client;
    if (client.uris.isNotEmpty) uri = client.uris.first;
    returnType ??= type;
    timeout ??= client.timeout;
    requestHeaders.addAll(client.requestHeaders);
  }

  @override
  Context clone() {
    final context = ClientContext();
    context.client = client;
    context.uri = uri;
    context.returnType = returnType;
    context.timeout = timeout;
    context.items.addAll(items);
    context.requestHeaders.addAll(requestHeaders);
    context.responseHeaders.addAll(responseHeaders);
    return context;
  }
}
