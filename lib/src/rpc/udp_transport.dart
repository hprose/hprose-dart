/*--------------------------------------------------------*\
|                                                          |
|                          hprose                          |
|                                                          |
| Official WebSite: https://hprose.com                     |
|                                                          |
| udp_transport.dart                                       |
|                                                          |
| UdpTransport for Dart.                                   |
|                                                          |
| LastModified: Dec 31, 2019                               |
| Author: Ma Bingyao <andot@hprose.com>                    |
|                                                          |
\*________________________________________________________*/

part of hprose.rpc;

class _UdpSocket {
  RawDatagramSocket socket;
  InternetAddress remoteAddress;
  int remotePort;
  _UdpSocket(this.socket, this.remoteAddress, this.remotePort);
}

class UdpTransport implements Transport {
  var _counter = 0;
  final _results = <RawDatagramSocket, Map<int, Completer<Uint8List>>>{};
  final _sockets = <Uri, _UdpSocket>{};
  bool Function(X509Certificate certificate) onBadCertificate = (_) => true;

  Future<_UdpSocket> _connect(Uri uri) async {
    InternetAddress host;
    RawDatagramSocket socket;
    var port = uri.port == 0 ? 8412 : uri.port;
    switch (uri.scheme) {
      case 'udp':
        host = (await InternetAddress.lookup(uri.host)).first;
        socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
        break;
      case 'udp4':
        host = (await InternetAddress.lookup(uri.host,
                type: InternetAddressType.IPv4))
            .first;
        socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
        break;
      case 'udp6':
        host = (await InternetAddress.lookup(uri.host,
                type: InternetAddressType.IPv6))
            .first;
        socket = await RawDatagramSocket.bind(InternetAddress.anyIPv6, 0);
        break;
      default:
        throw Exception('unsupported ${uri.scheme} protocol');
    }
    return _UdpSocket(socket, host, port);
  }

  void _close(Uri uri, RawDatagramSocket socket, Object error) async {
    if (_sockets.containsKey(uri) && _sockets[uri].socket == socket) {
      _sockets.remove(uri);
    }
    if (_results.containsKey(socket)) {
      var results = _results.remove(socket);
      for (var result in results.values) {
        if (!result.isCompleted) {
          result.completeError(error);
        }
      }
    }
  }

  void _receive(Uri uri, RawDatagramSocket socket) {
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
      if (bodyLength != datagram.data.length - 8) return;
      var index = istream.readByte() << 8 | istream.readByte();
      final has_error = (index & 0x8000) != 0;
      index &= 0x7FFF;
      final response = istream.read(bodyLength);
      if (_results.containsKey(socket)) {
        final results = _results[socket];
        final result = results.remove(index);
        if (has_error) {
          if (result != null && !result.isCompleted) {
            result.completeError(Exception(utf8.decode(response)));
          }
          _close(uri, socket, SocketException.closed());
          socket.close();
        } else if (result != null && !result.isCompleted) {
          result.complete(response);
        }
      }
    }
  }

  Future<_UdpSocket> _getSocket(Uri uri) async {
    if (_sockets.containsKey(uri)) {
      return _sockets[uri];
    }
    final udp = await _connect(uri);
    final socket = udp.socket;
    socket.listen((event) {
      if (event == RawSocketEvent.read) {
        _receive(uri, socket);
      }
    }, onError: (error) {
      _close(uri, socket, error);
    }, onDone: () {
      _close(uri, socket, SocketException.closed());
    }, cancelOnError: true);
    _sockets[uri] = udp;
    return udp;
  }

  @override
  Future<Uint8List> transport(Uint8List request, Context context) async {
    final clientContext = context as ClientContext;
    final uri = clientContext.uri;
    final index = (_counter < 0x7FFF) ? ++_counter : _counter = 0;
    final result = Completer<Uint8List>();
    final udp = await _getSocket(uri);
    final socket = udp.socket;
    if (!_results.containsKey(socket)) {
      _results[socket] = {};
    }
    final results = _results[socket];
    results[index] = result;
    Timer timer;
    if (clientContext.timeout > Duration.zero) {
      timer = Timer(clientContext.timeout, () async {
        if (!result.isCompleted) {
          result.completeError(TimeoutException('Timeout'));
          await abort();
        }
      });
    }
    final n = request.length;
    final data = Uint8List(8 + n);
    final view = ByteData.view(data.buffer);
    view.setUint16(4, n, Endian.big);
    view.setUint16(6, index, Endian.big);
    final crc = crc32(data.sublist(4, 8));
    view.setUint32(0, crc, Endian.big);
    data.setRange(8, 8 + n, request);
    socket.send(data, udp.remoteAddress, udp.remotePort);
    try {
      return await result.future;
    } finally {
      timer?.cancel();
    }
  }

  @override
  Future<void> abort() async {
    final sockets = Map<Uri, _UdpSocket>.from(_sockets);
    _sockets.clear();
    sockets.forEach((uri, udp) {
      _close(uri, udp.socket, SocketException.closed());
      udp.socket.close();
    });
  }
}

class UdpTransportCreator implements TransportCreator<UdpTransport> {
  @override
  List<String> schemes = ['udp', 'udp4', 'udp6'];

  @override
  UdpTransport create() {
    return UdpTransport();
  }
}
