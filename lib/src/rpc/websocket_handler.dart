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
| LastModified: May 25, 2019                               |
| Author: Ma Bingyao <andot@hprose.com>                    |
|                                                          |
\*________________________________________________________*/

part of hprose.rpc;

class WebSocketHandler extends HttpHandler {
  void Function(WebSocket socket) onAccept;
  void Function(WebSocket socket, dynamic error) onWebSocketError;
  void Function(WebSocket socket) onClose;

  WebSocketHandler(core.Service service) : super(service);

  @override
  void handler(HttpRequest request, ServiceContext context) async {
    if (request.headers[HttpHeaders.upgradeHeader]?.first != 'websocket') {
      await super.handler(request, context);
      return;
    }
    final socket = await WebSocketTransformer.upgrade(request);
    try {
      if (onAccept != null) onAccept(socket);
    } catch (e) {
      if (onError != null) onWebSocketError(socket, e);
      socket.close();
      if (onClose != null) onClose(socket);
      return;
    }
    socket.listen((data) async {
      final stream = new ByteStream.fromUint8List(data);
      var index = stream.readUInt32BE();
      final wscontext = context.clone();
      wscontext['websocket'] = socket;
      List<int> response;
      try {
        response = await service.handle(stream.remains, wscontext);
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
      if (onError != null) onWebSocketError(socket, error);
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
