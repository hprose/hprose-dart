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
| LastModified: Feb 24, 2019                               |
| Author: Ma Bingyao <andot@hprose.com>                    |
|                                                          |
\*________________________________________________________*/

part of hprose.rpc;

abstract class Transport {
  Future<Uint8List> transport(Uint8List request, Context context);
}

abstract class TransportCreator<T extends Transport> {
  List<String> schemes;
  T create();
}

class Client {
  static final List<MapEntry<String, TransportCreator>> _creators = [];
  static final Map<String, String> _schemes = {};
  static void Register<T extends Transport>(
      String name, TransportCreator<T> creator) {
    var schemes = creator.schemes;
    _creators.add(new MapEntry(name, creator));
    for (final scheme in schemes) {
      _schemes[scheme] = name;
    }
  }

  Map<String, Transport> _transports = {};
  Transport operator [](String name) => _transports[name];
  final Map<String, dynamic> requestHeaders = {};
  ClientCodec codec = DefaultClientCodec.instance;
  List<Uri> _urilist = [];
  List<Uri> get uris => _urilist;
  set uris(List<Uri> value) {
    if (value.length > 0) {
      _urilist = List<Uri>.from(value);
      _urilist.shuffle();
    }
  }

  InvokeManager _invokeManager;
  IOManager _ioManager;
  Client([List<String> uris]) {
    _invokeManager = new InvokeManager(call);
    _ioManager = new IOManager(transport);
    for (final pair in _creators) {
      _transports[pair.key] = pair.value.create();
    }
    if (uris != null) {
      _urilist.addAll(uris.map((uri) => Uri.parse(uri)));
    }
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
      {List args = null, ClientContext context = null}) async {
    if (context == null) context = new ClientContext();
    context.init(this, T);
    if (args == null) args = [];
    return await _invokeManager.handler(fullname, args, context);
  }

  Future call(String fullname, List args, Context context) async {
    var request = codec.encode(fullname, args, context);
    var response = await _ioManager.handler(request, context);
    return codec.decode(response, context);
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
}
