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
 * filter.dart                                            *
 *                                                        *
 * hprose filter interface for Dart.                      *
 *                                                        *
 * LastModified: Mar 3, 2015                              *
 * Author: Ma Bingyao <andot@hprose.com>                  *
 *                                                        *
\**********************************************************/
part of hprose.rpc;

abstract class Filter {
  Uint8List inputFilter(Uint8List data, Context context);
  Uint8List outputFilter(Uint8List data, Context context);
}