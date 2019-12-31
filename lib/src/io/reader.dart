/*--------------------------------------------------------*\
|                                                          |
|                          hprose                          |
|                                                          |
| Official WebSite: https://hprose.com                     |
|                                                          |
| reader.dart                                              |
|                                                          |
| hprose Reader for Dart.                                  |
|                                                          |
| LastModified: Dec 31, 2019                               |
| Author: Ma Bingyao <andot@hprose.com>                    |
|                                                          |
\*________________________________________________________*/

part of hprose.io;

class _ReaderRefer {
  final List _ref = [];
  int get lastIndex => _ref.length - 1;
  void addReference(value) => _ref.add(value);
  void setReference(int index, dynamic value) => _ref[index] = value;
  dynamic readReference(int index) => _ref[index];
  void reset() => _ref.length = 0;
}

enum LongType { Int, BigInt, String }

class Reader {
  _ReaderRefer _refer;
  final List<TypeInfo> _ref = [];
  LongType longType = LongType.Int;
  final ByteStream stream;
  Reader(this.stream, {bool simple = false}) {
    this.simple = simple;
  }
  bool get simple => _refer == null;
  set simple(bool value) => _refer = (value ? null : _ReaderRefer());

  T deserialize<T>() {
    return Deserializer.getInstance<T>().deserialize(this);
  }

  T read<T>(int tag) {
    return Deserializer.getInstance<T>().read(this, tag);
  }

  void readClass() {
    final name = ValueReader.readString(stream);
    final count = ValueReader.readCount(stream);
    final names = List<String>(count);
    final types = List<Type>(count);
    final type = TypeManager.getType(name);
    final strDeserialize = Deserializer.getInstance<String>();
    for (var i = 0; i < count; ++i) {
      names[i] = strDeserialize.deserialize(this);
      if (type != null) {
        types[i] = type[names[i]];
      }
    }
    stream.readByte();
    _ref.add(TypeInfo(name, names, types));
  }

  TypeInfo getTypeInfo(int index) => _ref[index];
  dynamic readReference() => _refer?.readReference(ValueReader.readInt(stream));
  void addReference(value) => _refer?.addReference(value);
  void setReference(int index, dynamic value) =>
      _refer?.setReference(index, value);
  int get lastReferenceIndex => simple ? -1 : _refer.lastIndex;
  void reset() {
    _refer?.reset();
    _ref.length = 0;
  }
}
