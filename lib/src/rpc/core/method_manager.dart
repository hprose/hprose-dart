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
| LastModified: Feb 27, 2019                               |
| Author: Ma Bingyao <andot@hprose.com>                    |
|                                                          |
\*________________________________________________________*/

part of hprose.rpc.core;

typedef dynamic MissingMethod1(String fullname, List args);
typedef dynamic MissingMethod2(String fullname, List args, Context context);

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
    add(new Method(method, fullname));
  }

  void addMethods(List<Function> methods, [List<String> fullnames]) {
    if (fullnames != null) {
      for (int i = 0; i < methods.length; ++i) {
        add(new Method(methods[i], fullnames[i]));
      }
    } else {
      for (int i = 0; i < methods.length; ++i) {
        add(new Method(methods[i]));
      }
    }
  }

  void addMissingMethod<MissingMethod extends Function>(MissingMethod method) {
    if (method is MissingMethod1 || method is MissingMethod2) {
      methods['*'] = new Method(method, '*', true);
    } else {
      throw new ArgumentError('method is not a missing method');
    }
  }
}
