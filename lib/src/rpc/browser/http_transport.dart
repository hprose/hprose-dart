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
| LastModified: May 4, 2019                                |
| Author: Ma Bingyao <andot@hprose.com>                    |
|                                                          |
\*________________________________________________________*/

part of hprose.rpc.browser;

typedef void OnProgress(ProgressEvent e);

class HttpTransport implements Transport {
  int _counter = 0;
  Map<int, HttpRequest> _requests = {};
  Map<String, String> httpRequestHeaders = {};
  OnProgress onProgress;
  Map<String, String> _getRequestHeaders(
      Map<String, dynamic> httpRequestHeaders) {
    final headers = <String, String>{};
    for (final name in this.httpRequestHeaders.keys) {
      headers[name] = this.httpRequestHeaders[name];
    }
    if (httpRequestHeaders != null && httpRequestHeaders.isNotEmpty) {
      for (final name in httpRequestHeaders.keys) {
        final value = httpRequestHeaders[name];
        if (value is List) {
          headers[name] = value.join(', ');
        } else {
          headers[name] = value.toString();
        }
      }
    }
    return headers;
  }

  @override
  Future<Uint8List> transport(Uint8List request, Context context) async {
    final clientContext = context as ClientContext;
    final index = (_counter < 0x7FFFFFFF) ? ++_counter : _counter = 0;
    final httpRequest = new HttpRequest();
    _requests[index] = httpRequest;
    var httpRequestHeaders = _getRequestHeaders(context['httpRequestHeaders']);
    httpRequest.open('POST', clientContext.uri.toString());
    httpRequest.withCredentials = true;
    httpRequest.responseType = 'arraybuffer';
    httpRequestHeaders.forEach((header, value) {
      httpRequest.setRequestHeader(header, value);
    });
    if (onProgress != null) {
      httpRequest.onProgress.listen(onProgress);
      httpRequest.upload.onProgress.listen(onProgress);
    }
    var result = new Completer<Uint8List>();
    httpRequest.onLoad.listen((e) {
      context['httpStatusCode'] = httpRequest.status;
      context['httpStatusText'] = httpRequest.statusText;
      if (httpRequest.status >= 200 && httpRequest.status < 300) {
        context['httpResponseHeaders'] = httpRequest.responseHeaders;
        result.complete(Uint8List.view(httpRequest.response));
      } else {
        result.completeError(
            new Exception('${httpRequest.status}:${httpRequest.statusText}'));
      }
    });
    httpRequest.onError.listen((ev) {
      _requests.remove(index);
      result.completeError(new Exception('network error'));
    });
    httpRequest.upload.onError.listen((ev) {
      _requests.remove(index);
      result.completeError(new Exception('network error'));
    });
    httpRequest.onAbort.listen((ev) {
      _requests.remove(index);
      result.completeError(new Exception('transport abort'));
    });
    httpRequest.upload.onAbort.listen((ev) {
      _requests.remove(index);
      result.completeError(new Exception('transport abort'));
    });
    httpRequest.onTimeout.listen((ev) {
      _requests.remove(index);
      result.completeError(new TimeoutException('Timeout'));
    });
    httpRequest.upload.onTimeout.listen((ev) {
      _requests.remove(index);
      result.completeError(new TimeoutException('Timeout'));
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
    return new HttpTransport();
  }
}
