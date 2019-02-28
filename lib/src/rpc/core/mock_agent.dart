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
| LastModified: Feb 27, 2019                               |
| Author: Ma Bingyao <andot@hprose.com>                    |
|                                                          |
\*________________________________________________________*/

part of hprose.rpc.core;

typedef Future<Uint8List> _Handler(String address, Uint8List request);

class _MockAgent {
  static final Map<String, _Handler> _handlers = {};
  static register(String address, _Handler handler) {
    _handlers[address] = handler;
  }

  static cancel(String address) {
    _handlers.remove(address);
  }

  static Future<Uint8List> handler(String address, Uint8List request) async {
    if (_handlers.containsKey(address)) {
      return await _handlers[address](address, request);
    }
    throw new Exception('Server is stopped');
  }
}
