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
| LastModified: Mar 5, 2019                                |
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

  HttpHandler get http => websocket.http;
  TcpHandler get tcp => this['tcp'];
  UdpHandler get udp => this['udp'];
  WebSocketHandler get websocket => this['websocket'];

  @override
  void init() {
    super.init();
    if (!isRegister('tcp')) {
      register<TcpHandler>('tcp', new TcpHandlerCreator());
    }
    if (!isRegister('udp')) {
      register<UdpHandler>('udp', new UdpHandlerCreator());
    }
    if (!isRegister('websocket')) {
      register<WebSocketHandler>('websocket', new WebSocketHandlerCreator());
    }
  }

  @override
  ServiceContext createContext() => new ServiceContext(this);
}
