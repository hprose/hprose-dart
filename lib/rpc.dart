/*--------------------------------------------------------*\
|                                                          |
|                          hprose                          |
|                                                          |
| Official WebSite: https://hprose.com                     |
|                                                          |
| rpc.dart                                                 |
|                                                          |
| hprose.rpc library for Dart.                             |
|                                                          |
| LastModified: Feb 21, 2019                               |
| Author: Ma Bingyao <andot@hprose.com>                    |
|                                                          |
\*________________________________________________________*/

library hprose.rpc;

import 'dart:core';
import 'dart:async';
import 'dart:math';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'io.dart';
import 'rpc_core.dart' as core show ServiceContext, Service, Client;
import 'rpc_core.dart' hide ServiceContext, Service, Client;
export 'rpc_core.dart' hide ServiceContext, Service, Client;

part 'src/rpc/crc32.dart';
part 'src/rpc/client.dart';
part 'src/rpc/service.dart';
part 'src/rpc/service_context.dart';
part 'src/rpc/http_transport.dart';
part 'src/rpc/http_handler.dart';
part 'src/rpc/tcp_transport.dart';
part 'src/rpc/tcp_handler.dart';
part 'src/rpc/udp_transport.dart';
part 'src/rpc/udp_handler.dart';
