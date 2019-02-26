/*--------------------------------------------------------*\
|                                                          |
|                          hprose                          |
|                                                          |
| Official WebSite: https://hprose.com                     |
|                                                          |
| handler_manager.dart                                     |
|                                                          |
| HandlerManager for Dart.                                 |
|                                                          |
| LastModified: Feb 21, 2019                               |
| Author: Ma Bingyao <andot@hprose.com>                    |
|                                                          |
\*________________________________________________________*/

part of hprose.rpc.core;

abstract class HandlerManager<Handler, NextHandler> {
  List<Handler> _handlers = [];
  NextHandler _firstHandler;
  NextHandler _defaultHandler;
  HandlerManager(this._defaultHandler) : _firstHandler = _defaultHandler;
  NextHandler _getNextHandler(Handler handler, NextHandler next);
  void _rebuildHandler() {
    final handlers = _handlers;
    var next = _defaultHandler;
    final n = handlers.length;
    for (var i = n - 1; i >= 0; --i) {
      next = _getNextHandler(handlers[i], next);
    }
    _firstHandler = next;
  }

  NextHandler get handler => _firstHandler;

  void use(Handler handler) {
    _handlers.add(handler);
    _rebuildHandler();
  }

  void unuse(Handler handler) {
    _handlers.remove(handler);
    _rebuildHandler();
  }
}
