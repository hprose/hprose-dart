/*--------------------------------------------------------*\
|                                                          |
|                          hprose                          |
|                                                          |
| Official WebSite: https://hprose.com                     |
|                                                          |
| io_manager.dart                                          |
|                                                          |
| IOManager for Dart.                                      |
|                                                          |
| LastModified: Feb 16, 2020                               |
| Author: Ma Bingyao <andot@hprose.com>                    |
|                                                          |
\*________________________________________________________*/

part of hprose.rpc.core;

typedef NextIOHandler = Future<Uint8List> Function(
    Uint8List request, Context context);
typedef IOHandler = Future<Uint8List> Function(
    Uint8List request, Context context, NextIOHandler next);

class IOManager extends PluginManager<IOHandler, NextIOHandler> {
  IOManager(NextIOHandler defaultHandler) : super(defaultHandler);
  @override
  NextIOHandler _getNextHandler(IOHandler handler, NextIOHandler next) =>
      (request, context) => handler(request, context, next);
}
