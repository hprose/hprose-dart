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
| LastModified: Mar 10, 2019                               |
| Author: Ma Bingyao <andot@hprose.com>                    |
|                                                          |
\*________________________________________________________*/

part of hprose.rpc.core;

class Method {
  final Function method;
  String fullname;
  final List<String> positionalParameterTypes = [];
  final List<String> optionalParameterTypes = [];
  final Map<String, String> namedParameterTypes = {};
  final bool missing;
  bool passContext = false;
  bool contextInPositionalArguments = false;
  bool contextInNamedArguments = false;
  bool hasOptionalArguments = false;
  bool hasNamedArguments = false;
  Method(this.method, [this.fullname, this.missing = false]) {
    if (fullname == null || fullname.isEmpty) {
      fullname = _getFunctionName(method);
    }
    if (fullname.isEmpty) {
      throw new ArgumentError.notNull('fullname');
    }
    _parseParameters(method);
    if (!hasOptionalArguments && !hasNamedArguments) {
      if (positionalParameterTypes.isNotEmpty &&
          (positionalParameterTypes.last == 'Context' ||
              positionalParameterTypes.last == 'ServiceContext')) {
        passContext = true;
        contextInPositionalArguments = true;
      }
    } else if (namedParameterTypes['context'] == 'Context' ||
        namedParameterTypes['context'] == 'ServiceContext') {
      passContext = true;
      contextInNamedArguments = true;
    }
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
        namedParameterTypes[name] = type;
      }
    }
    genericsArguments?.forEach((a) {
      for (var type in namedParameterTypes.entries) {
        if (a == type.value) {
          namedParameterTypes[type.key] = 'dynamic';
        } else {
          namedParameterTypes[type.key] = type.value
              .replaceAll('<$a>', '<dynamic>')
              .replaceAll('<$a,', '<dynamic,')
              .replaceAll(', $a>', ', dynamic>')
              .replaceAll(', $a,', ', dynamic,');
        }
      }
    });
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
      hasNamedArguments = true;
      _parseNamedParameters(
          genericsArguments, str.substring(p + 1, str.length - 1));
      str = str.substring(0, p - 2);
    }
    int nesting = 0;
    p = 0;
    var types = positionalParameterTypes;
    for (var i = 0; i < str.length; i++) {
      if (str[i] == '<') nesting++;
      if (str[i] == '>') nesting--;
      if (str[i] == ',' && nesting == 0) {
        types.add(str.substring(p, i));
        p = i = i + 2;
      }
      if (str[i] == '[') {
        hasOptionalArguments = true;
        types = optionalParameterTypes;
        p = i + 1;
      }
      if (str[i] == ']') {
        types.add(str.substring(p, i));
        break;
      }
    }
    if (str.isNotEmpty && types == positionalParameterTypes) {
      positionalParameterTypes.add(str.substring(p, str.length));
    }
    _replaceGenericsArguments(genericsArguments, positionalParameterTypes);
    _replaceGenericsArguments(genericsArguments, optionalParameterTypes);
  }

  void _replaceGenericsArguments(
      List<String> genericsArguments, List<String> types) {
    genericsArguments?.forEach((a) {
      var n = types.length;
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
  }
}
