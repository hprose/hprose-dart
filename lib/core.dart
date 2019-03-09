/*--------------------------------------------------------*\
|                                                          |
|                          hprose                          |
|                                                          |
| Official WebSite: https://hprose.com                     |
|                                                          |
| core.dart                                                |
|                                                          |
| hprose.rpc.core library for Dart.                        |
|                                                          |
| LastModified: Mar 9 2019                                 |
| Author: Ma Bingyao <andot@hprose.com>                    |
|                                                          |
\*________________________________________________________*/

library hprose.rpc.core;

import 'dart:core';
import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'io.dart';

part 'src/rpc/core/context.dart';
part 'src/rpc/core/handler_manager.dart';
part 'src/rpc/core/io_manager.dart';
part 'src/rpc/core/invoke_manager.dart';
part 'src/rpc/core/client_context.dart';
part 'src/rpc/core/client_codec.dart';
part 'src/rpc/core/client.dart';
part 'src/rpc/core/method.dart';
part 'src/rpc/core/method_manager.dart';
part 'src/rpc/core/service_context.dart';
part 'src/rpc/core/service_codec.dart';
part 'src/rpc/core/service.dart';
part 'src/rpc/core/mock_agent.dart';
part 'src/rpc/core/mock_handler.dart';
part 'src/rpc/core/mock_transport.dart';
