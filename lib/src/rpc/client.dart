/**********************************************************\
|                                                          |
|                          hprose                          |
|                                                          |
| Official WebSite: http://www.hprose.com/                 |
|                   http://www.hprose.org/                 |
|                                                          |
\**********************************************************/
/**********************************************************\
 *                                                        *
 * client.dart                                            *
 *                                                        *
 * hprose context class for Dart.                         *
 *                                                        *
 * LastModified: Mar 3, 2015                              *
 * Author: Ma Bingyao <andot@hprose.com>                  *
 *                                                        *
\**********************************************************/
part of hprose.rpc;

@proxy
class Proxy {
  Client _client;
  String _namespace;
  Proxy(this._client, this._namespace) {
    if (_namespace != '') {
      _namespace += '_';
    }
  }
  noSuchMethod(Invocation mirror) {
    String name = this._namespace + mirror.memberName.toString();
    if (mirror.isGetter) {
      return new Proxy(this._client, name);
    }
    if (mirror.isMethod) {
      return _client.invoke(name, mirror.positionalArguments);
    }
    super.noSuchMethod(mirror);
  }
}

abstract class Client {
  String _uri;

  String get uri => _uri;
  set uri(String value) => _uri = value;

  Future<Uint8List> sendAndReceive(Uint8List data);

  List<Filter> _filters = new List<Filter>();
  List<Filter> get filters => _filters;
  Uint8List _doOutput(String name, List<dynamic> args, bool byref, bool simple, Context context) {
    BytesIO bytes = new BytesIO();
    Writer writer = new Writer(bytes, simple);
    bytes.writeByte(TagCall);
    writer.writeString(name);
    if (args.length > 0 || byref) {
      writer.reset();
      writer.writeList(args);
      if (byref) {
        writer.writeBool(true);
      }
    }
    bytes.writeByte(TagEnd);
    Uint8List request = bytes.bytes;
    bytes.clear();
    filters.forEach((filter) => request = filter.outputFilter(request, context));
    return request;
  }
  dynamic _doInput(Uint8List response, List<dynamic> args, int mode, Context context) {
    filters.reversed.forEach((filter) => response = filter.inputFilter(response, context));
    if (mode == RawWithEndTag) {
      return response;
    }
    if (mode == Raw) {
      return response.sublist(0, response.length - 1);
    }
    BytesIO bytes = new BytesIO(response);
    Reader reader = new Reader(bytes);
    dynamic result;
    int tag;
    while((tag = bytes.readByte()) != TagEnd) {
      switch(tag) {
        case TagResult:
          if (mode == Serialized) {
            result = reader.readRaw();
          }
          else {
            reader.reset();
            result = reader.unserialize();
          }
          break;
        case TagArgument:
          reader.reset();
          List<dynamic> a = reader.readList();
          int n = min(a.length, args.length);
          for (int i = 0; i < n; ++i) args[i] = a[i];
          break;
        case TagError:
          reader.reset();
          throw new Exception(reader.readString());
        default:
          throw new Exception("Wrong Response: \r\n" + bytes.toString());
      }
    }
    bytes.clear();
    return result;
  }
  Client([this._uri = '']);
  Proxy useService([String uri = '', String namespace = '']) {
    if (uri != '') {
      this._uri = uri;
    }
    return new Proxy(this, namespace);
  }
  Future<dynamic> invoke(String name, List<dynamic> args, [bool byref = false, int mode = Normal, bool simple = false]) {
    Completer<dynamic> completor = new Completer<dynamic>();
    Context context = new Context();
    Uint8List request = _doOutput(name, args, byref, simple, context);
    sendAndReceive(request).then((response) {
      try {
        completor.complete(_doInput(response, args, mode, context));
      }
      catch(e) {
        completor.completeError(e);
      }
    })..catchError((e) {
      completor.completeError(e);
    });
    return completor.future;
  }
  @override
  noSuchMethod(Invocation mirror) {
      String name = MirrorSystem.getName(mirror.memberName);
      if (mirror.isGetter) {
        return new Proxy(this, name);
      }
      if (mirror.isMethod) {
        return invoke(name, mirror.positionalArguments);
      }
      super.noSuchMethod(mirror);
    }
}