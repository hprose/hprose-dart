/*--------------------------------------------------------*\
|                                                          |
|                          hprose                          |
|                                                          |
| Official WebSite: https://hprose.com                     |
|                                                          |
| client.dart                                              |
|                                                          |
| Client for Dart.                                         |
|                                                          |
| LastModified: Mar 10, 2019                               |
| Author: Ma Bingyao <andot@hprose.com>                    |
|                                                          |
\*________________________________________________________*/

part of hprose.rpc.browser;

class Client extends core.Client {
  static void register<T extends Transport>(
      String name, TransportCreator<T> creator) {
    core.Client.register<T>(name, creator);
  }

  static bool isRegister(String name) {
    return core.Client.isRegister(name);
  }

  Client([List<String> uris]) : super(uris);
  HttpTransport get http => this['http'];
  WebSocketTransport get websocket => this['websocket'];

  @override
  void init() {
    super.init();
    if (!isRegister('http')) {
      register<HttpTransport>('http', new HttpTransportCreator());
    }
    if (!isRegister('websocket')) {
      register<WebSocketTransport>(
          'websocket', new WebSocketTransportCreator());
    }
  }
}
