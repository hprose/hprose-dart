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
| LastModified: Oct 4, 2019                                |
| Author: Ma Bingyao <andot@hprose.com>                    |
|                                                          |
\*________________________________________________________*/

part of hprose.rpc.plugins;

class Oneway {
  const Oneway();
  Future handler(
      String name, List args, Context context, NextInvokeHandler next) {
    final result = next(name, args, context);
    if (context.containsKey('oneway') && context['oneway'] as bool) {
      result.catchError((e) => {});
      return null;
    }
    return result;
  }
}

const oneway = const Oneway();
