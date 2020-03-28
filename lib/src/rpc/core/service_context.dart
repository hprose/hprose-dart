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

part of hprose.rpc.core;

class ServiceContext extends Context {
  final Service service;
  Method method;
  String host;
  dynamic handler;
  ServiceContext(this.service);

  @override
  void copyTo(Context context) {
    super.copyTo(context);
    final serviceContext = context as ServiceContext;
    serviceContext.method = method;
    serviceContext.host = host;
    serviceContext.handler = handler;
  }

  @override
  Context clone() {
    final context = service.createContext();
    copyTo(context);
    return context;
  }
}
