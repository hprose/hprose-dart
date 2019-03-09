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
| LastModified: Mar 9, 2019                                |
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
  bool _closed = true;
  bool debug = false;
  void Function(dynamic error) onError;
  final Client client;
  final MethodManager _methodManager = new MethodManager();
  InvokeManager _invokeManager;
  String get id {
    if (client.requestHeaders.containsKey('id')) {
      return client.requestHeaders['id'].toString();
    }
    throw new Exception('Client unique id not found');
  }

  set id(String value) {
    client.requestHeaders['id'] = value;
  }

  Provider(this.client, [String id]) {
    _invokeManager = new InvokeManager(_execute);
    if (id != null && id.isNotEmpty) this.id = id;
    add(new Method(_methodManager.getNames, '~'));
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
      return Function.apply(method.method, args);
    }
    final namedArguments = args.removeLast();
    return Function.apply(method.method, args, namedArguments);
  }

  Future<List> _process(List call) async {
    final int index = call[0];
    final String name = call[1];
    final List args = call[2].toList(growable: true);
    final Method method = get(name);
    try {
      if (method == null) {
        throw new Exception('Can\'t find this method ${name}().');
      }
      final context = new ProviderContext(client, method);
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
        if (count > n) {
          args.length = n;
        }
        if (method.contextInPositionalArguments) {
          ppl--;
          n--;
        }
        n = min(count, n);
        for (int i = 0; i < n; ++i) {
          if (i < ppl) {
            args[i] = Formatter.deserialize(Formatter.serialize(args[i]),
                type: method.positionalParameterTypes[i]);
          } else if (method.hasOptionalArguments) {
            args[i] = Formatter.deserialize(Formatter.serialize(args[i]),
                type: method.optionalParameterTypes[i - ppl]);
          }
          if (i == ppl && method.hasNamedArguments) {
            if (args[i] is! Map) {
              throw new ArgumentError(
                  'Invalid argument, expected named parameters, but positional parameter found.');
            }
            var originalNamedArgs = (args[i] as Map);
            var namedArgs = new Map<Symbol, dynamic>();
            for (final entry in originalNamedArgs.entries) {
              var name = entry.key.toString();
              if (method.namedParameterTypes.containsKey(name)) {
                var value = Formatter.deserialize(
                    Formatter.serialize(entry.value),
                    type: method.namedParameterTypes[name]);
                namedArgs[new Symbol(name)] = value;
              }
            }
            if (method.contextInNamedArguments) {
              namedArgs[new Symbol('context')] = context;
            }
            args[i] = namedArgs;
          }
        }
        if (method.contextInPositionalArguments) {
          args[ppl] = context;
        }
      }
      return [index, await _invokeManager.handler(name, args, context), null];
    } on Error catch (e) {
      return [index, null, debug ? e.stackTrace.toString() : e.toString()];
    } on Exception catch (e) {
      return [index, null, e.toString()];
    }
  }

  Future<void> _dispatch(List<List> calls) async {
    final n = calls.length;
    final results = new List<Future>(n);
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
  Method get(String fullname) => _methodManager.get(fullname);
  void add(Method method) => _methodManager.add(method);
  void remove(String fullname) => _methodManager.remove(fullname);
  void addMethod(Function method, [String fullname]) =>
      _methodManager.addMethod(method, fullname);
  void addMethods(List<Function> methods, [List<String> fullnames]) =>
      _methodManager.addMethods(methods, fullnames);
  void addMissingMethod<MissingMethod extends Function>(MissingMethod method) =>
      _methodManager.addMissingMethod(method);
}

class _Proxy {
  final Caller _caller;
  String _id;
  String _namespace;
  _Proxy(this._caller, this._id, this._namespace) {
    if (_namespace != null && _namespace.isNotEmpty) {
      _namespace += '_';
    } else {
      _namespace = '';
    }
  }
  String _getName(Symbol symbol) {
    String name = symbol.toString();
    return name.substring(8, name.length - 2);
  }

  noSuchMethod(Invocation mirror) {
    String name = _namespace + _getName(mirror.memberName);
    if (mirror.isGetter) {
      return new _Proxy(_caller, _id, name);
    }
    if (mirror.isMethod) {
      Type type = dynamic;
      if (mirror.typeArguments.isNotEmpty) {
        type = mirror.typeArguments.first;
      }
      var args = [];
      if (mirror.positionalArguments.isNotEmpty) {
        args.addAll(mirror.positionalArguments);
      }
      if (mirror.namedArguments.isNotEmpty) {
        var namedArgs = new Map<String, dynamic>();
        mirror.namedArguments.forEach((name, value) {
          namedArgs[_getName(name)] = value;
        });
        if (namedArgs.isNotEmpty) {
          args.add(namedArgs);
        }
      }
      return _caller._invoke(_id, name, args, type);
    }
    super.noSuchMethod(mirror);
  }
}

class Caller {
  int _counter = 0;
  final Map<String, List<List>> _calls = {};
  final Map<String, Map<int, Completer>> _results = {};
  final Map<String, Completer<List<List>>> _responders = {};
  final Map<String, Completer<bool>> _timers = {};
  final Service service;
  Duration timeout = const Duration(minutes: 2);
  Caller(this.service) {
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
    throw new Exception('Client unique id not found');
  }

  bool _send(String id, Completer<List<List>> responder) {
    if (_calls.containsKey(id)) {
      final calls = _calls[id];
      if (calls.length == 0) {
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

  String _close(ServiceContext context) {
    final id = _getId(context);
    if (_responders.containsKey(id)) {
      final responder = _responders.remove(id);
      responder.complete(null);
    }
    return id;
  }

  Future<List<List>> _begin(ServiceContext context) async {
    final id = _close(context);
    final responder = new Completer<List<List>>();
    if (!_send(id, responder)) {
      _responders[id] = responder;
      if (timeout > Duration.zero) {
        var timeoutTimer = new Timer(timeout, () {
          if (!responder.isCompleted) {
            responder.complete([]);
          }
        });
        responder.future.then((value) {
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
          result.completeError(new Exception(error));
        } else {
          result.complete(value);
        }
      }
    }
  }

  Future _invoke(String id, String fullname, List args, Type returnType) async {
    if (args == null) args = [];
    for (var i = 0; i < args.length; i++) {
      if (args[i] is Future) {
        args[i] = await args[i];
      }
    }
    if (++_counter > 0x7FFFFFFF) {
      _counter = 0;
    }
    final index = _counter;
    final result = new Completer();
    if (!_calls.containsKey(id)) {
      _calls[id] = [];
    }
    _calls[id].add([index, fullname, args]);
    if (!_results.containsKey(id)) {
      _results[id] = {};
    }
    _results[id][index] = result;
    _response(id);
    final value = await result.future;
    if (returnType == dynamic || value.runtimeType == returnType) {
      return value;
    } else {
      return Formatter.deserialize(Formatter.serialize(value),
          type: returnType.toString());
    }
  }

  Future<T> invoke<T>(String id, String fullname, [List args]) async {
    return (await _invoke(id, fullname, args, T)) as T;
  }

  dynamic useService(String id, [String namespace]) {
    return new _Proxy(this, id, namespace);
  }

  Future _handler(
      String name, List args, Context context, NextInvokeHandler next) {
    context['invoke'] = <T>(String fullname, [List args]) =>
        invoke<T>(_getId(context as ServiceContext), fullname, args);
    return next(name, args, context);
  }
}
