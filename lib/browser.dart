/*--------------------------------------------------------*\
|                                                          |
|                          hprose                          |
|                                                          |
| Official WebSite: https://hprose.com                     |
|                                                          |
| browser.dart                                             |
|                                                          |
| hprose.rpc.browser library for Dart.                     |
|                                                          |
| LastModified: Mar 10, 2019                               |
| Author: Ma Bingyao <andot@hprose.com>                    |
|                                                          |
\*________________________________________________________*/

library hprose.rpc.browser;

import 'dart:core';
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:html';
import 'io.dart';
import 'core.dart' as core show Client;
import 'core.dart' hide Client;
export 'core.dart' hide Client;

part 'src/rpc/browser/client.dart';
part 'src/rpc/browser/http_transport.dart';
part 'src/rpc/browser/websocket_transport.dart';
