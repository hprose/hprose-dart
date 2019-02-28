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
| LastModified: Feb 27, 2019                               |
| Author: Ma Bingyao <andot@hprose.com>                    |
|                                                          |
\*________________________________________________________*/

part of hprose.rpc.core;

class MockTransport implements Transport {
  @override
  Future<Uint8List> transport(Uint8List request, Context context) async {
    final clientContext = context as ClientContext;
    final uri = clientContext.uri;
    if (clientContext.timeout > Duration.zero) {
      var completer = new Completer<Uint8List>();
      var timer = new Timer(clientContext.timeout,
          () => completer.completeError(new TimeoutException('Timeout')));
      _MockAgent.handler(uri.host, request).then((value) {
        timer.cancel();
        completer.complete(value);
      }, onError: (error) {
        timer.cancel();
        completer.completeError(error);
      });
      return await completer.future;
    }
    return await _MockAgent.handler(uri.host, request);
  }

  @override
  Future<void> abort() {
    return Future<void>.value();
  }
}

class MockTransportCreator implements TransportCreator<MockTransport> {
  @override
  List<String> schemes = ['mock'];
  @override
  MockTransport create() {
    return new MockTransport();
  }
}
