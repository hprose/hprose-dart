/*--------------------------------------------------------*\
|                                                          |
|                          hprose                          |
|                                                          |
| Official WebSite: https://hprose.com                     |
|                                                          |
| tags.dart                                                |
|                                                          |
| hprose Tags for Dart.                                    |
|                                                          |
| LastModified: Feb 14, 2019                               |
| Author: Ma Bingyao <andot@hprose.com>                    |
|                                                          |
\*________________________________________________________*/

/* Serialize Tags */
/* 'i' */ const int TagInteger = 0x69;
/* 'l' */ const int TagLong = 0x6C;
/* 'd' */ const int TagDouble = 0x64;
/* 'n' */ const int TagNull = 0x6E;
/* 'e' */ const int TagEmpty = 0x65;
/* 't' */ const int TagTrue = 0x74;
/* 'f' */ const int TagFalse = 0x66;
/* 'N' */ const int TagNaN = 0x4E;
/* 'I' */ const int TagInfinity = 0x49;
/* 'D' */ const int TagDate = 0x44;
/* 'T' */ const int TagTime = 0x54;
/* 'Z' */ const int TagUTC = 0x5A;
/* 'b' */ const int TagBytes = 0x62;
/* 'u' */ const int TagUTF8Char = 0x75;
/* 's' */ const int TagString = 0x73;
/* 'g' */ const int TagGuid = 0x67;
/* 'a' */ const int TagList = 0x61;
/* 'm' */ const int TagMap = 0x6D;
/* 'c' */ const int TagClass = 0x63;
/* 'o' */ const int TagObject = 0x6F;
/* 'r' */ const int TagRef = 0x72;
/* Serialize Marks */
/* '+' */ const int TagPos = 0x2B;
/* '-' */ const int TagNeg = 0x2D;
/* ',' */ const int TagSemicolon = 0x3B;
/* '{' */ const int TagOpenbrace = 0x7B;
/* '}' */ const int TagClosebrace = 0x7D;
/* '"' */ const int TagQuote = 0x22;
/* '.' */ const int TagPoint = 0x2E;
/* RPC Protocol Tags */
/* 'H' */ const int TagHeader = 0x48;
/* 'C' */ const int TagCall = 0x43;
/* 'R' */ const int TagResult = 0x52;
/* 'E' */ const int TagError = 0x45;
/* 'z' */ const int TagEnd = 0x7A;
