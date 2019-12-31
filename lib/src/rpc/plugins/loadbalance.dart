/*--------------------------------------------------------*\
|                                                          |
|                          hprose                          |
|                                                          |
| Official WebSite: https://hprose.com                     |
|                                                          |
| loadbalance.dart                                         |
|                                                          |
| LoadBalance plugin for Dart.                             |
|                                                          |
| LastModified: Dec 31, 2019                               |
| Author: Ma Bingyao <andot@hprose.com>                    |
|                                                          |
\*________________________________________________________*/

part of hprose.rpc.plugins;

class RandomLoadBalance {
  final _random = Random.secure();
  Future<Uint8List> handler(
      Uint8List request, Context context, NextIOHandler next) {
    final clientContext = context as ClientContext;
    final uris = clientContext.client.uris;
    final n = uris.length;
    clientContext.uri = uris[_random.nextInt(n)];
    return next(request, context);
  }
}

class RoundRobinLoadBalance {
  var _index = -1;
  Future<Uint8List> handler(
      Uint8List request, Context context, NextIOHandler next) {
    final clientContext = context as ClientContext;
    final uris = clientContext.client.uris;
    final n = uris.length;
    if (n > 1) {
      if (++_index >= n) {
        _index = 0;
      }
      clientContext.uri = uris[_index];
    }
    return next(request, context);
  }
}

class LeastActiveLoadBalance {
  final _actives = <int>[];
  final _random = Random.secure();
  Future<Uint8List> handler(
      Uint8List request, Context context, NextIOHandler next) async {
    final clientContext = context as ClientContext;
    final uris = clientContext.client.uris;
    final n = uris.length;
    if (_actives.length < n) {
      _actives.length = n;
      _actives.fillRange(0, n, 0);
    }
    final leastActive = _actives.sublist(0, n).reduce(min);
    final leastActiveIndexes = <int>[];
    for (var i = 0; i < n; ++i) {
      if (_actives[i] == leastActive) {
        leastActiveIndexes.add(i);
      }
    }
    var index = leastActiveIndexes[0];
    final count = leastActiveIndexes.length;
    if (count > 1) {
      index = leastActiveIndexes[_random.nextInt(count)];
    }
    clientContext.uri = uris[index];
    _actives[index]++;
    try {
      return await next(request, context);
    } finally {
      _actives[index]--;
    }
  }
}

abstract class WeightedLoadBalance {
  List<Uri> _uris;
  List<int> _weights;
  WeightedLoadBalance(Map<Uri, int> uris) {
    if (uris == null) {
      throw ArgumentError.notNull('uris');
    }
    if (uris.isEmpty) {
      throw ArgumentError('uris cannot be empty');
    }
    for (final weight in uris.values) {
      if (weight <= 0) {
        throw ArgumentError('uris weight must be great than 0');
      }
    }
    _uris = uris.keys.toList(growable: false);
    _weights = uris.values.toList(growable: false);
  }
}

class WeightedRandomLoadBalance extends WeightedLoadBalance {
  List<int> _effectiveWeights;
  final _random = Random.secure();
  WeightedRandomLoadBalance(Map<Uri, int> uris) : super(uris) {
    _effectiveWeights = _weights.toList(growable: false);
  }
  Future<Uint8List> handler(
      Uint8List request, Context context, NextIOHandler next) async {
    final n = _uris.length;
    var index = n - 1;
    final totalWeight = _effectiveWeights.reduce((x, y) => x + y);
    if (totalWeight > 0) {
      var currentWeight = _random.nextInt(totalWeight);
      for (var i = 0; i < n; ++i) {
        currentWeight -= _effectiveWeights[i];
        if (currentWeight < 0) {
          index = i;
          break;
        }
      }
    } else {
      index = _random.nextInt(n);
    }
    (context as ClientContext).uri = _uris[index];
    try {
      final response = await next(request, context);
      if (_effectiveWeights[index] < _weights[index]) {
        _effectiveWeights[index]++;
      }
      return response;
    } catch (e) {
      if (_effectiveWeights[index] > 0) {
        _effectiveWeights[index]--;
      }
      rethrow;
    }
  }
}

int gcd(int x, int y) {
  if (x < y) {
    var t = x;
    x = y;
    y = t;
  }
  while (y != 0) {
    var t = x;
    x = y;
    y = t % y;
  }
  return x;
}

class WeightedRoundRobinLoadBalance extends WeightedLoadBalance {
  int _maxWeight;
  int _gcdWeight;
  var _index = -1;
  var _currentWeight = 0;
  WeightedRoundRobinLoadBalance(Map<Uri, int> uris) : super(uris) {
    _maxWeight = _weights.reduce(max);
    _gcdWeight = _weights.reduce(gcd);
  }
  Future<Uint8List> handler(
      Uint8List request, Context context, NextIOHandler next) async {
    final n = _uris.length;
    while (true) {
      _index = (_index + 1) % n;
      if (_index == 0) {
        _currentWeight -= _gcdWeight;
        if (_currentWeight <= 0) {
          _currentWeight = _maxWeight;
        }
      }
      if (_weights[_index] >= _currentWeight) {
        (context as ClientContext).uri = _uris[_index];
        return next(request, context);
      }
    }
  }
}

class NginxRoundRobinLoadBalance extends WeightedLoadBalance {
  List<int> _effectiveWeights;
  List<int> _currentWeights;
  final _random = Random.secure();
  NginxRoundRobinLoadBalance(Map<Uri, int> uris) : super(uris) {
    final n = uris.length;
    _effectiveWeights = _weights.toList(growable: false);
    _currentWeights = List<int>(n)..fillRange(0, n, 0);
  }
  Future<Uint8List> handler(
      Uint8List request, Context context, NextIOHandler next) async {
    final n = _uris.length;
    var index = -1;
    final totalWeight = _effectiveWeights.reduce((x, y) => x + y);
    if (totalWeight > 0) {
      var currentWeight = -2 ^ 53;
      for (var i = 0; i < n; ++i) {
        var weight = (_currentWeights[i] += _effectiveWeights[i]);
        if (currentWeight < weight) {
          currentWeight = weight;
          index = i;
        }
      }
      _currentWeights[index] = currentWeight - totalWeight;
    } else {
      index = _random.nextInt(n);
    }
    (context as ClientContext).uri = _uris[index];
    try {
      final response = await next(request, context);
      if (_effectiveWeights[index] < _weights[index]) {
        _effectiveWeights[index]++;
      }
      return response;
    } catch (e) {
      if (_effectiveWeights[index] > 0) {
        _effectiveWeights[index]--;
      }
      rethrow;
    }
  }
}

class WeightedLeastActiveLoadBalance extends WeightedLoadBalance {
  List<int> _effectiveWeights;
  List<int> _actives;
  final _random = Random.secure();
  WeightedLeastActiveLoadBalance(Map<Uri, int> uris) : super(uris) {
    final n = uris.length;
    _effectiveWeights = _weights.toList(growable: false);
    _actives = List<int>(n)..fillRange(0, n, 0);
  }
  Future<Uint8List> handler(
      Uint8List request, Context context, NextIOHandler next) async {
    final leastActive = _actives.reduce(min);
    final leastActiveIndexes = <int>[];
    var totalWeight = 0;
    for (var i = 0; i < _weights.length; ++i) {
      if (_actives[i] == leastActive) {
        leastActiveIndexes.add(i);
        totalWeight += _effectiveWeights[i];
      }
    }
    var index = leastActiveIndexes[0];
    final n = leastActiveIndexes.length;
    if (n > 1) {
      if (totalWeight > 0) {
        var currentWeight = _random.nextInt(totalWeight);
        for (var i = 0; i < n; ++i) {
          currentWeight -= _effectiveWeights[leastActiveIndexes[i]];
          if (currentWeight < 0) {
            index = leastActiveIndexes[i];
            break;
          }
        }
      } else {
        index = leastActiveIndexes[_random.nextInt(n)];
      }
    }
    (context as ClientContext).uri = _uris[index];
    _actives[index]++;
    try {
      final response = await next(request, context);
      _actives[index]--;
      if (_effectiveWeights[index] < _weights[index]) {
        _effectiveWeights[index]++;
      }
      return response;
    } catch (e) {
      _actives[index]--;
      if (_effectiveWeights[index] > 0) {
        _effectiveWeights[index]--;
      }
      rethrow;
    }
  }
}
