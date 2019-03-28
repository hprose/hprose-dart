/*--------------------------------------------------------*\
|                                                          |
|                          hprose                          |
|                                                          |
| Official WebSite: https://hprose.com                     |
|                                                          |
| websocket_handler.dart                                   |
|                                                          |
| WebSocketHandler for Dart.                               |
|                                                          |
| LastModified: Mar 28, 2019                               |
| Author: Ma Bingyao <andot@hprose.com>                    |
|                                                          |
\*________________________________________________________*/

part of hprose.rpc;

class WebSocketHandler implements Handler<HttpServer> {
  void Function(WebSocket socket) onAccept;
  void Function(WebSocket socket, dynamic error) onError;
  void Function(WebSocket socket) onClose;

  void Function(dynamic error) get onServerError => http.onError;
  void Function() get onDone => http.onDone;
  set onServerError(void Function(dynamic error) value) => http.onError = value;
  set onDone(void Function() value) => http.onDone = value;

  HttpHandler http;
  core.Service service;

  WebSocketHandler(this.service) {
    http = new HttpHandler(service);
  }

  @override
  void bind(HttpServer server) {
    server.listen((request) async {
      if (request.headers[HttpHeaders.upgradeHeader]?.first == 'websocket') {
        handler(request, await WebSocketTransformer.upgrade(request), server);
      } else {
        http.handler(request, server);
      }
    }, onError: onServerError, onDone: onDone);
  }

  void handler(HttpRequest request, WebSocket socket, HttpServer server) {
    try {
      if (onAccept != null) onAccept(socket);
    } catch (e) {
      if (onError != null) onError(socket, e);
      socket.close();
      if (onClose != null) onClose(socket);
      return;
    }
    socket.listen((data) async {
      final stream = new ByteStream.fromUint8List(data);
      var index = stream.readUInt32BE();
      final context = service.createContext() as ServiceContext;
      context['request'] = request;
      context['websocket'] = socket;
      context['server'] = server;
      context.remoteAddress = request.connectionInfo.remoteAddress;
      context.remotePort = request.connectionInfo.remotePort;
      context.localAddress = server.address;
      context.localPort = request.connectionInfo.localPort;
      context.host = server.address.host;
      context.handler = this;
      List<int> response;
      try {
        response = await service.handle(stream.remains, context);
      } catch (e) {
        index |= 0x80000000;
        response = utf8.encode(e.toString());
      }
      final n = response.length;
      data = new Uint8List(4 + n);
      final view = new ByteData.view(data.buffer);
      view.setUint32(0, index, Endian.big);
      data.setRange(4, 4 + n, response);
      socket.add(data);
    }, onError: (dynamic error) {
      if (onError != null) onError(socket, error);
    }, onDone: () {
      if (onClose != null) onClose(socket);
    }, cancelOnError: true);
  }
}

class WebSocketHandlerCreator implements HandlerCreator<WebSocketHandler> {
  @override
  List<String> serverTypes = ['_HttpServer'];

  @override
  WebSocketHandler create(core.Service service) {
    return new WebSocketHandler(service);
  }
}
