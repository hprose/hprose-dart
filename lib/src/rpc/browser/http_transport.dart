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
| LastModified: Mar 29, 2020                               |
| Author: Ma Bingyao <andot@hprose.com>                    |
|                                                          |
\*________________________________________________________*/

part of hprose.rpc.browser;

typedef OnProgress = void Function(ProgressEvent e);

class HttpTransport implements Transport {
  var _counter = 0;
  final _requests = <int, HttpRequest>{};
  var httpRequestHeaders = <String, Object>{};
  OnProgress onProgress;
  void _setRequestHeader(
      HttpRequest httpRequest, Map<String, Object> httpRequestHeaders) {
    httpRequestHeaders?.forEach((String name, Object values) {
      if (values is List) {
        httpRequest.setRequestHeader(name, values.join(', '));
      } else {
        httpRequest.setRequestHeader(name, values.toString());
      }
    });
  }

  Map<String, Object> _getResponseHeader(Map<String, String> responseHeaders) {
    var httpResponseHeaders = <String, Object>{};
    responseHeaders?.forEach((String name, String values) {
      if (values.contains(',')) {
        httpResponseHeaders[name] = values
            .split(',')
            .map((String v) => v.trim())
            .toList(growable: true);
      } else {
        httpResponseHeaders[name] = values;
      }
    });
    return httpResponseHeaders;
  }

  @override
  Future<Uint8List> transport(Uint8List request, Context context) async {
    final clientContext = context as ClientContext;
    final index = (_counter < 0x7FFFFFFF) ? ++_counter : _counter = 0;
    final httpRequest = HttpRequest();
    _requests[index] = httpRequest;
    httpRequest.open('POST', clientContext.uri.toString());
    httpRequest.withCredentials = true;
    httpRequest.responseType = 'arraybuffer';
    _setRequestHeader(httpRequest, httpRequestHeaders);
    _setRequestHeader(httpRequest, context['httpRequestHeaders']);
    if (onProgress != null) {
      httpRequest.onProgress.listen(onProgress);
      httpRequest.upload.onProgress.listen(onProgress);
    }
    var result = Completer<Uint8List>();
    httpRequest.onLoad.listen((e) {
      context['httpStatusCode'] = httpRequest.status;
      context['httpStatusText'] = httpRequest.statusText;
      if (httpRequest.status >= 200 && httpRequest.status < 300) {
        context['httpResponseHeaders'] =
            _getResponseHeader(httpRequest.responseHeaders);
        result.complete(Uint8List.view(httpRequest.response));
      } else {
        result.completeError(
            Exception('${httpRequest.status}:${httpRequest.statusText}'));
      }
    });
    httpRequest.onError.listen((ev) {
      _requests.remove(index);
      result.completeError(Exception('network error'));
    });
    httpRequest.upload.onError.listen((ev) {
      _requests.remove(index);
      result.completeError(Exception('network error'));
    });
    httpRequest.onAbort.listen((ev) {
      _requests.remove(index);
      result.completeError(Exception('transport abort'));
    });
    httpRequest.upload.onAbort.listen((ev) {
      _requests.remove(index);
      result.completeError(Exception('transport abort'));
    });
    httpRequest.onTimeout.listen((ev) {
      _requests.remove(index);
      result.completeError(TimeoutException('Timeout'));
    });
    httpRequest.upload.onTimeout.listen((ev) {
      _requests.remove(index);
      result.completeError(TimeoutException('Timeout'));
    });
    httpRequest.send(request);
    return result.future;
  }

  @override
  Future<void> abort() async {
    final requests = _requests.values.toList();
    _requests.clear();
    requests.forEach((request) => request.abort());
  }
}

class HttpTransportCreator implements TransportCreator<HttpTransport> {
  @override
  List<String> schemes = ['http', 'https'];

  @override
  HttpTransport create() {
    return HttpTransport();
  }
}
