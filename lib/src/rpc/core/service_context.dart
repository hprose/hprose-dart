/*--------------------------------------------------------*\
|                                                          |
|                          hprose                          |
|                                                          |
| Official WebSite: https://hprose.com                     |
|                                                          |
| service_context.dart                                     |
|                                                          |
| ServiceContext for Dart.                                 |
|                                                          |
| LastModified: Mar 9, 2019                                |
| Author: Ma Bingyao <andot@hprose.com>                    |
|                                                          |
\*________________________________________________________*/

part of hprose.rpc.core;

class ServiceContext extends Context {
  final Service service;
  Method method;
  String host;
  int port;
  final Map<String, dynamic> requestHeaders = {};
  final Map<String, dynamic> responseHeaders = {};
  dynamic handler;
  ServiceContext(this.service);

  @override
  Context clone() {
    final context = service.createContext();
    context.method = method;
    context.host = host;
    context.port = port;
    context.handler = handler;
    context.items.addAll(items);
    context.requestHeaders.addAll(requestHeaders);
    context.responseHeaders.addAll(responseHeaders);
    return context;
  }
}
