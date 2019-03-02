/*--------------------------------------------------------*\
|                                                          |
|                          hprose                          |
|                                                          |
| Official WebSite: https://hprose.com                     |
|                                                          |
| http_transport.dart                                      |
|                                                          |
| HttpTransport for Dart.                                  |
|                                                          |
| LastModified: Mar 2, 2019                                |
| Author: Ma Bingyao <andot@hprose.com>                    |
|                                                          |
\*________________________________________________________*/

part of hprose.rpc;

class HttpHandler implements Handler<HttpServer> {
  static DateTime _lastModified = DateTime.now().toUtc();
  static Random _random = Random.secure();
  static String _etag =
      '"${_random.nextInt(2147483647).toRadixString(16)}:${_random.nextInt(2147483647).toRadixString(16)}"';

  bool p3p = true;
  bool get = true;
  bool crossDomain = true;
  Map<String, bool> _origins = {};
  String _crossDomainXmlFile = '';
  String _crossDomainXmlContent = '';
  String _clientAccessPolicyXmlFile = '';
  String _clientAccessPolicyXmlContent = '';
  String get crossDomainXmlFile => _crossDomainXmlFile;
  set crossDomainXmlFile(String value) {
    _crossDomainXmlFile = value;
    _crossDomainXmlContent = new File(value).readAsStringSync();
  }

  String get clientAccessPolicyXmlFile => _clientAccessPolicyXmlFile;
  set clientAccessPolicyXmlFile(String value) {
    _clientAccessPolicyXmlFile = value;
    _clientAccessPolicyXmlContent = new File(value).readAsStringSync();
  }

  String get crossDomainXmlContent => _crossDomainXmlContent;
  set crossDomainXmlContent(String value) {
    _crossDomainXmlFile = '';
    _crossDomainXmlContent = value;
  }

  String get clientAccessPolicyXmlContent => _clientAccessPolicyXmlContent;
  set clientAccessPolicyXmlContent(String value) {
    _clientAccessPolicyXmlFile = '';
    _clientAccessPolicyXmlContent = value;
  }

  void Function(dynamic error, StackTrace stackTrace) onError;
  void Function() onDone;
  core.Service service;
  HttpHandler(this.service);

  @override
  void bind(HttpServer server) {
    server.listen(handler, onError: onError, onDone: onDone);
  }

  bool _crossDomainXmlHandler(HttpRequest request) {
    if (request.uri.path.toLowerCase() == '/crossdomain.xml') {
      final response = request.response;
      if (request.headers.ifModifiedSince == _lastModified &&
          request.headers[HttpHeaders.ifNoneMatchHeader] == _etag) {
        response.statusCode = 304;
      } else {
        response.headers.add(HttpHeaders.lastModifiedHeader, _lastModified);
        response.headers.add(HttpHeaders.etagHeader, _etag);
        response.headers.add(HttpHeaders.contentTypeHeader, 'text/xml');
        response.write(this._crossDomainXmlContent);
      }
      response.flush();
      response.close();
      return true;
    }
    return false;
  }

  bool _clientAccessPolicyXmlHandler(HttpRequest request) {
    if (request.uri.path.toLowerCase() == '/clientaccesspolicy.xml') {
      final response = request.response;
      if (request.headers.ifModifiedSince == _lastModified &&
          request.headers[HttpHeaders.ifNoneMatchHeader] == _etag) {
        response.statusCode = 304;
      } else {
        response.headers.add(HttpHeaders.lastModifiedHeader, _lastModified);
        response.headers.add(HttpHeaders.etagHeader, _etag);
        response.headers.add(HttpHeaders.contentTypeHeader, 'text/xml');
        response.write(this._clientAccessPolicyXmlContent);
      }
      return true;
    }
    return false;
  }

  void sendHeader(HttpRequest request) {
    final response = request.response;
    response.statusCode = 200;
    response.headers.add(HttpHeaders.contentTypeHeader, 'text/plain');
    if (this.p3p) {
      response.headers.add(
          'P3P',
          'CP="CAO DSP COR CUR ADM DEV TAI PSA PSD IVAi IVDi ' +
              'CONi TELo OTPi OUR DELi SAMi OTRi UNRi PUBi IND PHY ONL ' +
              'UNI PUR FIN COM NAV INT DEM CNT STA POL HEA PRE GOV"');
    }
    if (this.crossDomain) {
      final origin = request.headers['origin']?.first;
      if (origin != null && origin != 'null') {
        if (_origins.isEmpty || _origins[origin]) {
          response.headers.add('Access-Control-Allow-Origin', origin);
          response.headers.add('Access-Control-Allow-Credentials', 'true');
        }
      } else {
        response.headers.add('Access-Control-Allow-Origin', '*');
      }
    }
  }

  void addAccessControlAllowOrigin(String origin) {
    if (!_origins[origin]) {
      _origins[origin] = true;
    }
  }

  void removeAccessControlAllowOrigin(String origin) {
    if (_origins[origin]) {
      _origins.remove(origin);
    }
  }

  void handler(HttpRequest request) async {
    final response = request.response;
    final context = service.createContext() as ServiceContext;
    context['request'] = request;
    context['response'] = response;
    context.address = request.connectionInfo.remoteAddress;
    context.host = request.connectionInfo.remoteAddress.host;
    context.port = request.connectionInfo.remotePort;
    context.handler = this;
    if (request.contentLength > service.maxRequestLength) {
      response.statusCode = HttpStatus.requestEntityTooLarge;
      response.reasonPhrase = 'Request Entity Too Large';
      await response.flush();
      await response.close();
      return;
    }
    ByteStream stream = new ByteStream(request.contentLength >= 0
        ? request.contentLength
        : await request.length);
    await for (var data in request) stream.write(data);
    final data = stream.takeBytes();
    Uint8List result;
    switch (request.method) {
      case 'GET':
        if (_clientAccessPolicyXmlContent.isNotEmpty &&
            _clientAccessPolicyXmlHandler(request)) {
          await response.flush();
          await response.close();
          return;
        }
        if (_crossDomainXmlContent.isNotEmpty &&
            _crossDomainXmlHandler(request)) {
          await response.flush();
          await response.close();
          return;
        }
        if (!get) {
          response.statusCode = HttpStatus.forbidden;
          response.reasonPhrase = 'Forbidden';
          await response.flush();
          await response.close();
          return;
        }
        result = await service.handle(data, context);
        break;
      case 'POST':
        result = await service.handle(data, context);
        break;
    }
    sendHeader(request);
    response.add(result);
    await response.flush();
    await response.close();
  }
}

class HttpHandlerCreator implements HandlerCreator<HttpHandler> {
  @override
  List<String> serverTypes = ['_HttpServer'];

  @override
  HttpHandler create(core.Service service) {
    return new HttpHandler(service);
  }
}
