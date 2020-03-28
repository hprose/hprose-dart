/*--------------------------------------------------------*\
|                                                          |
|                          hprose                          |
|                                                          |
| Official WebSite: https://hprose.com                     |
|                                                          |
| reverse.dart                                             |
|                                                          |
| Reverse plugin for Dart.                                 |
|                                                          |
| LastModified: Mar 28, 2020                               |
| Author: Ma Bingyao <andot@hprose.com>                    |
|                                                          |
\*________________________________________________________*/

part of hprose.rpc.plugins;

class ProviderContext extends Context {
  final Client client;
  final Method method;
  ProviderContext(this.client, this.method);
}

class Provider {
  var _closed = true;
  var debug = false;
  void Function(dynamic error) onError;
  final Client client;
  final _methodManager = MethodManager();
  InvokeManager _invokeManager;
  String get id {
    if (client.requestHeaders.containsKey('id')) {
      return client.requestHeaders['id'].toString();
    }
    throw Exception('Client unique id not found');
  }

  set id(String value) {
    client.requestHeaders['id'] = value;
  }

  Provider(this.client, [String id]) {
    Method.registerContextType('ProviderContext');
    _invokeManager = InvokeManager(_execute);
    if (id != null && id.isNotEmpty) this.id = id;
    addMethod(_methodManager.getNames, '~');
  }
  Future _execute(String name, List args, Context context) async {
    final method = (context as ProviderContext).method;
    if (method.missing) {
      if (method.passContext) {
        return Function.apply(method.method, [name, args, context]);
      }
      return Function.apply(method.method, [name, args]);
    }
    if (method.namedParameterTypes.isEmpty) {
      if (method.contextInPositionalArguments) {
        args.add(context);
      }
      return Function.apply(method.method, args);
    }
    final namedArguments = args.removeLast();
    if (method.contextInNamedArguments) {
      namedArguments[Symbol('context')] = context;
    }
    return Function.apply(method.method, args, namedArguments);
  }

  Future<List> _process(List call) async {
    final int index = call[0];
    final String name = call[1];
    final List args = call[2].toList(growable: true);
    final method = get(name);
    try {
      if (method == null) {
        throw Exception('Can\'t find this method ${name}().');
      }
      final context = ProviderContext(client, method);
      if (!method.missing) {
        var count = args.length;
        var ppl = method.positionalParameterTypes.length;
        if (count < ppl) {
          args.length = ppl;
        }
        var opl = method.optionalParameterTypes.length;
        var n = ppl + opl;
        if (method.hasOptionalArguments) {
          if (count < ppl) {
            n = ppl;
          } else if (count < n) {
            n = count;
          }
        }
        if (method.hasNamedArguments) {
          n = ppl + 1;
        }
        if (method.contextInPositionalArguments) {
          ppl--;
          n--;
        }
        n = min(count, n);
        args.length = n;
        for (var i = 0; i < n; ++i) {
          if (i < ppl) {
            args[i] = Formatter.deserialize(Formatter.serialize(args[i]),
                type: method.positionalParameterTypes[i]);
          } else if (method.hasOptionalArguments) {
            args[i] = Formatter.deserialize(Formatter.serialize(args[i]),
                type: method.optionalParameterTypes[i - ppl]);
          }
          if (i == ppl && method.hasNamedArguments) {
            if (args[i] is! Map) {
              throw ArgumentError(
                  'Invalid argument, expected named parameters, but positional parameter found.');
            }
            var originalNamedArgs = (args[i] as Map);
            var namedArgs = <Symbol, dynamic>{};
            for (final entry in originalNamedArgs.entries) {
              var name = entry.key.toString();
              if (method.namedParameterTypes.containsKey(name)) {
                var value = Formatter.deserialize(
                    Formatter.serialize(entry.value),
                    type: method.namedParameterTypes[name]);
                namedArgs[Symbol(name)] = value;
              }
            }
            args[i] = namedArgs;
          }
        }
      }
      return [index, await _invokeManager.handler(name, args, context), null];
    } on Error catch (e) {
      return [index, null, debug ? e.stackTrace.toString() : e.toString()];
    } on Exception catch (e) {
      return [index, null, e.toString()];
    }
  }

  void _dispatch(List<List> calls) async {
    final n = calls.length;
    final results = List<Future>(n);
    for (var i = 0; i < n; i++) {
      results[i] = _process(calls[i]);
    }
    try {
      await client.invoke('=', [await Future.wait(results)]);
    } catch (e) {
      if (onError != null) {
        onError(e);
      }
    }
  }

  Future<void> listen() async {
    _closed = false;
    do {
      try {
        final calls = await client.invoke<List<List>>('!');
        if (calls == null) return;
        _dispatch(calls);
      } catch (e) {
        if (onError != null) {
          onError(e);
        }
      }
    } while (!_closed);
  }

  Future<void> close() async {
    _closed = true;
    await client.invoke('!!');
  }

  void use(InvokeHandler handler) => _invokeManager.use(handler);
  void unuse(InvokeHandler handler) => _invokeManager.unuse(handler);
  Method get(String name) => _methodManager.get(name);
  void add(Method method) => _methodManager.add(method);
  void remove(String name) => _methodManager.remove(name);
  void addMethod(Function method, [String name]) =>
      _methodManager.addMethod(method, name);
  void addMethods(List<Function> methods, [List<String> names]) =>
      _methodManager.addMethods(methods, names);
  void addMissingMethod<MissingMethod extends Function>(MissingMethod method) =>
      _methodManager.addMissingMethod(method);
}

class _Proxy {
  final Caller _caller;
  final String _id;
  String _namespace;
  _Proxy(this._caller, this._id, this._namespace) {
    if (_namespace != null && _namespace.isNotEmpty) {
      _namespace += '_';
    } else {
      _namespace = '';
    }
  }
  String _getName(Symbol symbol) {
    var name = symbol.toString();
    return name.substring(8, name.length - 2);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    var name = _namespace + _getName(invocation.memberName);
    if (invocation.isGetter) {
      return _Proxy(_caller, _id, name);
    }
    if (invocation.isMethod) {
      var type = dynamic;
      if (invocation.typeArguments.isNotEmpty) {
        type = invocation.typeArguments.first;
      }
      var args = [];
      if (invocation.positionalArguments.isNotEmpty) {
        args.addAll(invocation.positionalArguments);
      }
      if (invocation.namedArguments.isNotEmpty) {
        var namedArgs = <String, dynamic>{};
        invocation.namedArguments.forEach((name, value) {
          namedArgs[_getName(name)] = value;
        });
        if (namedArgs.isNotEmpty) {
          args.add(namedArgs);
        }
      }
      return _caller._invoke(_id, name, args, type);
    }
    super.noSuchMethod(invocation);
  }
}

class CallerContext extends ServiceContext {
  final Caller caller;
  dynamic proxy;
  CallerContext(this.caller, ServiceContext context) : super(context.service) {
    context.copyTo(this);
    proxy = caller.useService(caller._getId(this));
  }
  invoke<T>(String name, [List args]) {
    caller.invoke<T>(caller._getId(this), name, args);
  }
}

class Caller {
  var _counter = 0;
  final Map<String, List<List>> _calls = {};
  final Map<String, Map<int, Completer>> _results = {};
  final Map<String, Completer<List<List>>> _responders = {};
  final Map<String, bool> _onlines = {};
  final Service service;
  var heartbeat = const Duration(minutes: 2);
  var timeout = const Duration(seconds: 30);
  Caller(this.service) {
    Method.registerContextType('CallerContext');
    service
      ..addMethod(_close, '!!')
      ..addMethod(_begin, '!')
      ..addMethod(_end, '=')
      ..use(_handler);
  }
  String _getId(ServiceContext context) {
    if (context.requestHeaders.containsKey('id')) {
      return context.requestHeaders['id'].toString();
    }
    throw Exception('Client unique id not found');
  }

  bool _send(String id, Completer<List<List>> responder) {
    if (_calls.containsKey(id)) {
      final calls = _calls[id];
      if (calls.isEmpty) {
        return false;
      }
      _calls[id] = [];
      responder.complete(calls);
      return true;
    }
    return false;
  }

  void _response(String id) {
    if (_responders.containsKey(id)) {
      final responder = _responders[id];
      if (_send(id, responder)) {
        _responders.remove(id);
      }
    }
  }

  String _stop(ServiceContext context) {
    final id = _getId(context);
    if (_responders.containsKey(id)) {
      final responder = _responders.remove(id);
      responder.complete(null);
    }
    return id;
  }

  void _close(ServiceContext context) {
    final id = _stop(context);
    _onlines.remove(id);
  }

  Future<List<List>> _begin(ServiceContext context) async {
    final id = _stop(context);
    _onlines.putIfAbsent(id, () => true);
    final responder = Completer<List<List>>();
    if (!_send(id, responder)) {
      _responders[id] = responder;
      if (heartbeat > Duration.zero) {
        var timeoutTimer = Timer(heartbeat, () {
          if (!responder.isCompleted) {
            responder.complete([]);
          }
        });
        await responder.future.then((value) {
          timeoutTimer.cancel();
        });
      }
    }
    return responder.future;
  }

  void _end(List<List> results, ServiceContext context) {
    final id = _getId(context);
    for (var i = 0, n = results.length; i < n; ++i) {
      final item = results[i];
      final int index = item[0];
      final value = item[1];
      final error = item[2];
      if (_results.containsKey(id) && _results[id].containsKey(index)) {
        final result = _results[id].remove(index);
        if (error != null) {
          result.completeError(Exception(error));
        } else {
          result.complete(value);
        }
      }
    }
  }

  Future _invoke(String id, String name, List args, Type returnType) async {
    args ??= [];
    for (var i = 0; i < args.length; i++) {
      if (args[i] is Future) {
        args[i] = await args[i];
      }
    }
    final index = (_counter < 0x7FFFFFFF) ? ++_counter : _counter = 0;
    final result = Completer();
    if (!_calls.containsKey(id)) {
      _calls[id] = [];
    }
    final call = [index, name, args];
    _calls[id].add(call);
    if (!_results.containsKey(id)) {
      _results[id] = {};
    }
    _results[id][index] = result;
    _response(id);
    if (timeout > Duration.zero) {
      var timeoutTimer = Timer(timeout, () {
        if (!result.isCompleted) {
          _calls[id].remove(call);
          _results[id].remove(index);
          result.completeError(TimeoutException('Timeout'));
        }
      });
      await result.future.then((value) {
        timeoutTimer.cancel();
      });
    }
    final value = await result.future;
    if (returnType == dynamic || value.runtimeType == returnType) {
      return value;
    } else {
      return Formatter.deserialize(Formatter.serialize(value),
          type: returnType.toString());
    }
  }

  Future<T> invoke<T>(String id, String name, [List args]) async {
    return (await _invoke(id, name, args, T)) as T;
  }

  dynamic useService(String id, [String namespace]) {
    return _Proxy(this, id, namespace);
  }

  bool exists(String id) {
    return _onlines.containsKey(id);
  }

  List<String> idlist() {
    return _onlines.keys.toList();
  }

  Future _handler(
      String name, List args, Context context, NextInvokeHandler next) {
    return next(name, args, CallerContext(this, context as ServiceContext));
  }
}
