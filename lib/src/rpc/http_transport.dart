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
| LastModified: Dec 31, 2019                               |
| Author: Ma Bingyao <andot@hprose.com>                    |
|                                                          |
\*________________________________________________________*/

part of hprose.rpc;

class HttpTransport implements Transport {
  HttpClient httpClient;
  Map<String, Object> httpRequestHeaders = {};
  bool keepAlive = true;
  int maxConnectionsPerHost = 0;

  HttpTransport() {
    httpClient = createHttpClient();
  }

  HttpClient createHttpClient() {
    var httpClient = HttpClient();
    if (maxConnectionsPerHost > 0) {
      httpClient.maxConnectionsPerHost = maxConnectionsPerHost;
    }
    return httpClient;
  }

  @override
  Future<Uint8List> transport(Uint8List request, Context context) async {
    final clientContext = context as ClientContext;
    if (clientContext.timeout > Duration.zero) {
      httpClient.connectionTimeout = clientContext.timeout;
    }
    final httpRequest = await httpClient.postUrl(clientContext.uri);
    httpRequestHeaders.forEach(httpRequest.headers.add);
    if (context.containsKey('httpRequestHeaders')) {
      (context['httpRequestHeaders'] as Map<String, Object>)
          ?.forEach(httpRequest.headers.add);
    }
    httpRequest.persistentConnection = keepAlive;
    httpRequest.contentLength = request.length;
    httpRequest.add(request);
    HttpClientResponse httpResponse;
    if (clientContext.timeout > Duration.zero) {
      var completer = Completer<HttpClientResponse>();
      var timer = Timer(clientContext.timeout, () async {
        if (!completer.isCompleted) {
          completer.completeError(TimeoutException('Timeout'));
          await abort();
        }
      });
      try {
        httpResponse =
            await Future.any([httpRequest.close(), completer.future]);
      } finally {
        timer.cancel();
      }
    } else {
      httpResponse = await httpRequest.close();
    }
    context['httpStatusCode'] = httpResponse.statusCode;
    context['httpStatusText'] = httpResponse.reasonPhrase;
    if (httpResponse.statusCode >= 200 && httpResponse.statusCode < 300) {
      context['httpResponseHeaders'] = httpResponse.headers;
      var stream = ByteStream(
          httpResponse.contentLength >= 0 ? httpResponse.contentLength : 0);
      await for (var data in httpResponse) {
        stream.write(data);
      }
      return stream.takeBytes();
    }
    throw Exception('${httpResponse.statusCode}:${httpResponse.reasonPhrase}');
  }

  @override
  Future<void> abort() async {
    httpClient.close(force: true);
    httpClient = createHttpClient();
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
