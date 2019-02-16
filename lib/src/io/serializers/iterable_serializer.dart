/*--------------------------------------------------------*\
|                                                          |
|                          hprose                          |
|                                                          |
| Official WebSite: https://hprose.com                     |
|                                                          |
| iterable_serializer.ts                                   |
|                                                          |
| hprose Iterable Serializer for Dart.                     |
|                                                          |
| LastModified: Feb 14, 2019                               |
| Author: Ma Bingyao <andot@hprose.com>                    |
|                                                          |
\*________________________________________________________*/

part of hprose.io;

class IterableSerializer<E> extends ReferenceSerializer<Iterable<E>> {
  static final AbstractSerializer instance = new IterableSerializer();
  @override
  void write(Writer writer, Iterable<E> value) {
    super.write(writer, value);
    final stream = writer.stream;
    stream.writeByte(TagList);
    final n = value.length;
    if (n > 0) stream.writeAsciiString(n.toString());
    stream.writeByte(TagOpenbrace);
    AbstractSerializer serializer = Serializer.getInstance(E, value.first);
    for (final element in value) {
      serializer.serialize(writer, element);
    }
    stream.writeByte(TagClosebrace);
  }
}
