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
| LastModified: Feb 22, 2019                               |
| Author: Ma Bingyao <andot@hprose.com>                    |
|                                                          |
\*________________________________________________________*/

part of hprose.rpc.core;

typedef Future<Uint8List> NextIOHandler(Uint8List request, Context context);
typedef Future<Uint8List> IOHandler(
    Uint8List request, Context context, NextIOHandler next);

class IOManager extends HandlerManager<IOHandler, NextIOHandler> {
  IOManager(NextIOHandler defaultHandler) : super(defaultHandler);
  @override
  NextIOHandler _getNextHandler(IOHandler handler, NextIOHandler next) =>
      (request, context) => handler(request, context, next);
}
