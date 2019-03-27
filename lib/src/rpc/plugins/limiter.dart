/*--------------------------------------------------------*\
|                                                          |
|                          hprose                          |
|                                                          |
| Official WebSite: https://hprose.com                     |
|                                                          |
| limiter.dart                                             |
|                                                          |
| Limiter plugin for Dart.                                 |
|                                                          |
| LastModified: Mar 27, 2019                               |
| Author: Ma Bingyao <andot@hprose.com>                    |
|                                                          |
\*________________________________________________________*/

part of hprose.rpc.plugins;

class RateLimiter {
  double _interval;
  int _next = DateTime.now().millisecondsSinceEpoch;
  final int permitsPerSecond;
  final double maxPermits;
  final Duration timeout;
  RateLimiter(this.permitsPerSecond,
      [this.maxPermits = double.infinity, this.timeout = Duration.zero]) {
    _interval = Duration.millisecondsPerSecond / permitsPerSecond;
  }
  Future<int> acquire([int tokens = 1]) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final last = _next;
    double permits = (now - last) / _interval - tokens;
    if (permits > maxPermits) {
      permits = maxPermits;
    }
    _next = (now - permits * _interval).floor();
    var delay = new Duration(milliseconds: last - now);
    if (delay <= Duration.zero) return last;
    if (timeout > Duration.zero && delay > timeout) {
      throw new TimeoutException('Timeout');
    }
    await Future.delayed(delay);
    return last;
  }

  Future<Uint8List> ioHandler(
      Uint8List request, Context context, NextIOHandler next) async {
    await acquire(request.length);
    return next(request, context);
  }

  Future invokeHandler(
      String name, List args, Context context, NextInvokeHandler next) async {
    await acquire();
    return next(name, args, context);
  }
}

class ConcurrentLimiter {
  int _counter = 0;
  Queue<Completer<void>> _tasks = new Queue<Completer<void>>();
  final int maxConcurrentRequests;
  final Duration timeout;
  ConcurrentLimiter(this.maxConcurrentRequests, [this.timeout = Duration.zero]);
  Future<void> acquire() async {
    if (++_counter <= maxConcurrentRequests) return null;
    final task = new Completer<void>();
    _tasks.add(task);
    Timer timer;
    if (timeout > Duration.zero) {
      timer = new Timer(timeout, () {
        if (_tasks.remove(task)) {
          --_counter;
        }
        if (!task.isCompleted) {
          task.completeError(new TimeoutException('Timeout'));
        }
      });
    }
    try {
      return await task.future;
    } finally {
      timer?.cancel();
    }
  }

  void release() {
    --_counter;
    if (_tasks.isNotEmpty) {
      final task = _tasks.removeFirst();
      if (!task.isCompleted) {
        task.complete();
      }
    }
  }

  Future handler(
      String name, List args, Context context, NextInvokeHandler next) async {
    await acquire();
    try {
      return await next(name, args, context);
    } finally {
      release();
    }
  }
}
