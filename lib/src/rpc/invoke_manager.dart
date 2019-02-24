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
| LastModified: Feb 22, 2019                               |
| Author: Ma Bingyao <andot@hprose.com>                    |
|                                                          |
\*________________________________________________________*/

part of hprose.rpc;

typedef Future NextInvokeHandler(String name, List args, Context context);
typedef Future InvokeHandler(
    String name, List args, Context context, NextInvokeHandler next);

class InvokeManager extends HandlerManager<InvokeHandler, NextInvokeHandler> {
  InvokeManager(NextInvokeHandler defaultHandler) : super(defaultHandler);
  @override
  NextInvokeHandler _getNextHandler(
          InvokeHandler handler, NextInvokeHandler next) =>
      (name, args, context) => handler(name, args, context, next);
}
