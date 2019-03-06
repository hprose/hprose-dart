/*--------------------------------------------------------*\
|                                                          |
|                          hprose                          |
|                                                          |
| Official WebSite: https://hprose.com                     |
|                                                          |
| oneway.dart                                              |
|                                                          |
| Oneway plugin for Dart.                                  |
|                                                          |
| LastModified: Mar 6, 2019                                |
| Author: Ma Bingyao <andot@hprose.com>                    |
|                                                          |
\*________________________________________________________*/

part of hprose.rpc.plugins;

class Oneway {
  Future handler(
      String name, List args, Context context, NextInvokeHandler next) async {
    final result = next(name, args, context);
    if (context.containsKey('oneway') && context['oneway'] as bool) {
      return null;
    }
    return result;
  }
}
