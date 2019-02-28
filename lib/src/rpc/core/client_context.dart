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
| LastModified: Feb 28, 2019                               |
| Author: Ma Bingyao <andot@hprose.com>                    |
|                                                          |
\*________________________________________________________*/

part of hprose.rpc.core;

class ClientContext extends Context {
  Client client;
  Uri uri;
  Type returnType;
  Duration timeout;
  final Map<String, dynamic> requestHeaders = {};
  final Map<String, dynamic> responseHeaders = {};
  ClientContext(
      {this.uri,
      this.returnType,
      this.timeout,
      Map<String, dynamic> requestHeaders,
      Map<String, dynamic> responseHeaders}) {
    if (requestHeaders != null && requestHeaders.isNotEmpty) {
      this.requestHeaders.addAll(requestHeaders);
    }
    if (responseHeaders != null && responseHeaders.isNotEmpty) {
      this.responseHeaders.addAll(responseHeaders);
    }
  }
  void init(Client client, Type type) {
    this.client = client;
    if (client.uris.length > 0) this.uri = client.uris.first;
    if (returnType == null) returnType = type;
    if (timeout == null) timeout = client.timeout;
    requestHeaders.addAll(client.requestHeaders);
  }

  @override
  Context clone() {
    final context = super.clone() as ClientContext;
    context.requestHeaders.addAll(requestHeaders);
    context.responseHeaders.addAll(responseHeaders);
    return context;
  }
}
