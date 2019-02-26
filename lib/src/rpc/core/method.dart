/*--------------------------------------------------------*\
|                                                          |
|                          hprose                          |
|                                                          |
| Official WebSite: https://hprose.com                     |
|                                                          |
| method.dart                                              |
|                                                          |
| Method for Dart.                                         |
|                                                          |
| LastModified: Feb 24, 2019                               |
| Author: Ma Bingyao <andot@hprose.com>                    |
|                                                          |
\*________________________________________________________*/

part of hprose.rpc.core;

class Method {
  final Function method;
  String fullname;
  List<String> positionalParameterTypes;
  Map<String, String> namedParameterTypes;
  bool missing;
  Method(this.method, [this.fullname, this.missing]) {
    if (fullname == null || fullname.isEmpty) {
      fullname = _getFunctionName(method);
    }
    if (fullname.isEmpty) {
      throw new ArgumentError.notNull('fullname');
    }
    _parseParameters(method);
  }

  String _getFunctionName(Function func) {
    var str = func.toString();
    var n = str.indexOf(' from Function \'');
    if (n < 0) return '';
    str = str.substring(n + 16);
    n = str.indexOf('\':');
    if (n < 0) return '';
    return str.substring(0, n);
  }

  void _parseNamedParameters(List<String> genericsArguments, String str) {
    Map<String, String> types = {};
    int nesting = 0;
    int p = 0;
    String type;
    String name;
    for (var i = 0; i < str.length; i++) {
      if (str[i] == '<') nesting++;
      if (str[i] == '>') nesting--;
      if (str[i] == ' ' && nesting == 0) {
        type = str.substring(p, i);
        p = str.indexOf(', ', i + 1);
        if (p == -1) {
          p = str.length;
        }
        name = str.substring(i + 1, p);
        p = i = p + 2;
        types[name] = type;
      }
    }
    genericsArguments?.forEach((a) {
      for (var type in types.entries) {
        if (a == type.value) {
          types[type.key] = 'dynamic';
        } else {
          types[type.key] = type.value
              .replaceAll('<$a>', '<dynamic>')
              .replaceAll('<$a,', '<dynamic,')
              .replaceAll(', $a>', ', dynamic>')
              .replaceAll(', $a,', ', dynamic,');
        }
      }
    });
    namedParameterTypes = types;
  }

  void _parseParameters(Function func) {
    var str = func.runtimeType.toString();
    List<String> genericsArguments;
    var p = -1;
    if (str.startsWith('<')) {
      p = str.indexOf('>(');
      genericsArguments = str.substring(1, p).split(', ');
    }
    str = str.substring(p + 2, str.indexOf(') => '));
    p = str.indexOf('{');
    if (p != -1) {
      _parseNamedParameters(
          genericsArguments, str.substring(p + 1, str.length - 1));
      str = str.substring(0, p - 2);
    }
    List<String> types = [];
    int nesting = 0;
    p = 0;
    for (var i = 0; i < str.length; i++) {
      if (str[i] == '<') nesting++;
      if (str[i] == '>') nesting--;
      if (str[i] == ',' && nesting == 0) {
        types.add(str.substring(p, i));
        p = i = i + 2;
      }
    }
    if (str.length > 0) {
      types.add(str.substring(p, str.length));
    }
    var n = types.length;
    genericsArguments?.forEach((a) {
      for (var i = 0; i < n; i++) {
        if (a == types[i]) {
          types[i] = 'dynamic';
        } else {
          types[i] = types[i]
              .replaceAll('<$a>', '<dynamic>')
              .replaceAll('<$a,', '<dynamic,')
              .replaceAll(', $a>', ', dynamic>')
              .replaceAll(', $a,', ', dynamic,');
        }
      }
    });
    positionalParameterTypes = types;
  }
}
