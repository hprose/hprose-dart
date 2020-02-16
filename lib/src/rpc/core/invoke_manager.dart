/*--------------------------------------------------------*\
|                                                          |
|                          hprose                          |
|                                                          |
| Official WebSite: https://hprose.com                     |
|                                                          |
| invoke_manager.dart                                      |
|                                                          |
| InvokeManager for Dart.                                  |
|                                                          |
| LastModified: Feb 16, 2020                               |
| Author: Ma Bingyao <andot@hprose.com>                    |
|                                                          |
\*________________________________________________________*/

part of hprose.rpc.core;

typedef NextInvokeHandler = Future Function(
    String name, List args, Context context);
typedef InvokeHandler = Future Function(
    String name, List args, Context context, NextInvokeHandler next);

class InvokeManager extends PluginManager<InvokeHandler, NextInvokeHandler> {
  InvokeManager(NextInvokeHandler defaultHandler) : super(defaultHandler);
  @override
  NextInvokeHandler _getNextHandler(
          InvokeHandler handler, NextInvokeHandler next) =>
      (name, args, context) => handler(name, args, context, next);
}
