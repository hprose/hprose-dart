/*--------------------------------------------------------*\
|                                                          |
|                          hprose                          |
|                                                          |
| Official WebSite: https://hprose.com                     |
|                                                          |
| service.dart                                             |
|                                                          |
| hprose Service for Dart.                                 |
|                                                          |
| LastModified: Feb 28, 2019                               |
| Author: Ma Bingyao <andot@hprose.com>                    |
|                                                          |
\*________________________________________________________*/

part of hprose.rpc.core;

abstract class Handler<T> {
  void bind(T server);
}

abstract class HandlerCreator<T extends Handler> {
  List<String> serverTypes;
  T create(Service service);
}

class Service {
  static final Map<String, HandlerCreator> _creators = {};
  static final Map<String, List<String>> _serverTypes = {};
  static void register<T extends Handler>(
      String name, HandlerCreator<T> creator) {
    _creators[name] = creator;
    creator.serverTypes.forEach((type) {
      if (_serverTypes.containsKey(type)) {
        _serverTypes[type].add(name);
      } else {
        _serverTypes[type] = [name];
      }
    });
  }

  Duration timeout = new Duration(seconds: 30);
  ServiceCodec codec = DefaultServiceCodec.instance;
  int maxRequestLength = 0x7FFFFFFFF;
  InvokeManager _invokeManager;
  IOManager _ioManager;
  final MethodManager _methodManager = new MethodManager();
  Map<String, Handler> _handlers = {};
  Handler operator [](String name) => _handlers[name];
  void operator []=(String name, Handler value) => _handlers[name] = value;
  Service() {
    if (!_creators.containsKey('mock')) {
      register<MockHandler>('mock', new MockHandlerCreator());
    }

    _invokeManager = new InvokeManager(execute);
    _ioManager = new IOManager(process);
    _creators
        .forEach((name, creator) => _handlers[name] = creator.create(this));
    add(new Method(_methodManager.getNames, '~'));
  }
  void bind(dynamic server, [String name]) {
    final type = server.runtimeType.toString();
    if (_serverTypes.containsKey(type)) {
      final names = _serverTypes[type];
      for (var i = 0, n = names.length; i < n; ++i) {
        if ((name == null) || (name == names[i])) {
          _handlers[names[i]].bind(server);
        }
      }
    } else {
      throw new UnsupportedError('This type server is not supported.');
    }
  }

  Future<Uint8List> handle(Uint8List request, Context context) =>
      _ioManager.handler(request, context);

  Future<Uint8List> process(Uint8List request, Context context) async {
    dynamic result;
    try {
      final requestInfo = codec.decode(request, context as ServiceContext);
      if (timeout > Duration.zero) {
        var completer = new Completer();
        var timer = new Timer(timeout,
            () => completer.completeError(new TimeoutException('Timeout')));
        _invokeManager
            .handler(requestInfo.name, requestInfo.args, context)
            .then((value) {
          timer.cancel();
          completer.complete(value);
        }, onError: (error) {
          timer.cancel();
          completer.completeError(error);
        });
        result = await completer.future;
      } else {
        result = await _invokeManager.handler(
            requestInfo.name, requestInfo.args, context);
      }
    } catch (e) {
      result = e;
    }
    return codec.encode(result, context as ServiceContext);
  }

  Future execute(String fullname, List args, Context context) async {
    final method = (context as ServiceContext).method;
    if (method.missing) {
      if (method.passContext) {
        return Function.apply(method.method, [fullname, args, context]);
      }
      return Function.apply(method.method, [fullname, args]);
    }
    if (method.namedParameterTypes.isEmpty) {
      return Function.apply(method.method, args);
    }
    final namedArguments = args.removeLast();
    return Function.apply(method.method, args, namedArguments);
  }

  void use<T extends Function>(T handler) {
    if (handler is InvokeHandler) {
      _invokeManager.use(handler);
    } else if (handler is IOHandler) {
      _ioManager.use(handler);
    } else {
      throw new TypeError();
    }
  }

  void unuse<T extends Function>(T handler) {
    if (handler is InvokeHandler) {
      _invokeManager.unuse(handler);
    } else if (handler is IOHandler) {
      _ioManager.unuse(handler);
    } else {
      throw new TypeError();
    }
  }

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
