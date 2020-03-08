/*--------------------------------------------------------*\
|                                                          |
|                          hprose                          |
|                                                          |
| Official WebSite: https://hprose.com                     |
|                                                          |
| timeout.dart                                             |
|                                                          |
| Timeout plugin for Dart.                                 |
|                                                          |
| LastModified: Mar 8, 2020                                |
| Author: Ma Bingyao <andot@hprose.com>                    |
|                                                          |
\*________________________________________________________*/

part of hprose.rpc.plugins;

class Timeout {
  Duration timeout = Duration(seconds: 30);
  Timeout([Duration timeout = Duration.zero]) {
    if (timeout != Duration.zero) {
      this.timeout = timeout;
    }
  }
  Future handler(
      String name, List args, Context context, NextInvokeHandler next) async {
    final task = next(name, args, context);
    final serviceContext = context as ServiceContext;
    var timeout = this.timeout;
    if (serviceContext.method.options.containsKey('timeout')) {
      timeout = serviceContext.method.options['timeout'];
    }
    if (timeout <= Duration.zero) {
      return await task;
    }
    var completer = Completer();
    var timer = Timer(timeout, () {
      if (!completer.isCompleted) {
        completer.completeError(TimeoutException('Timeout'));
      }
    });
    try {
      return await Future.any([task, completer.future]);
    } finally {
      completer.complete(null);
      timer.cancel();
    }
  }
}
