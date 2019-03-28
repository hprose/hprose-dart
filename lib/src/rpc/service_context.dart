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
| LastModified: Mar 28, 2019                               |
| Author: Ma Bingyao <andot@hprose.com>                    |
|                                                          |
\*________________________________________________________*/

part of hprose.rpc;

class ServiceContext extends core.ServiceContext {
  InternetAddress remoteAddress;
  int remotePort;
  InternetAddress localAddress;
  int localPort;
  ServiceContext(Service service) : super(service);

  @override
  Context clone() {
    final context = super.clone() as ServiceContext;
    context.remoteAddress = remoteAddress;
    context.remotePort = remotePort;
    context.localAddress = localAddress;
    context.localPort = localPort;
    return context;
  }
}
