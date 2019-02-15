/*--------------------------------------------------------*\
|                                                          |
|                          hprose                          |
|                                                          |
| Official WebSite: https://hprose.com                     |
|                                                          |
| io.dart                                                  |
|                                                          |
| hprose.io library for Dart.                              |
|                                                          |
| LastModified: Feb 13, 2019                               |
| Author: Ma Bingyao <andot@hprose.com>                    |
|                                                          |
\*________________________________________________________*/

library hprose.io;

import 'dart:core';
import 'dart:math';
import 'dart:convert';
import 'dart:typed_data';

part 'src/io/dynamic_object.dart';
part 'src/io/byte_stream.dart';
part 'src/io/tags.dart';
part 'src/io/type_info.dart';
part 'src/io/value_writer.dart';
part 'src/io/value_reader.dart';
part 'src/io/writer.dart';
part 'src/io/serializer.dart';

part 'src/io/serializers/base_serializer.dart';
part 'src/io/serializers/dynamic_serializer.dart';
part 'src/io/serializers/num_serializer.dart';
part 'src/io/serializers/int_serializer.dart';
part 'src/io/serializers/double_serializer.dart';
part 'src/io/serializers/bigint_serializer.dart';
part 'src/io/serializers/bool_serializer.dart';
part 'src/io/serializers/reference_serializer.dart';
part 'src/io/serializers/string_serializer.dart';
part 'src/io/serializers/datetime_serializer.dart';
part 'src/io/serializers/typed_data_serializer.dart';
part 'src/io/serializers/map_serializer.dart';
part 'src/io/serializers/iterable_serializer.dart';
part 'src/io/serializers/bytes_serializer.dart';
part 'src/io/serializers/dynamic_object_serializer.dart';
part 'src/io/serializers/error_serializer.dart';
