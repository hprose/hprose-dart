/*--------------------------------------------------------*\
|                                                          |
|                          hprose                          |
|                                                          |
| Official WebSite: https://hprose.com                     |
|                                                          |
| method_manager.dart                                      |
|                                                          |
| MethodManager for Dart.                                  |
|                                                          |
| LastModified: Mar 28, 2020                               |
| Author: Ma Bingyao <andot@hprose.com>                    |
|                                                          |
\*________________________________________________________*/

part of hprose.rpc.core;

typedef MissingMethod1 = dynamic Function(String name, List args);
typedef MissingMethod2 = dynamic Function(
    String name, List args, Context context);

class MethodManager {
  final List<String> _names = [];
  final Map<String, Method> _methods = {};
  Iterable<String> getNames() => _names;
  Method get(String name) {
    name = name.toLowerCase();
    return _methods.containsKey(name) ? _methods[name] : _methods['*'];
  }

  void remove(String name) {
    _methods.remove(name.toLowerCase());
    _names.remove(name);
  }

  void add(Method method) {
    final name = method.name;
    _methods[name.toLowerCase()] = method;
    if (!_names.contains(name)) {
      _names.add(name);
    }
  }

  void addMethod(Function method, [String name]) {
    add(Method(method, name: name));
  }

  void addMethods(List<Function> _methods, [List<String> names]) {
    if (names != null) {
      for (var i = 0; i < _methods.length; ++i) {
        add(Method(_methods[i], name: names[i]));
      }
    } else {
      for (var i = 0; i < _methods.length; ++i) {
        add(Method(_methods[i]));
      }
    }
  }

  void addMissingMethod<MissingMethod extends Function>(MissingMethod method) {
    if (method is MissingMethod1 || method is MissingMethod2) {
      add(Method(method, name: '*', missing: true));
    } else {
      throw ArgumentError('method is not a missing method');
    }
  }
}
