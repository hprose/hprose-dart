/*--------------------------------------------------------*\
|                                                          |
|                          hprose                          |
|                                                          |
| Official WebSite: https://hprose.com                     |
|                                                          |
| mock_transport.dart                                      |
|                                                          |
| MockTransport for Dart.                                  |
|                                                          |
| LastModified: Dec 31, 2019                               |
| Author: Ma Bingyao <andot@hprose.com>                    |
|                                                          |
\*________________________________________________________*/

part of hprose.rpc.core;

class MockTransport implements Transport {
  @override
  Future<Uint8List> transport(Uint8List request, Context context) async {
    final clientContext = context as ClientContext;
    final uri = clientContext.uri;
    final result = _MockAgent.handler(uri.host, request);
    if (clientContext.timeout > Duration.zero) {
      var completer = Completer<Uint8List>();
      var timer = Timer(clientContext.timeout, () {
        if (!completer.isCompleted) {
          completer.completeError(TimeoutException('Timeout'));
        }
      });
      try {
        return await Future.any([result, completer.future]);
      } finally {
        timer.cancel();
      }
    }
    return await result;
  }

  @override
  Future<void> abort() async {}
}

class MockTransportCreator implements TransportCreator<MockTransport> {
  @override
  List<String> schemes = ['mock'];
  @override
  MockTransport create() {
    return MockTransport();
  }
}
