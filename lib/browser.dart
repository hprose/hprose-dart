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
 * browser.dart                                           *
 *                                                        *
 * hprose for Dart on browser.                            *
 *                                                        *
 * LastModified: Mar 3, 2015                              *
 * Author: Ma Bingyao <andot@hprose.com>                  *
 *                                                        *
\**********************************************************/
library hprose.browser;

import "dart:async";
import "dart:core";
import 'dart:html';
import "dart:typed_data";
import 'rpc.dart';

export 'io.dart';
export 'rpc.dart';

typedef void OnProgress(ProgressEvent e);

class HttpClient extends Client {
  Map<String, String> _headers = new Map<String, String>();
  OnProgress _onProgress = null;

  Map<String, String> get headers => _headers;
  OnProgress get onProgress => _onProgress;
  set onProgress(OnProgress value) => _onProgress = value;

  HttpClient([String uri = '']) : super(uri);

  @override
  Future<Uint8List> sendAndReceive(Uint8List data) {
    Completer<Uint8List> completor = new Completer<Uint8List>();
    HttpRequest.request(uri,
      method: 'POST',
      withCredentials: window.location.protocol != 'file:',
      responseType: 'arraybuffer',
      requestHeaders:  _headers,
      sendData: data,
      onProgress: _onProgress).then((HttpRequest request) {
      if (request.status == 200) {
        completor.complete(new Uint8List.view(request.response));
      }
      else if (request.status != 0) {
        String error = request.status.toString() + ':' + request.statusText;
        completor.completeError(new Exception(error));
      }
    })..catchError((e) {
      completor.completeError(e);
    });
    return completor.future;
  }
}