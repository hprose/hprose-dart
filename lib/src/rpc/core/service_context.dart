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
| LastModified: Feb 23, 2019                               |
| Author: Ma Bingyao <andot@hprose.com>                    |
|                                                          |
\*________________________________________________________*/

part of hprose.rpc.core;

class ServiceContext extends Context {
  final Service service;
  Method method;
  
  ServiceContext(this.service);
}