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
| LastModified: Feb 27, 2019                               |
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
}
