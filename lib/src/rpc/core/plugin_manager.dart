/*--------------------------------------------------------*\
|                                                          |
|                          hprose                          |
|                                                          |
| Official WebSite: https://hprose.com                     |
|                                                          |
| plugin_manager.dart                                      |
|                                                          |
| PluginManager for Dart.                                  |
|                                                          |
| LastModified: Feb 16, 2020                               |
| Author: Ma Bingyao <andot@hprose.com>                    |
|                                                          |
\*________________________________________________________*/

part of hprose.rpc.core;

abstract class PluginManager<Handler extends Function,
    NextHandler extends Function> {
  final _handlers = <Handler>[];
  final NextHandler _defaultHandler;
  NextHandler _firstHandler;
  PluginManager(this._defaultHandler) : _firstHandler = _defaultHandler;
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
