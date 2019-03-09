/*--------------------------------------------------------*\
|                                                          |
|                          hprose                          |
|                                                          |
| Official WebSite: https://hprose.com                     |
|                                                          |
| log.dart                                                 |
|                                                          |
| Log plugin for Dart.                                     |
|                                                          |
| LastModified: Mar 6, 2019                                |
| Author: Ma Bingyao <andot@hprose.com>                    |
|                                                          |
\*________________________________________________________*/

part of hprose.rpc.plugins;

class Log {
  final bool enabled;
  const Log([this.enabled = true]);
  Future<Uint8List> ioHandler(
      Uint8List request, Context context, NextIOHandler next) async {
    final enabled =
        context.containsKey('log') ? context['log'] as bool : this.enabled;
    if (!enabled) return next(request, context);
    try {
      print(utf8.decode(request));
    } catch (e) {
      print(e);
    }
    final response = next(request, context);
    response.then((value) => print(utf8.decode(value))).catchError(print);
    return response;
  }

  Future invokeHandler(
      String name, List args, Context context, NextInvokeHandler next) async {
    final enabled =
        context.containsKey('log') ? context['log'] as bool : this.enabled;
    if (!enabled) return next(name, args, context);
    var a = '';
    try {
      a = json.encode((args.length > 0 && args.last is Context)
          ? args.sublist(0, args.length - 1)
          : args);
    } catch (e) {
      print(e);
    }
    final result = next(name, args, context);
    result
        .then((value) => print(
            '${name}(${a.substring(1, a.length - 1)}) = ${json.encode(value)}'))
        .catchError(print);
    return result;
  }
}

const log = const Log();
