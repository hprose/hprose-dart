/*--------------------------------------------------------*\
|                                                          |
|                          hprose                          |
|                                                          |
| Official WebSite: https://hprose.com                     |
|                                                          |
| socket_transport.dart                                    |
|                                                          |
| SocketTransport for Dart.                                |
|                                                          |
| LastModified: Mar 3, 2019                                |
| Author: Ma Bingyao <andot@hprose.com>                    |
|                                                          |
\*________________________________________________________*/

part of hprose.rpc;

class SocketTransport implements Transport {
  int _counter = 0;
  Map<Socket, Map<int, Completer<Uint8List>>> _results = {};
  Map<Uri, Socket> _sockets = {};
  bool noDelay = true;
  SecurityContext securityContext = null;
  bool Function(X509Certificate certificate) onBadCertificate = (_) => true;

  Future<Socket> _connect(Uri uri, Duration timeout) async {
    switch (uri.scheme) {
      case 'tcp':
      case 'tls':
      case 'ssl':
      case 'tcp4':
      case 'tls4':
      case 'ssl4':
      case 'tcp6':
      case 'tls6':
      case 'ssl6':
        break;
      default:
        throw new Exception('unsupported ${uri.scheme} protocol');
    }
    var host;
    if (uri.scheme.endsWith('4')) {
      host = (await InternetAddress.lookup(uri.host,
              type: InternetAddressType.IPv4))
          .first;
    } else if (uri.scheme.endsWith('6')) {
      host = (await InternetAddress.lookup(uri.host,
              type: InternetAddressType.IPv6))
          .first;
    } else {
      host = uri.host;
    }
    var port = uri.port == 0 ? 8412 : uri.port;
    if (uri.scheme.startsWith('tcp')) {
      return await Socket.connect(host, port, timeout: timeout);
    }
    return await SecureSocket.connect(host, port,
        context: securityContext,
        onBadCertificate: onBadCertificate,
        timeout: timeout);
  }

  void _close(Uri uri, Socket socket, Object error) async {
    if (_sockets.containsKey(uri) && _sockets[uri] == socket) {
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

  void Function(List<int>) _receive(Uri uri, Socket socket) {
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
          if (crc32(header) != crc || (header[0] & 0x80) == 0) {
            _close(uri, socket, new Exception('Invalid response'));
            socket.destroy();
            return;
          }
          instream.reset();
          bodyLength = instream.readInt32BE() & 0x7FFFFFFF;
          index = instream.readInt32BE();
        }
        if ((bodyLength >= 0) &&
            ((instream.length - headerLength) >= bodyLength)) {
          final response = instream.read(bodyLength);
          instream.trunc();
          bodyLength = -1;
          final has_error = (index & 0x80000000) != 0;
          index &= 0x7FFFFFFF;
          if (_results.containsKey(socket)) {
            final results = _results[socket];
            final result = results.remove(index);
            if (has_error) {
              if (result != null && !result.isCompleted) {
                result.completeError(new Exception(utf8.decode(response)));
              }
              _close(uri, socket, new SocketException.closed());
              socket.destroy();
              return;
            } else if (result != null && !result.isCompleted) {
              result.complete(response);
            }
          }
        } else {
          break;
        }
      }
    };
  }

  Future<Socket> _getSocket(Uri uri, Duration timeout) async {
    if (_sockets.containsKey(uri)) {
      return _sockets[uri];
    }
    final socket = await _connect(uri, timeout);
    socket.setOption(SocketOption.tcpNoDelay, noDelay);
    socket.listen(_receive(uri, socket), onError: (error) {
      _close(uri, socket, error);
    }, onDone: () {
      _close(uri, socket, new SocketException.closed());
    }, cancelOnError: true);
    _sockets[uri] = socket;
    return socket;
  }

  @override
  Future<Uint8List> transport(Uint8List request, Context context) async {
    final clientContext = context as ClientContext;
    final uri = clientContext.uri;
    final index = (_counter < 0x7FFFFFFF) ? ++_counter : _counter = 0;
    final result = new Completer<Uint8List>();
    final socket = await _getSocket(uri, clientContext.timeout);
    if (!_results.containsKey(socket)) {
      _results[socket] = {};
    }
    final results = _results[socket];
    results[index] = result;
    if (clientContext.timeout > Duration.zero) {
      var timer = new Timer(clientContext.timeout, () {
        if (!result.isCompleted) {
          result.completeError(new TimeoutException('Timeout'));
          abort();
        }
      });
      result.future.then((value) {
        timer.cancel();
      }, onError: (reason) {
        timer.cancel();
      });
    }
    final n = request.length;
    final header = new Uint8List(12);
    final view = new ByteData.view(header.buffer);
    view.setInt32(4, n | 0x80000000, Endian.big);
    view.setInt32(8, index, Endian.big);
    final crc = crc32(header.sublist(4, 12));
    view.setUint32(0, crc);
    socket.add(header);
    socket.add(request);
    return await result.future;
  }

  @override
  Future<void> abort() async {
    Map<Uri, Socket> sockets = new Map.from(_sockets);
    _sockets.clear();
    sockets.forEach((uri, socket) {
      _close(uri, socket, new SocketException.closed());
      socket.destroy();
    });
  }
}

class SocketTransportCreator implements TransportCreator<SocketTransport> {
  @override
  List<String> schemes = [
    'tcp',
    'tcp4',
    'tcp6',
    'tls',
    'tls4',
    'tls6',
    'ssl',
    'ssl4',
    'ssl6'
  ];

  @override
  SocketTransport create() {
    return new SocketTransport();
  }
}
