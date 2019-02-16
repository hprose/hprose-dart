/*--------------------------------------------------------*\
|                                                          |
|                          hprose                          |
|                                                          |
| Official WebSite: https://hprose.com                     |
|                                                          |
| bigint_serializer.ts                                     |
|                                                          |
| hprose BigInt Serializer for Dart.                       |
|                                                          |
| LastModified: Feb 14, 2019                               |
| Author: Ma Bingyao <andot@hprose.com>                    |
|                                                          |
\*________________________________________________________*/

part of hprose.io;

class BigIntSerializer extends BaseSerializer<BigInt> {
  static final AbstractSerializer<BigInt> instance = new BigIntSerializer();
  @override
  void write(Writer writer, BigInt value) => writeBigInt(writer.stream, value);
}
