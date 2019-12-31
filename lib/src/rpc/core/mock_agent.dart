/*--------------------------------------------------------*\
|                                                          |
|                          hprose                          |
|                                                          |
| Official WebSite: https://hprose.com                     |
|                                                          |
| mock_agent.dart                                          |
|                                                          |
| MockAgent for Dart.                                      |
|                                                          |
| LastModified: Dec 31, 2019                               |
| Author: Ma Bingyao <andot@hprose.com>                    |
|                                                          |
\*________________________________________________________*/

part of hprose.rpc.core;

typedef _Handler = Future<Uint8List> Function(
    String address, Uint8List request);

class _MockAgent {
  static final Map<String, _Handler> _handlers = {};
  static void register(String address, _Handler handler) {
    _handlers[address] = handler;
  }

  static void cancel(String address) {
    _handlers.remove(address);
  }

  static Future<Uint8List> handler(String address, Uint8List request) async {
    if (_handlers.containsKey(address)) {
      return await _handlers[address](address, request);
    }
    throw Exception('Server is stopped');
  }
}
