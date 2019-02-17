/*--------------------------------------------------------*\
|                                                          |
|                          hprose                          |
|                                                          |
| Official WebSite: https://hprose.com                     |
|                                                          |
| type_manager.dart                                        |
|                                                          |
| hprose TypeManager for Dart.                             |
|                                                          |
| LastModified: Feb 16, 2019                               |
| Author: Ma Bingyao <andot@hprose.com>                    |
|                                                          |
\*________________________________________________________*/

part of hprose.io;

class _TypeManager {
  final Map<String, Map<String, Type>> _types = {};
  final Map<String, Type> _emptyType = {};
  void register(String name, Map<String, Type> fields) {
    _types[name] = fields;
  }

  bool isRegister(String name) {
    return _types.containsKey(name);
  }

  Map<String, Type> getType(String name) {
    return isRegister(name) ? _types[name] : _emptyType;
  }
}

final TypeManager = new _TypeManager();
