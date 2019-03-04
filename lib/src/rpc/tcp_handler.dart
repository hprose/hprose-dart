/*--------------------------------------------------------*\
|                                                          |
|                          hprose                          |
|                                                          |
| Official WebSite: https://hprose.com                     |
|                                                          |
| tcp_handler.dart                                         |
|                                                          |
| TcpHandler for Dart.                                     |
|                                                          |
| LastModified: Mar 3, 2019                                |
| Author: Ma Bingyao <andot@hprose.com>                    |
|                                                          |
\*________________________________________________________*/

part of hprose.rpc;

class TcpHandler<T extends Socket> implements Handler<Stream<T>> {
  void Function(T socket) onAccept;
  void Function(dynamic error) onServerError;
  void Function() onDone;
  void Function(T socket, dynamic error) onError;
  void Function(T socket) onClose;
  core.Service service;
  TcpHandler(this.service);

  @override
  void bind(Stream<T> server) {
    server.listen(handler, onError: onServerError, onDone: onDone);
  }

  void handler(T socket) {
    try {
      if (onAccept != null) onAccept(socket);
    } catch (e) {
      if (onError != null) onError(socket, e);
      socket.destroy();
      if (onClose != null) onClose(socket);
      return;
    }
    socket.listen(_receive(socket), onError: (dynamic error) {
      if (onError != null) onError(socket, error);
    }, onDone: () {
      if (onClose != null) onClose(socket);
    }, cancelOnError: true);
  }

  void _send(T socket, List<int> response, int index) {
    final n = response.length;
    final header = new Uint8List(12);
    final view = new ByteData.view(header.buffer);
    view.setUint32(4, n | 0x80000000, Endian.big);
    view.setUint32(8, index, Endian.big);
    final crc = crc32(header.sublist(4, 12));
    view.setUint32(0, crc, Endian.big);
    socket.add(header);
    socket.add(response);
  }

  void _run(T socket, Uint8List request, int index) async {
    final context = service.createContext() as ServiceContext;
    context['socket'] = socket;
    context.address = socket.remoteAddress;
    context.host = socket.remoteAddress.host;
    context.port = socket.remotePort;
    context.handler = this;
    List<int> response;
    try {
      response = await service.handle(request, context);
    } catch (e) {
      index |= 0x80000000;
      response = utf8.encode(e.toString());
    }
    _send(socket, response, index);
  }

  void Function(List<int>) _receive(T socket) {
    final instream = new ByteStream();
    const headerLength = 12;
    var bodyLength = -1;
    var index = 0;
    return (List<int> data) async {
      instream.write(data);
      while (true) {
        if ((bodyLength < 0) && (instream.length >= headerLength)) {
          final crc = instream.readUInt32BE();
          instream.mark();
          final header = instream.read(8);
          if (crc32(header) != crc ||
              (header[0] & 0x80) == 0 ||
              (header[4] & 0x80) != 0) {
            if (onError != null) {
              onError(socket, new Exception('Invalid request'));
            }
            socket.destroy();
            return;
          }
          instream.reset();
          bodyLength = instream.readUInt32BE() & 0x7FFFFFFF;
          index = instream.readUInt32BE();
          if (bodyLength > service.maxRequestLength) {
            _send(socket, utf8.encode('Request entity too large'),
                index | 0x80000000);
            await socket.close();
            return;
          }
        }
        if ((bodyLength >= 0) &&
            ((instream.length - headerLength) >= bodyLength)) {
          final request = instream.read(bodyLength);
          instream.trunc();
          bodyLength = -1;
          _run(socket, request, index);
        } else {
          break;
        }
      }
    };
  }
}

class TcpHandlerCreator implements HandlerCreator<TcpHandler> {
  @override
  List<String> serverTypes = ['_ServerSocket', 'SecureServerSocket'];

  @override
  TcpHandler create(core.Service service) {
    return new TcpHandler(service);
  }
}
