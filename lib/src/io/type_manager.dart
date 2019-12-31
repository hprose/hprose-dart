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
| LastModified: Dec 31, 2019                               |
| Author: Ma Bingyao <andot@hprose.com>                    |
|                                                          |
\*________________________________________________________*/

part of hprose.io;

typedef FromJson<T> = T Function(Map<String, dynamic> data);

class _TypeManager {
  final _fromJson = <String, FromJson>{};
  final _types = <String, Map<String, Type>>{};
  final _names = <String, String>{};
  final _emptyType = <String, Type>{};
  void register<T>(FromJson<T> fromJson,
      [Map<String, Type> fields, String name]) {
    if (name == null || name.isEmpty) {
      name = T.toString();
    }
    _names[T.toString()] = name;
    _fromJson[name] = fromJson;
    _types[name] = fields;
    if (fromJson != null) {
      Deserializer.register<T>(ObjectDeserializer(name));
    }
  }

  bool isRegister(String name) {
    return _types.containsKey(name);
  }

  Map<String, Type> getType(String name) {
    return isRegister(name) ? _types[name] : _emptyType;
  }

  String getName(String type) {
    return _names.containsKey(type) ? _names[type] : type;
  }

  FromJson getConstructor(String name) {
    return _fromJson[name];
  }
}

final TypeManager = _TypeManager();
