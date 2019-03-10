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
| LastModified: Mar 3, 2019                                |
| Author: Ma Bingyao <andot@hprose.com>                    |
|                                                          |
\*________________________________________________________*/

part of hprose.rpc;

class HttpTransport implements Transport {
  HttpClient httpClient;
  Map<String, Object> httpRequestHeaders = {};
  bool keepAlive = true;
  int maxConnectionsPerHost = null;

  HttpTransport() {
    httpClient = createHttpClient();
  }

  HttpClient createHttpClient() {
    HttpClient httpClient = new HttpClient();
    if (maxConnectionsPerHost != null) {
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
      var completer = new Completer<HttpClientResponse>();
      var timer = new Timer(clientContext.timeout, () async {
        if (!completer.isCompleted) {
          completer.completeError(new TimeoutException('Timeout'));
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
    if (httpResponse.statusCode >= 200 && httpResponse.statusCode < 300) {
      context['httpResponseHeaders'] = httpResponse.headers;
      ByteStream stream = new ByteStream(
          httpResponse.contentLength >= 0 ? httpResponse.contentLength : 0);
      await for (var data in httpResponse) stream.write(data);
      return stream.takeBytes();
    }
    throw new Exception(
        '${httpResponse.statusCode}:${httpResponse.reasonPhrase}');
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
    return new HttpTransport();
  }
}
