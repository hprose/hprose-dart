/*--------------------------------------------------------*\
|                                                          |
|                          hprose                          |
|                                                          |
| Official WebSite: https://hprose.com                     |
|                                                          |
| writer.dart                                              |
|                                                          |
| hprose Writer for Dart.                                  |
|                                                          |
| LastModified: Feb 14, 2019                               |
| Author: Ma Bingyao <andot@hprose.com>                    |
|                                                          |
\*________________________________________________________*/

part of hprose.io;

class _WriterRefer {
  final Map<dynamic, int> _ref = <dynamic, int>{};
  int _last = 0;
  void addCount(int count) {
    _last += count;
  }

  void setReference(value) {
    _ref[value] = _last++;
  }

  bool writeReference(ByteStream stream, value) {
    final index = _ref[value];
    if (index != null) {
      stream.writeByte(TagRef);
      stream.writeAsciiString(index.toString());
      stream.writeByte(TagSemicolon);
      return true;
    }
    return false;
  }

  void reset() {
    _ref.clear();
    _last = 0;
  }
}

class Writer {
  _WriterRefer _refer;
  final Map<dynamic, int> _ref = <dynamic, int>{};
  int _last = 0;
  final ByteStream stream;
  Writer(this.stream, {bool simple = false}) {
    this.simple = simple;
  }
  bool get simple => _refer == null;
  set simple(bool value) => _refer = value ? null : new _WriterRefer();
  void serialize<T>(T value) {
    if (value == null) {
      stream.writeByte(TagNull);
    } else {
      Serializer.getInstance(T, value).serialize(this, value);
    }
  }

  void write<T>(T value) {
    if (value == null) {
      stream.writeByte(TagNull);
    } else {
      Serializer.getInstance(T, value).write(this, value);
    }
  }

  bool writeReference(value) {
    return simple ? false : _refer.writeReference(stream, value);
  }

  void setReference(value) {
    if (!simple) _refer.setReference(value);
  }

  void addReferenceCount(int count) {
    if (!simple) _refer.addCount(count);
  }

  void reset() {
    if (!simple) _refer.reset();
    _ref.clear();
    _last = 0;
  }

  int writeClass(type, void action()) {
    var r = _ref[type];
    if (r == null) {
      action();
      r = _last++;
      _ref[type] = r;
    }
    return r;
  }
}
