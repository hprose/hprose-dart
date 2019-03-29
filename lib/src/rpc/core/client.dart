/*--------------------------------------------------------*\
|                                                          |
|                          hprose                          |
|                                                          |
| Official WebSite: https://hprose.com                     |
|                                                          |
| client.dart                                              |
|                                                          |
| hprose Client for Dart.                                  |
|                                                          |
| LastModified: Mar 29, 2019                               |
| Author: Ma Bingyao <andot@hprose.com>                    |
|                                                          |
\*________________________________________________________*/

part of hprose.rpc.core;

abstract class Transport {
  Future<Uint8List> transport(Uint8List request, Context context);
  Future<void> abort();
}

abstract class TransportCreator<T extends Transport> {
  List<String> schemes;
  T create();
}

class _Proxy {
  final Client _client;
  String _namespace;
  _Proxy(this._client, this._namespace) {
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
      return new _Proxy(_client, name);
    }
    if (mirror.isMethod) {
      Type type = dynamic;
      if (mirror.typeArguments.isNotEmpty) {
        type = mirror.typeArguments.first;
      }
      ClientContext context;
      var args = [];
      if (mirror.positionalArguments.isNotEmpty) {
        args.addAll(mirror.positionalArguments);
        if (args.last is Context) {
          context = args.removeLast();
        }
      }
      if (mirror.namedArguments.isNotEmpty) {
        var namedArgs = new Map<String, dynamic>();
        mirror.namedArguments.forEach((name, value) {
          namedArgs[_getName(name)] = value;
        });
        if (namedArgs.containsKey('context') &&
            namedArgs['context'] is Context) {
          context = namedArgs.remove('context');
        }
        if (namedArgs.isNotEmpty) {
          args.add(namedArgs);
        }
      }
      if (context == null) {
        context = new ClientContext();
      }
      context.returnType = type;
      return _client.invoke(name, args, context);
    }
    super.noSuchMethod(mirror);
  }
}

class Client {
  static final Map<String, TransportCreator> _creators = {};
  static final Map<String, String> _schemes = {};
  static void register<T extends Transport>(
      String name, TransportCreator<T> creator) {
    var schemes = creator.schemes;
    _creators[name] = creator;
    for (final scheme in schemes) {
      _schemes[scheme] = name;
    }
  }

  static bool isRegister(String name) {
    return _creators.containsKey(name);
  }

  Map<String, Transport> _transports = {};
  Transport operator [](String name) => _transports[name];
  void operator []=(String name, Transport value) => _transports[name] = value;
  MockTransport get mock => _transports['mock'];
  final Map<String, dynamic> requestHeaders = {};
  ClientCodec codec = DefaultClientCodec.instance;
  Duration timeout = new Duration(seconds: 30);
  List<Uri> _urilist = [];
  List<Uri> get uris => _urilist;
  set uris(List<Uri> value) {
    if (value.isNotEmpty) {
      _urilist = List<Uri>.from(value);
      _urilist.shuffle();
    }
  }

  InvokeManager _invokeManager;
  IOManager _ioManager;
  Client([List<String> uris]) {
    init();
    _invokeManager = new InvokeManager(call);
    _ioManager = new IOManager(transport);
    for (final entry in _creators.entries) {
      _transports[entry.key] = entry.value.create();
    }
    if (uris != null) {
      _urilist.addAll(uris.map(Uri.parse));
    }
  }

  void init() {
    if (!isRegister('mock')) {
      register<MockTransport>('mock', new MockTransportCreator());
    }
  }

  dynamic useService([String namespace]) {
    return new _Proxy(this, namespace);
  }

  void use<Handler>(Handler handler) {
    if (handler is InvokeHandler) {
      _invokeManager.use(handler);
    } else if (handler is IOHandler) {
      _ioManager.use(handler);
    } else {
      throw new Exception('Invalid parameter type');
    }
  }

  void unuse<Handler>(Handler handler) {
    if (handler is InvokeHandler) {
      _invokeManager.unuse(handler);
    } else if (handler is IOHandler) {
      _ioManager.unuse(handler);
    } else {
      throw new Exception('Invalid parameter type');
    }
  }

  Future<T> invoke<T>(String fullname,
      [List args, ClientContext context]) async {
    if (context == null) context = new ClientContext();
    context.init(this, T);
    if (args == null) args = [];
    for (var i = 0; i < args.length; i++) {
      if (args[i] is Future) {
        args[i] = await args[i];
      }
    }
    return await _invokeManager.handler(fullname, args, context);
  }

  Future call(String fullname, List args, Context context) async {
    var request = codec.encode(fullname, args, context);
    var response = await this.request(request, context);
    return codec.decode(response, context);
  }

  Future<Uint8List> request(Uint8List request, Context context) {
    return _ioManager.handler(request, context);
  }

  Future<Uint8List> transport(Uint8List request, Context context) {
    var uri = (context as ClientContext).uri;
    var scheme = uri.scheme;
    if (_schemes.containsKey(scheme)) {
      var name = _schemes[scheme];
      return _transports[name].transport(request, context);
    }
    throw new Exception('The protocol $scheme is not supported.');
  }

  Future<void> abort() {
    List<Future> results = [];
    _transports.values.forEach((trans) {
      results.add(trans.abort());
    });
    return Future.wait(results);
  }
}
