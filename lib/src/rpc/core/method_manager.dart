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
| LastModified: Feb 26, 2019                               |
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

  void addMethod(Function func, [String fullname]) {
    add(new Method(func, fullname));
  }

  void addMethods(List<Function> funcs, [List<String> fullnames]) {
    if (fullnames != null) {
      for (int i = 0; i < funcs.length; ++i) {
        add(new Method(funcs[i], fullnames[i]));
      }
    }
    else {
      for (int i = 0; i < funcs.length; ++i) {
        add(new Method(funcs[i]));
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
