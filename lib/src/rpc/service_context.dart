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

part of hprose.rpc;

class ServiceContext extends core.ServiceContext {
  InternetAddress address;
  ServiceContext(Service service) : super(service);

  @override
  Context clone() {
    final context = super.clone() as ServiceContext;
    context.address = address;
    return context;
  }
}
