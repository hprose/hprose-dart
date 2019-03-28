/*--------------------------------------------------------*\
|                                                          |
|                          hprose                          |
|                                                          |
| Official WebSite: https://hprose.com                     |
|                                                          |
| mock_handler.dart                                        |
|                                                          |
| MockHandler for Dart.                                    |
|                                                          |
| LastModified: Mar 28, 2019                               |
| Author: Ma Bingyao <andot@hprose.com>                    |
|                                                          |
\*________________________________________________________*/

part of hprose.rpc.core;

class MockServer {
  final String address;
  MockServer(this.address);
  void close() {
    _MockAgent.cancel(address);
  }
}

class MockHandler implements Handler<MockServer> {
  final Service service;
  MockHandler(this.service);

  @override
  void bind(MockServer server) {
    _MockAgent.register(server.address, handler);
  }

  Future<Uint8List> handler(String address, Uint8List request) {
    if (request.length > service.maxRequestLength) {
      throw new Exception('Request entity too large');
    }
    final context = service.createContext();
    context.host = address;
    context.handler = this;
    return service.handle(request, context);
  }
}

class MockHandlerCreator implements HandlerCreator<MockHandler> {
  @override
  List<String> serverTypes = ['MockServer'];
  @override
  MockHandler create(Service service) {
    return new MockHandler(service);
  }
}
