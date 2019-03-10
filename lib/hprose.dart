/*--------------------------------------------------------*\
|                                                          |
|                          hprose                          |
|                                                          |
| Official WebSite: https://hprose.com                     |
|                                                          |
| hprose.dart                                              |
|                                                          |
| hprose library for Dart.                                 |
|                                                          |
| LastModified: Mar 10 2019                                |
| Author: Ma Bingyao <andot@hprose.com>                    |
|                                                          |
\*________________________________________________________*/

library hprose;

export 'io.dart';
// ignore: uri_does_not_exist
export 'core.dart'
    // ignore: uri_does_not_exist
    if (dart.library.html) 'browser.dart'
    // ignore: uri_does_not_exist
    if (dart.library.io) 'rpc.dart';
export 'jsonrpc.dart';
export 'plugins.dart';
