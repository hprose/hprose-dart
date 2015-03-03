/**********************************************************\
|                                                          |
|                          hprose                          |
|                                                          |
| Official WebSite: http://www.hprose.com/                 |
|                   http://www.hprose.org/                 |
|                                                          |
\**********************************************************/
/**********************************************************\
 *                                                        *
 * context.dart                                           *
 *                                                        *
 * hprose context class for Dart.                         *
 *                                                        *
 * LastModified: Mar 3, 2015                              *
 * Author: Ma Bingyao <andot@hprose.com>                  *
 *                                                        *
\**********************************************************/
part of hprose.rpc;

class Context {
  Map<String, dynamic> _userdata = new Map<String, dynamic>();
  Map<String, dynamic> get userdata => _userdata;
  dynamic operator [](String key) => userdata[key];
  void operator []=(String key, dynamic value) => userdata[key] = value;
}