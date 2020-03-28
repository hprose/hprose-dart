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
| LastModified: Mar 28, 2020                               |
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
  void copyTo(Context context) {
    super.copyTo(context);
    final serviceContext = context as ServiceContext;
    serviceContext.remoteAddress = remoteAddress;
    serviceContext.remotePort = remotePort;
    serviceContext.localAddress = localAddress;
    serviceContext.localPort = localPort;
  }
}
