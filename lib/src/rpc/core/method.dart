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
| LastModified: Mar 28, 2020                               |
| Author: Ma Bingyao <andot@hprose.com>                    |
|                                                          |
\*________________________________________________________*/

part of hprose.rpc.core;

class Method {
  static final List<String> _contextTypes = ['Context', 'ServiceContext'];
  static registerContextType(String contextType) {
    if (!_contextTypes.contains(contextType)) {
      _contextTypes.add(contextType);
    }
  }

  final Function method;
  String name;
  final List<String> positionalParameterTypes = [];
  final List<String> optionalParameterTypes = [];
  final Map<String, String> namedParameterTypes = {};
  final bool missing;
  final Map<String, dynamic> options;
  dynamic operator [](String key) => options[key];
  void operator []=(String key, value) => options[key] = value;
  bool passContext = false;
  bool contextInPositionalArguments = false;
  bool contextInNamedArguments = false;
  bool hasOptionalArguments = false;
  bool hasNamedArguments = false;
  Method(this.method,
      {this.name, this.missing = false, this.options = const {}}) {
    if (name == null || name.isEmpty) {
      name = _getFunctionName(method);
    }
    if (name.isEmpty) {
      throw ArgumentError.notNull('name');
    }
    _parseParameters(method);
    if (!hasOptionalArguments && !hasNamedArguments) {
      if (positionalParameterTypes.isNotEmpty &&
          _contextTypes.contains(positionalParameterTypes.last)) {
        passContext = true;
        contextInPositionalArguments = true;
      }
    } else if (_contextTypes.contains(namedParameterTypes['context'])) {
      passContext = true;
      contextInNamedArguments = true;
    }
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    var name = invocation.memberName.toString();
    name = name.substring(8, name.length - 2);
    if (invocation.isGetter) {
      return options[name];
    } else if (invocation.isSetter) {
      name = name.substring(0, name.length - 1);
      options[name] = invocation.positionalArguments[0];
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
    var nesting = 0;
    var p = 0;
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
    var nesting = 0;
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
