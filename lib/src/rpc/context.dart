/*--------------------------------------------------------*\
|                                                          |
|                          hprose                          |
|                                                          |
| Official WebSite: https://hprose.com                     |
|                                                          |
| context.dart                                             |
|                                                          |
| hprose Context for Dart.                                 |
|                                                          |
| LastModified: Feb 22, 2019                               |
| Author: Ma Bingyao <andot@hprose.com>                    |
|                                                          |
\*________________________________________________________*/

part of hprose.rpc;

class Context {
  final Map<String, dynamic> Items = <String, dynamic>{};

  operator [](String key) => Items[key];

  void operator []=(String key, value) => Items[key] = value;

  bool containsKey(String key) => Items.containsKey(key);

  Context clone() {
    final context = new Context();
    context.Items.addAll(Items);
    return context;
  }
}
