/*--------------------------------------------------------*\
|                                                          |
|                          hprose                          |
|                                                          |
| Official WebSite: https://hprose.com                     |
|                                                          |
| type_info.dart                                           |
|                                                          |
| hprose TypeInfo for Dart.                                |
|                                                          |
| LastModified: Feb 16, 2019                               |
| Author: Ma Bingyao <andot@hprose.com>                    |
|                                                          |
\*________________________________________________________*/

part of hprose.io;

class TypeInfo {
    final String name;
    final List<String> names;
    final List<Type> types;
    TypeInfo(this.name, this.names, this.types);
}