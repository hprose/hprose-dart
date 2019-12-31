/*--------------------------------------------------------*\
|                                                          |
|                          hprose                          |
|                                                          |
| Official WebSite: https://hprose.com                     |
|                                                          |
| byte_stream.dart                                         |
|                                                          |
| hprose ByteStream for Dart.                              |
|                                                          |
| LastModified: Dec 31, 2019                               |
| Author: Ma Bingyao <andot@hprose.com>                    |
|                                                          |
\*________________________________________________________*/

part of hprose.io;

class ByteStream {
  static const int _initSize = 1024;
  static final _emptyList = Uint8List(0);
  Uint8List _buffer = _emptyList;
  int _size = 0;
  int _offset = 0;
  int _rmark = 0;
  int _wmark = 0;

  static int _pow2roundup(int value) {
    --value;
    value |= value >> 1;
    value |= value >> 2;
    value |= value >> 4;
    value |= value >> 8;
    value |= value >> 16;
    return value + 1;
  }

  ByteStream([int initialCapacity = 0]) {
    _buffer = (initialCapacity <= 0)
        ? _emptyList
        : Uint8List(_pow2roundup(initialCapacity));
  }

  ByteStream.fromByteBuffer(ByteBuffer buffer,
      [int offsetInBytes = 0, int length]) {
    _buffer = (buffer == null)
        ? _emptyList
        : buffer.asUint8List(offsetInBytes, length);
    _size = _buffer.length;
    mark();
  }

  ByteStream.fromString(String str) {
    writeString(str);
    mark();
  }

  ByteStream.fromUint8List(Uint8List list) {
    _buffer = (list == null) ? _emptyList : list;
    _size = _buffer.length;
    mark();
  }

  ByteStream.fromUint8ClampedList(Uint8ClampedList list) {
    _buffer = (list == null)
        ? _emptyList
        : list.buffer.asUint8List(list.offsetInBytes, list.length);
    _size = _buffer.length;
    mark();
  }

  ByteStream.fromByteStream(ByteStream bytes) {
    _buffer = (bytes == null) ? _emptyList : bytes.toBytes();
    _size = _buffer.length;
    mark();
  }

  void _grow(int n) {
    n = _size + n;
    if (n > capacity) {
      if (capacity > 0) {
        final buf = Uint8List(_pow2roundup(n));
        buf.setAll(0, _buffer);
        _buffer = buf;
      } else {
        _buffer = Uint8List(max(_pow2roundup(n), _initSize));
      }
    }
  }

  /// Returns the current capacity of this stream.
  int get capacity => _buffer.length;

  /// Returns the current length of the data in this stream.
  int get length => _size;

  /// Returns the position of the next reading operation in this stream.
  int get position => _offset;

  /// Returns all bytes data in this stream.
  ///
  /// If the returned data is changed, the data in this stream will be also changed.
  Uint8List get bytes => _buffer.sublist(0, _size);

  /// Returns all bytes data in this stream that has not been read.
  ///
  /// If the returned data is changed, the data in this stream will be also changed.
  Uint8List get remains => _buffer.sublist(_offset, _size);

  /// Sets this stream's mark at its reading and writing position.
  void mark() {
    _wmark = _size;
    _rmark = _offset;
  }

  /// Resets this stream's reading and writing position to the previously-marked position.
  ///
  /// Invoking this method neither changes nor discards the mark's value.
  void reset() {
    _size = _wmark;
    _offset = _rmark;
  }

  /// Clears this stream.
  ///
  /// The position is set to zero, the limit is set to the capacity, and the mark is discarded.
  void clear() {
    _buffer = _emptyList;
    _size = 0;
    _offset = 0;
    _wmark = 0;
    _rmark = 0;
  }

  /// Writes a byte to the stream as a 1-byte value.
  ///
  /// @param byte a byte value to be written.
  void writeByte(int byte) {
    _grow(1);
    _buffer[_size++] = byte;
  }

  static int _writeUInt32BE(Uint8List bytes, int offset, int value) {
    bytes[offset++] = value >> 24 & 0xFF;
    bytes[offset++] = value >> 16 & 0xFF;
    bytes[offset++] = value >> 8 & 0xFF;
    bytes[offset++] = value & 0xFF;
    return offset;
  }

  static int _writeUInt32LE(Uint8List bytes, int offset, int value) {
    bytes[offset++] = value & 0xFF;
    bytes[offset++] = value >> 8 & 0xFF;
    bytes[offset++] = value >> 16 & 0xFF;
    bytes[offset++] = value >> 24 & 0xFF;
    return offset;
  }

  /// Writes value to this stream with big endian format.
  ///
  /// @param value number to be written to this stream. value should be a valid signed 32-bit integer.
  /// RangeError will be throwed when value is anything other than a signed 32-bit integer.
  void writeInt32BE(int value) {
    if (value < -2147483648 || value > 2147483647) {
      throw RangeError.range(value, -2147483648, 2147483647, 'value');
    }
    _grow(4);
    _size = _writeUInt32BE(_buffer, _size, value);
  }

  /// Writes value to this stream with big endian format.
  ///
  /// @param value number to be written to this stream. value should be a valid unsigned 32-bit integer.
  /// RangeError will be throwed when value is anything other than a unsigned 32-bit integer.
  void writeUInt32BE(int value) {
    if (value < 0 || value > 0xFFFFFFFF) {
      throw RangeError.range(value, 0, 0xFFFFFFFF, 'value');
    }
    _grow(4);
    _size = _writeUInt32BE(_buffer, _size, value);
  }

  /// Writes value to this stream with little endian format.
  ///
  /// @param value number to be written to this stream. value should be a valid signed 32-bit integer.
  /// RangeError will be throwed when value is anything other than a signed 32-bit integer.
  void writeInt32LE(int value) {
    if (value < -2147483648 || value > 2147483647) {
      throw RangeError.range(value, -2147483648, 2147483647, 'value');
    }
    _grow(4);
    _size = _writeUInt32LE(_buffer, _size, value);
  }

  /// Writes value to this stream with little endian format.
  ///
  /// @param value number to be written to this stream. value should be a valid unsigned 32-bit integer.
  /// RangeError will be throwed when value is anything other than a unsigned 32-bit integer.
  void writeUInt32LE(int value) {
    if (value < 0 || value > 0xFFFFFFFF) {
      throw RangeError.range(value, 0, 0xFFFFFFFF, 'value');
    }
    _grow(4);
    _size = _writeUInt32LE(_buffer, _size, value);
  }

  /// Writes binary data to this stream.
  ///
  /// @param data to be written to this stream.
  void write(dynamic data) {
    final n = (data is ByteBuffer) ? data.lengthInBytes : data.length;
    if (n == 0) return;
    _grow(n);
    final bytes = _buffer;
    final offset = _size;
    if (data is ByteStream) {
      bytes.setAll(offset, data.bytes);
    } else if (data is ByteBuffer) {
      bytes.setAll(offset, data.asUint8List());
    } else {
      bytes.setAll(offset, data);
    }
    _size += n;
  }

  /// Writes str to this stream with ascii encoding.
  ///
  /// @param str to be written to this stream.
  void writeAsciiString(String str) {
    if (str.isEmpty) return;
    final n = str.length;
    _grow(n);
    _buffer.setAll(_size, str.codeUnits);
    _size += n;
  }

  /// Writes str to this stream with utf8 encoding.
  ///
  /// @param str to be written to this stream.
  void writeString(String str) {
    if (str.isEmpty) return;
    final utf8List = utf8.encode(str);
    final n = utf8List.length;
    _grow(n);
    _buffer.setAll(_size, utf8List);
    _size += n;
  }

  /// Reads and returns a single byte.
  ///
  /// If no byte is available, returns -1.
  int readByte() {
    if (_offset >= _size) return -1;
    return _buffer[_offset++];
  }

  /// Reads a signed 32-bit integer from this stream with the big endian format.
  ///
  /// If the remaining data is less than 4 bytes, Error('EOF') will be throw.
  int readInt32BE() {
    return readUInt32BE().toSigned(32);
  }

  /// Reads an unsigned 32-bit integer from this stream with the big endian format.
  ///
  /// If the remaining data is less than 4 bytes, Error('EOF') will be throw.
  int readUInt32BE() {
    final bytes = _buffer;
    var offset = _offset;
    if (offset + 3 >= _size) {
      throw Exception('EOF');
    }
    final result = bytes[offset++] << 24 |
        bytes[offset++] << 16 |
        bytes[offset++] << 8 |
        bytes[offset++];
    _offset = offset;
    return result;
  }

  /// Reads a signed 32-bit integer from this stream with the little endian format.
  ///
  /// If the remaining data is less than 4 bytes, Error('EOF') will be throw.
  int readInt32LE() {
    return readUInt32LE().toSigned(32);
  }

  /// Reads an unsigned 32-bit integer from this stream with the little endian format.
  ///
  /// If the remaining data is less than 4 bytes, Error('EOF') will be throw.
  int readUInt32LE() {
    final bytes = _buffer;
    var offset = _offset;
    if (offset + 3 >= _size) {
      throw Exception('EOF');
    }
    final result = bytes[offset++] |
        bytes[offset++] << 8 |
        bytes[offset++] << 16 |
        bytes[offset++] << 24;
    _offset = offset;
    return result;
  }

  /// Reads n bytes of data from this stream and returns the result as a Uint8Array.
  ///
  /// If n is negative, reads to the end of this stream.
  /// @param n The maximum number of bytes to read.
  Uint8List read(int n) {
    if (n < 0 || _offset + n > _size) n = _size - _offset;
    if (n == 0) return _emptyList;
    return _buffer.sublist(_offset, _offset += n);
  }

  /// Skips over and discards n bytes of data from this stream.
  ///
  /// The actual number of bytes skipped is returned.
  /// If n is negative, all remaining bytes are skipped.
  /// @param n the number of bytes to be skipped.
  int skip(int n) {
    if (n == 0) return 0;
    if (n < 0 || _offset + n > _size) {
      n = _size - _offset;
      _offset = _size;
    } else {
      _offset += n;
    }
    return n;
  }

  /// Returns a Uint8Array from the current position to the delimiter. The result includes delimiter.
  ///
  /// Returns all remaining data if no delimiter is found.
  /// After this method is called, The new position is after the delimiter.
  /// @param delimiter a byte, which represents the end of reading data.
  Uint8List readBytes(int delimiter) {
    final pos = _buffer.indexOf(delimiter, _offset);
    Uint8List result;
    if (pos == -1) {
      result = _buffer.sublist(_offset, _size);
      _offset = _size;
    } else {
      result = _buffer.sublist(_offset, pos + 1);
      _offset = pos + 1;
    }
    return result;
  }

  /// Returns a string from the current position to the delimiter. The result doesn't include delimiter.
  ///
  /// Returns all remaining data if no delimiter is found.
  /// After this method is called, the new position is after the delimiter.
  /// @param delimiter a byte, which represents the end of reading data.
  String readUntil(int delimiter) {
    final pos = _buffer.indexOf(delimiter, _offset);
    var result = '';
    if (pos == _offset) {
      _offset++;
    } else if (pos == -1) {
      result = utf8.decode(_buffer.sublist(_offset, _size));
      _offset = _size;
    } else {
      result = utf8.decode(_buffer.sublist(_offset, pos));
      _offset = pos + 1;
    }
    return result;
  }

  /// Reads n bytes of data from this stream and returns the result as an ascii string.
  ///
  /// If n is negative, reads to the end of this stream.
  /// @param n The maximum number of bytes to read.
  String readAsciiString(int n) => String.fromCharCodes(read(n));

  /// Returns a Uint8Array containing a string of length n.
  ///
  /// If n is negative, reads to the end of this stream.
  /// @param n is the string(UTF16) length.
  Uint8List readStringAsBytes(int n) {
    if (n == 0) return _emptyList;
    final bytes = _buffer.sublist(_offset, _size);
    if (n < 0) {
      _offset = _size;
      return bytes;
    }
    var offset = 0;
    for (var i = 0, length = bytes.length; i < n && offset < length; ++i) {
      final unit = bytes[offset++];
      switch (unit >> 4) {
        case 0:
        case 1:
        case 2:
        case 3:
        case 4:
        case 5:
        case 6:
        case 7:
          break;
        case 12:
        case 13:
          if (offset < length) {
            offset++;
            break;
          }
          throw Exception('Unfinished UTF-8 octet sequence');
        case 14:
          if (offset + 1 < length) {
            offset += 2;
            break;
          }
          throw Exception('Unfinished UTF-8 octet sequence');
        case 15:
          if (offset + 2 < length) {
            final rune = (((unit & 0x07) << 18) |
                    ((bytes[offset++] & 0x3F) << 12) |
                    ((bytes[offset++] & 0x3F) << 6) |
                    (bytes[offset++] & 0x3F)) -
                0x10000;
            if (0 <= rune && rune <= 0xFFFFF) {
              i++;
              break;
            }
            throw Exception('Character outside valid Unicode range: 0x' +
                rune.toRadixString(16));
          }
          throw Exception('Unfinished UTF-8 octet sequence');
        default:
          throw Exception('Bad UTF-8 encoding 0x' + unit.toRadixString(16));
      }
    }
    _offset += offset;
    return bytes.sublist(0, offset);
  }

  /// Returns a string of length n.
  ///
  /// If n is negative, reads to the end of this stream.
  /// @param n is the string(UTF16) length.
  String readString(int n) => utf8.decode(readStringAsBytes(n));

  /// Returns a view of the the internal buffer and clears `this`.
  Uint8List takeBytes() {
    final bytes = this.bytes;
    clear();
    return bytes;
  }

  /// Returns a copy of the current contents and leaves `this` intact.
  Uint8List toBytes() => Uint8List.fromList(bytes);

  /// Returns a string representation of this stream.
  @override
  String toString() => utf8.decode(bytes);

  /// Creates an exact copy of this stream.
  ByteStream clone() => ByteStream.fromByteStream(this);

  /// Truncates this stream, only leaves the unread data.
  ///
  /// The position is reset to 0.
  /// The mark is cleared.
  void trunc() {
    _buffer = remains;
    _size = _buffer.length;
    _offset = 0;
    _wmark = 0;
    _rmark = 0;
  }
}
