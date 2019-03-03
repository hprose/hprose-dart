/*--------------------------------------------------------*\
|                                                          |
|                          hprose                          |
|                                                          |
| Official WebSite: https://hprose.com                     |
|                                                          |
| service.dart                                             |
|                                                          |
| Service for Dart.                                        |
|                                                          |
| LastModified: Mar 2, 2019                                |
| Author: Ma Bingyao <andot@hprose.com>                    |
|                                                          |
\*________________________________________________________*/

part of hprose.rpc;

class Service extends core.Service {
  static void register<T extends Handler>(
      String name, HandlerCreator<T> creator) {
    core.Service.register<T>(name, creator);
  }

  static bool isRegister(String name) {
    return core.Service.isRegister(name);
  }

  HttpHandler get http => this['http'];
  HttpHandler get tcp => this['tcp'];

  @override
  void init() {
    super.init();
    if (!isRegister('http')) {
      register<HttpHandler>('http', new HttpHandlerCreator());
    }
    if (!isRegister('tcp')) {
      register<SocketHandler>('tcp', new SocketHandlerCreator());
    }
  }

  @override
  ServiceContext createContext() => new ServiceContext(this);
}
