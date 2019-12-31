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
| LastModified: Dec 31, 2019                               |
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

  static bool isRegister(String name) {
    return _creators.containsKey(name);
  }

  Duration timeout = Duration(seconds: 30);
  ServiceCodec codec = DefaultServiceCodec.instance;
  int maxRequestLength = 0x7FFFFFFFF;
  InvokeManager _invokeManager;
  IOManager _ioManager;
  final MethodManager _methodManager = MethodManager();
  final _handlers = <String, Handler>{};
  Handler operator [](String name) => _handlers[name];
  void operator []=(String name, Handler value) => _handlers[name] = value;
  List<String> get names => _methodManager.getNames().toList();
  MockHandler get mock => _handlers['mock'];
  final Map<String, dynamic> options = {};
  Service() {
    init();
    _invokeManager = InvokeManager(execute);
    _invokeManager.use(_timeoutHandler);
    _ioManager = IOManager(process);
    _creators
        .forEach((name, creator) => _handlers[name] = creator.create(this));
    addMethod(_methodManager.getNames, '~');
  }

  void init() {
    if (!isRegister('mock')) {
      register<MockHandler>('mock', MockHandlerCreator());
    }
  }

  ServiceContext createContext() => ServiceContext(this);

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
      throw UnsupportedError('This type server is not supported.');
    }
  }

  Future<Uint8List> handle(Uint8List request, Context context) =>
      _ioManager.handler(request, context);

  Future<Uint8List> process(Uint8List request, Context context) async {
    dynamic result;
    try {
      final requestInfo = codec.decode(request, context as ServiceContext);
      result = await _invokeManager.handler(
          requestInfo.name, requestInfo.args, context);
    } catch (e) {
      result = e;
    }
    return codec.encode(result, context as ServiceContext);
  }

  Future _timeoutHandler(String fullname, List args, Context context,
      NextInvokeHandler next) async {
    final task = next(fullname, args, context);
    final serviceContext = context as ServiceContext;
    final timeout = serviceContext.method.timeout > Duration.zero
        ? serviceContext.method.timeout
        : serviceContext.service.timeout;
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
      timer.cancel();
    }
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
      throw TypeError();
    }
  }

  void unuse<T extends Function>(T handler) {
    if (handler is InvokeHandler) {
      _invokeManager.unuse(handler);
    } else if (handler is IOHandler) {
      _ioManager.unuse(handler);
    } else {
      throw TypeError();
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
