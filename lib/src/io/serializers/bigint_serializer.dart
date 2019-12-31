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
| LastModified: Dec 31, 2019                               |
| Author: Ma Bingyao <andot@hprose.com>                    |
|                                                          |
\*________________________________________________________*/

part of hprose.io;

class BigIntSerializer extends BaseSerializer<BigInt> {
  static final AbstractSerializer<BigInt> instance = BigIntSerializer();
  @override
  void write(Writer writer, BigInt value) =>
      ValueWriter.writeBigInt(writer.stream, value);
}
