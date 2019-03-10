/*--------------------------------------------------------*\
|                                                          |
|                          hprose                          |
|                                                          |
| Official WebSite: https://hprose.com                     |
|                                                          |
| websocket_transport.dart                                 |
|                                                          |
| WebSocketTransport for Dart.                             |
|                                                          |
| LastModified: Mar 10, 2019                               |
| Author: Ma Bingyao <andot@hprose.com>                    |
|                                                          |
\*________________________________________________________*/

part of hprose.rpc.browser;

class WebSocketTransport implements Transport {
  int _counter = 0;
  Map<WebSocket, Map<int, Completer<Uint8List>>> _results = {};
  Map<Uri, WebSocket> _sockets = {};

  void _close(Uri uri, WebSocket socket, Object error) async {
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

  Future<WebSocket> _getSocket(Uri uri) async {
    if (_sockets.containsKey(uri)) {
      return _sockets[uri];
    }
    final socket = new WebSocket(uri.toString(), 'hprose');
    socket.binaryType = 'arraybuffer';
    socket.onMessage.listen((event) {
      final istream = new ByteStream.fromByteBuffer(event.data);
      var index = istream.readUInt32BE();
      final response = istream.remains;
      final has_error = (index & 0x80000000) != 0;
      index &= 0x7FFFFFFF;
      if (_results.containsKey(socket)) {
        final results = _results[socket];
        final result = results.remove(index);
        if (has_error) {
          if (result != null && !result.isCompleted) {
            result.completeError(new Exception(utf8.decode(response)));
          }
          _close(uri, socket, new Exception('Socket has been closed'));
          socket.close();
          return;
        } else if (result != null && !result.isCompleted) {
          result.complete(response);
        }
      }
    }, onError: (error) {
      _close(uri, socket, error);
    }, onDone: () {
      _close(uri, socket, new Exception('Socket has been closed'));
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
    final socket = await _getSocket(uri);
    if (!_results.containsKey(socket)) {
      _results[socket] = {};
    }
    final results = _results[socket];
    results[index] = result;
    Timer timer;
    if (clientContext.timeout > Duration.zero) {
      timer = new Timer(clientContext.timeout, () {
        if (!result.isCompleted) {
          result.completeError(new TimeoutException('Timeout'));
          abort();
        }
      });
    }
    final n = request.length;
    final data = new Uint8List(4 + n);
    final view = new ByteData.view(data.buffer);
    view.setUint32(0, index, Endian.big);
    data.setRange(4, 4 + n, request);
    socket.sendTypedData(data);
    try {
      return await result.future;
    } finally {
      timer?.cancel();
    }
  }

  @override
  Future<void> abort() async {
    Map<Uri, WebSocket> sockets = new Map.from(_sockets);
    _sockets.clear();
    sockets.forEach((uri, socket) {
      _close(uri, socket, new Exception('Socket has been closed'));
      socket.close();
    });
  }
}

class WebSocketTransportCreator
    implements TransportCreator<WebSocketTransport> {
  @override
  List<String> schemes = ['ws', 'wss'];

  @override
  WebSocketTransport create() {
    return new WebSocketTransport();
  }
}
