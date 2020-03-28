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
| LastModified: Mar 28, 2020                               |
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
    var name = symbol.toString();
    return name.substring(8, name.length - 2);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    var name = _namespace + _getName(invocation.memberName);
    if (invocation.isGetter) {
      return _Proxy(_client, name);
    }
    if (invocation.isMethod) {
      var type = dynamic;
      if (invocation.typeArguments.isNotEmpty) {
        type = invocation.typeArguments.first;
      }
      ClientContext context;
      var args = [];
      if (invocation.positionalArguments.isNotEmpty) {
        args.addAll(invocation.positionalArguments);
        if (args.last is Context) {
          context = args.removeLast();
        }
      }
      if (invocation.namedArguments.isNotEmpty) {
        var namedArgs = <String, dynamic>{};
        invocation.namedArguments.forEach((name, value) {
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
      context ??= ClientContext();
      context.returnType = type;
      return _client.invoke(name, args, context);
    }
    super.noSuchMethod(invocation);
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

  final _transports = <String, Transport>{};
  Transport operator [](String name) => _transports[name];
  void operator []=(String name, Transport value) => _transports[name] = value;
  MockTransport get mock => _transports['mock'];
  final Map<String, dynamic> requestHeaders = {};
  ClientCodec codec = DefaultClientCodec.instance;
  Duration timeout = Duration(seconds: 30);
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
    _invokeManager = InvokeManager(call);
    _ioManager = IOManager(transport);
    for (final entry in _creators.entries) {
      _transports[entry.key] = entry.value.create();
    }
    if (uris != null) {
      _urilist.addAll(uris.map(Uri.parse));
    }
  }

  void init() {
    if (!isRegister('mock')) {
      register<MockTransport>('mock', MockTransportCreator());
    }
  }

  dynamic useService([String namespace]) {
    return _Proxy(this, namespace);
  }

  void use<Handler>(Handler handler) {
    if (handler is InvokeHandler) {
      _invokeManager.use(handler);
    } else if (handler is IOHandler) {
      _ioManager.use(handler);
    } else {
      throw Exception('Invalid parameter type');
    }
  }

  void unuse<Handler>(Handler handler) {
    if (handler is InvokeHandler) {
      _invokeManager.unuse(handler);
    } else if (handler is IOHandler) {
      _ioManager.unuse(handler);
    } else {
      throw Exception('Invalid parameter type');
    }
  }

  Future<T> invoke<T>(String name, [List args, ClientContext context]) async {
    context ??= ClientContext();
    context.init(this, T);
    args ??= [];
    for (var i = 0; i < args.length; i++) {
      if (args[i] is Future) {
        args[i] = await args[i];
      }
    }
    return await _invokeManager.handler(name, args, context);
  }

  Future call(String name, List args, Context context) async {
    var request = codec.encode(name, args, context);
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
    throw Exception('The protocol $scheme is not supported.');
  }

  Future<void> abort() {
    final results = <Future>[];
    _transports.values.forEach((trans) {
      results.add(trans.abort());
    });
    return Future.wait(results);
  }
}
