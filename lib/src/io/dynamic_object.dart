/*--------------------------------------------------------*\
|                                                          |
|                          hprose                          |
|                                                          |
| Official WebSite: https://hprose.com                     |
|                                                          |
| dynamic_object.dart                                      |
|                                                          |
| hprose DynamicObject for Dart.                           |
|                                                          |
| LastModified: Feb 14, 2019                               |
| Author: Ma Bingyao <andot@hprose.com>                    |
|                                                          |
\*________________________________________________________*/

part of hprose.io;

class DynamicObject implements Map<String, dynamic> {
  final Map<String, dynamic> _items = <String, dynamic>{};
  final String _name;
  DynamicObject([this._name = '']);
  String getName() => _name;
  dynamic noSuchMethod(Invocation invocation) {
    var name = invocation.memberName.toString();
    name = name.substring(8, name.length - 2);
    if (invocation.isGetter) {
      return _items[name];
    } else if (invocation.isSetter) {
      name = name.substring(0, name.length - 1);
      _items[name] = invocation.positionalArguments[0];
    }
  }

  @override
  operator [](Object key) {
    return _items[key];
  }

  @override
  void operator []=(String key, value) {
    _items[key] = value;
  }

  @override
  void addAll(Map<String, dynamic> other) {
    _items.addAll(other);
  }

  @override
  void addEntries(Iterable<MapEntry<String, dynamic>> newEntries) {
    _items.addEntries(newEntries);
  }

  @override
  Map<RK, RV> cast<RK, RV>() {
    return _items.cast<RK, RV>();
  }

  @override
  void clear() {
    _items.clear();
  }

  @override
  bool containsKey(Object key) {
    return _items.containsKey(key);
  }

  @override
  bool containsValue(Object value) {
    return _items.containsValue(value);
  }

  @override
  Iterable<MapEntry<String, dynamic>> get entries => _items.entries;

  @override
  void forEach(void Function(String key, dynamic value) f) {
    _items.forEach(f);
  }

  @override
  bool get isEmpty => _items.isEmpty;

  @override
  bool get isNotEmpty => _items.isNotEmpty;

  @override
  Iterable<String> get keys => _items.keys;

  @override
  int get length => _items.length;

  @override
  Map<K2, V2> map<K2, V2>(
      MapEntry<K2, V2> Function(String key, dynamic value) f) {
    return _items.map<K2, V2>(f);
  }

  @override
  putIfAbsent(String key, Function() ifAbsent) {
    return _items.putIfAbsent(key, ifAbsent);
  }

  @override
  remove(Object key) {
    return _items.remove(key);
  }

  @override
  void removeWhere(bool Function(String key, dynamic value) predicate) {
    _items.removeWhere(predicate);
  }

  @override
  update(String key, Function(dynamic value) update, {Function() ifAbsent}) {
    _items.update(key, update, ifAbsent: ifAbsent);
  }

  @override
  void updateAll(Function(String key, dynamic value) update) {
    _items.updateAll(update);
  }

  @override
  Iterable get values => _items.values;
}