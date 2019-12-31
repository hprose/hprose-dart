/*--------------------------------------------------------*\
|                                                          |
|                          hprose                          |
|                                                          |
| Official WebSite: https://hprose.com                     |
|                                                          |
| udp_handler.dart                                         |
|                                                          |
| UdpHandler for Dart.                                     |
|                                                          |
| LastModified: Dec 31, 2019                               |
| Author: Ma Bingyao <andot@hprose.com>                    |
|                                                          |
\*________________________________________________________*/

part of hprose.rpc;

class UdpHandler implements Handler<RawDatagramSocket> {
  void Function(RawDatagramSocket socket) onAccept;
  void Function(dynamic error) onError;
  void Function() onDone;
  core.Service service;
  UdpHandler(this.service);

  @override
  void bind(RawDatagramSocket server) {
    server.readEventsEnabled = true;
    server.writeEventsEnabled = false;
    handler(server);
  }

  void handler(RawDatagramSocket server) {
    server.listen((event) {
      if (event == RawSocketEvent.read) {
        _receive(server);
      }
    }, onError: onError, onDone: onDone);
  }

  void _receive(RawDatagramSocket socket) {
    while (true) {
      final datagram = socket.receive();
      if (datagram == null) return;
      final istream = ByteStream.fromUint8List(datagram.data);
      final crc = istream.readUInt32BE();
      istream.mark();
      final header = istream.read(4);
      if (crc32(header) != crc) return;
      istream.reset();
      final bodyLength = istream.readByte() << 8 | istream.readByte();
      final index = istream.readByte() << 8 | istream.readByte();
      if (bodyLength != datagram.data.length - 8 || index & 0x8000 != 0) return;
      if (bodyLength > service.maxRequestLength) {
        _send(socket, utf8.encode('Request entity too large'), index | 0x8000,
            datagram.address, datagram.port);
        return;
      }
      final request = istream.read(bodyLength);
      _run(socket, request, index, datagram.address, datagram.port);
    }
  }

  void _send(RawDatagramSocket socket, List<int> response, int index,
      InternetAddress address, int port) {
    final n = response.length;
    final data = Uint8List(8 + n);
    final view = ByteData.view(data.buffer);
    view.setUint16(4, n, Endian.big);
    view.setUint16(6, index, Endian.big);
    final crc = crc32(data.sublist(4, 8));
    view.setUint32(0, crc, Endian.big);
    data.setRange(8, 8 + n, response);
    socket.send(data, address, port);
  }

  void _run(RawDatagramSocket socket, Uint8List request, int index,
      InternetAddress address, int port) async {
    final context = service.createContext() as ServiceContext;
    context['socket'] = socket;
    context.remoteAddress = address;
    context.remotePort = port;
    context.localAddress = socket.address;
    context.localPort = socket.port;
    context.host = socket.address.host;
    context.handler = this;
    List<int> response;
    try {
      response = await service.handle(request, context);
    } catch (e) {
      index |= 0x8000;
      response = utf8.encode(e.toString());
    }
    _send(socket, response, index, address, port);
  }
}

class UdpHandlerCreator implements HandlerCreator<UdpHandler> {
  @override
  List<String> serverTypes = ['_RawDatagramSocket'];

  @override
  UdpHandler create(core.Service service) {
    return UdpHandler(service);
  }
}
