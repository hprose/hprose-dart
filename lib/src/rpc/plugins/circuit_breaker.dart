/*--------------------------------------------------------*\
|                                                          |
|                          hprose                          |
|                                                          |
| Official WebSite: https://hprose.com                     |
|                                                          |
| circuit_breaker.dart                                     |
|                                                          |
| CircuitBreaker plugin for Dart.                          |
|                                                          |
| LastModified: Dec 31, 2019                               |
| Author: Ma Bingyao <andot@hprose.com>                    |
|                                                          |
\*________________________________________________________*/

part of hprose.rpc.plugins;

abstract class MockService {
  Future invoke(String name, List args, Context context);
}

class BreakerError extends Error {
  BreakerError() : super();
  @override
  String toString() => 'Service breaked';
}

class CircuitBreaker {
  DateTime _lastFailTime = DateTime(0);
  int _failCount = 0;
  final int threshold;
  final Duration recoverTime;
  final MockService mockService;
  CircuitBreaker(
      [this.threshold = 5,
      this.recoverTime = const Duration(seconds: 30),
      this.mockService]);

  Future<Uint8List> ioHandler(
      Uint8List request, Context context, NextIOHandler next) async {
    if (_failCount > threshold) {
      var interval = DateTime.now().difference(_lastFailTime);
      if (interval < recoverTime) {
        throw BreakerError();
      }
      _failCount = threshold >> 1;
    }
    try {
      final response = await next(request, context);
      _failCount = 0;
      return response;
    } catch (e) {
      ++_failCount;
      _lastFailTime = DateTime.now();
      rethrow;
    }
  }

  Future invokeHandler(
      String name, List args, Context context, NextInvokeHandler next) async {
    if (mockService == null) {
      return next(name, args, context);
    }
    try {
      return await next(name, args, context);
    } on BreakerError {
      return await mockService.invoke(name, args, context);
    }
  }
}
