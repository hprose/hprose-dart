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

part of hprose.rpc;

class ServiceContext extends core.ServiceContext {
  InternetAddress address;
  int port;
  ServiceContext(Service service) : super(service);
}
