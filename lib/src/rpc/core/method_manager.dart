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
| LastModified: Dec 31, 2019                               |
| Author: Ma Bingyao <andot@hprose.com>                    |
|                                                          |
\*________________________________________________________*/

part of hprose.rpc.core;

typedef MissingMethod1 = dynamic Function(String fullname, List args);
typedef MissingMethod2 = dynamic Function(
    String fullname, List args, Context context);

class MethodManager {
  Map<String, Method> methods = {};
  Iterable<String> getNames() => methods.keys;
  Method get(String fullname) {
    return methods.containsKey(fullname) ? methods[fullname] : methods['*'];
  }

  void remove(String fullname) {
    methods.remove(fullname);
  }

  void add(Method method) {
    methods[method.fullname] = method;
  }

  void addMethod(Function method, [String fullname]) {
    add(Method(method, fullname: fullname));
  }

  void addMethods(List<Function> methods, [List<String> fullnames]) {
    if (fullnames != null) {
      for (var i = 0; i < methods.length; ++i) {
        add(Method(methods[i], fullname: fullnames[i]));
      }
    } else {
      for (var i = 0; i < methods.length; ++i) {
        add(Method(methods[i]));
      }
    }
  }

  void addMissingMethod<MissingMethod extends Function>(MissingMethod method) {
    if (method is MissingMethod1 || method is MissingMethod2) {
      methods['*'] = Method(method, fullname: '*', missing: true);
    } else {
      throw ArgumentError('method is not a missing method');
    }
  }
}
