/*--------------------------------------------------------*\
|                                                          |
|                          hprose                          |
|                                                          |
| Official WebSite: https://hprose.com                     |
|                                                          |
| jsonrpc.dart                                             |
|                                                          |
| hprose.rpc.codec.jsonrpc library for Dart.               |
|                                                          |
| LastModified: Mar 9, 2019                                |
| Author: Ma Bingyao <andot@hprose.com>                    |
|                                                          |
\*________________________________________________________*/

library hprose.rpc.codec.jsonrpc;

import 'dart:core';
import 'dart:math';
import 'dart:convert';
import 'dart:typed_data';
import 'io.dart';
import 'core.dart';

part 'src/rpc/codec/jsonrpc_client_codec.dart';
part 'src/rpc/codec/jsonrpc_service_codec.dart';
