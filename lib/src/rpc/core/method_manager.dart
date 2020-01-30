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
| LastModified: Jan 30, 2020                               |
| Author: Ma Bingyao <andot@hprose.com>                    |
|                                                          |
\*________________________________________________________*/

part of hprose.rpc.core;

typedef MissingMethod1 = dynamic Function(String fullname, List args);
typedef MissingMethod2 = dynamic Function(
    String fullname, List args, Context context);

class MethodManager {
  final List<String> _names = [];
  final Map<String, Method> _methods = {};
  Iterable<String> getNames() => _names;
  Method get(String fullname) {
    fullname = fullname.toLowerCase();
    return _methods.containsKey(fullname) ? _methods[fullname] : _methods['*'];
  }

  void remove(String fullname) {
    _methods.remove(fullname.toLowerCase());
    _names.remove(fullname);
  }

  void add(Method method) {
    final fullname = method.fullname;
    _methods[fullname.toLowerCase()] = method;
    if (!_names.contains(fullname)) {
      _names.add(fullname);
    }
  }

  void addMethod(Function method, [String fullname]) {
    add(Method(method, fullname: fullname));
  }

  void addMethods(List<Function> _methods, [List<String> fullnames]) {
    if (fullnames != null) {
      for (var i = 0; i < _methods.length; ++i) {
        add(Method(_methods[i], fullname: fullnames[i]));
      }
    } else {
      for (var i = 0; i < _methods.length; ++i) {
        add(Method(_methods[i]));
      }
    }
  }

  void addMissingMethod<MissingMethod extends Function>(MissingMethod method) {
    if (method is MissingMethod1 || method is MissingMethod2) {
      add(Method(method, fullname: '*', missing: true));
    } else {
      throw ArgumentError('method is not a missing method');
    }
  }
}
