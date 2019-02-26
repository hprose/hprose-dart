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
| LastModified: Feb 24, 2019                               |
| Author: Ma Bingyao <andot@hprose.com>                    |
|                                                          |
\*________________________________________________________*/

part of hprose.rpc;

class ClientContext extends Context {
  Client client;
  Uri uri;
  Type returnType;
  final Map<String, dynamic> requestHeaders = {};
  final Map<String, dynamic> responseHeaders = {};
  void init(Client client, Type returnType) {
    this.client = client;
    uri = client.uris.length > 0 ? client.uris.first : null;
    this.returnType = returnType;
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
