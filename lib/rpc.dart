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
import 'rpc_core.dart' as core show ServiceContext;
import 'rpc_core.dart' hide ServiceContext;
export 'rpc_core.dart' hide ServiceContext;

part 'src/rpc/service_context.dart';
