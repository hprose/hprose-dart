/*--------------------------------------------------------*\
|                                                          |
|                          hprose                          |
|                                                          |
| Official WebSite: https://hprose.com                     |
|                                                          |
| push.dart                                                |
|                                                          |
| Push plugin for Dart.                                    |
|                                                          |
| LastModified: Dec 31, 2019                               |
| Author: Ma Bingyao <andot@hprose.com>                    |
|                                                          |
\*________________________________________________________*/

part of hprose.rpc.plugins;

class Message {
  dynamic data;
  String from;
  Message(this.data, this.from);
  factory Message.FromJson(Map<String, dynamic> json) =>
      Message(json['data'], json['from']);
  Map<String, dynamic> toJson() => {'data': data, 'from': from};
}

class Producer {
  final Broker _broker;
  final String from;
  Producer(this._broker, this.from);
  bool unicast(dynamic data, String topic, String id) =>
      _broker.unicast(data, topic, id, from);
  Map<String, bool> multicast(dynamic data, String topic, List<String> ids) =>
      _broker.multicast(data, topic, ids, from);
  Map<String, bool> broadcast(dynamic data, String topic) =>
      _broker.broadcast(data, topic, from);
  dynamic push(dynamic data, String topic, [dynamic id]) =>
      _broker.push(data, topic, id);
  void deny([String id, String topic]) => _broker.deny(id ?? from, topic);
  bool exists(String topic, [String id]) => _broker.exists(topic, id ?? from);
  List<String> idlist(String topic) => _broker.idlist(topic);
}

class BrokerContext extends ServiceContext {
  final Producer producer;
  BrokerContext(this.producer, ServiceContext context)
      : super(context.service) {
    context.copyTo(this);
  }
}

class Broker {
  final _messages = <String, Map<String, List<Message>>>{};
  final _responders = <String, Completer<Map<String, List<Message>>>>{};
  final _timers = <String, Completer<bool>>{};
  Service service;
  int messageQueueMaxLength = 10;
  Duration timeout = const Duration(minutes: 2);
  Duration heartbeat = const Duration(seconds: 10);
  void Function(String id, String topic, ServiceContext context) onSubscribe;
  void Function(String id, String topic, List<Message> messages,
      ServiceContext context) onUnsubscribe;
  Broker(this.service) {
    if (!TypeManager.isRegister('@')) {
      TypeManager.register<Message>((json) => Message.FromJson(json),
          {'data': dynamic, 'from': String}, '@');
    }
    Method.registerContextType('BrokerContext');
    service
      ..addMethod(_subscribe, '+')
      ..addMethod(_unsubscribe, '-')
      ..addMethod(_message, '<')
      ..addMethod(unicast, '>')
      ..addMethod(multicast, '>?')
      ..addMethod(broadcast, '>*')
      ..addMethod(exists, '?')
      ..addMethod(idlist, '|')
      ..use(_handler);
  }
  bool _send(String id, Completer<Map<String, List<Message>>> responder) {
    if (!_messages.containsKey(id)) {
      if (!responder.isCompleted) {
        responder.complete(null);
      }
      return true;
    }
    final topics = _messages[id];
    if (topics.isEmpty) {
      if (!responder.isCompleted) {
        responder.complete(null);
      }
      return true;
    }
    final result = <String, List<Message>>{};
    var count = 0;
    for (final topic in topics.entries) {
      final name = topic.key;
      final messages = topic.value;
      if (messages == null || messages.isNotEmpty) {
        ++count;
        result[name] = messages;
        if (messages == null) {
          topics.remove(name);
        } else {
          topics[name] = [];
        }
      }
    }
    if (count == 0) return false;
    if (!responder.isCompleted) {
      responder.complete(result);
    }
    if (heartbeat > Duration.zero) {
      _doHeartbeat(id);
    }
    return true;
  }

  void _doHeartbeat(String id) {
    var timer = Completer<bool>();
    if (_timers.containsKey(id) && !_timers[id].isCompleted) {
      _timers[id].complete(false);
    }
    _timers[id] = timer;
    var heartbeatTimer = Timer(heartbeat, () {
      if (!timer.isCompleted) {
        timer.complete(true);
      }
    });
    timer.future.then((value) {
      heartbeatTimer.cancel();
      if (value && _messages.containsKey(id)) {
        final topics = _messages[id];
        for (final topic in topics.keys) {
          _offline(topics, id, topic, service.createContext());
        }
      }
    });
  }

  String _getId(ServiceContext context) {
    if (context.requestHeaders.containsKey('id')) {
      return context.requestHeaders['id'].toString();
    }
    throw Exception('Client unique id not found');
  }

  bool _subscribe(String topic, ServiceContext context) {
    final id = _getId(context);
    if (!_messages.containsKey(id)) {
      _messages[id] = {};
    }
    if (_messages[id].containsKey(topic)) {
      return false;
    }
    _messages[id][topic] = [];
    if (onSubscribe != null) {
      onSubscribe(id, topic, context);
    }
    return true;
  }

  void _response(String id) {
    if (_responders.containsKey(id)) {
      final responder = _responders[id];
      if (_send(id, responder)) {
        _responders.remove(id);
      }
    }
  }

  bool _offline(Map<String, List<Message>> topics, String id, String topic,
      ServiceContext context) {
    if (topics.containsKey(topic)) {
      final messages = topics.remove(topic);
      if (onUnsubscribe != null) {
        onUnsubscribe(id, topic, messages, context);
      }
      _response(id);
      return true;
    }
    return false;
  }

  bool _unsubscribe(String topic, ServiceContext context) {
    final id = _getId(context);
    if (_messages.containsKey(id)) {
      return _offline(_messages[id], id, topic, context);
    }
    return false;
  }

  Future<Map<String, List<Message>>> _message(ServiceContext context) async {
    final id = _getId(context);
    if (_responders.containsKey(id)) {
      final responder = _responders.remove(id);
      if (!responder.isCompleted) {
        responder.complete(null);
      }
    }
    if (_timers.containsKey(id)) {
      final timer = _timers.remove(id);
      if (!timer.isCompleted) {
        timer.complete(false);
      }
    }
    final responder = Completer<Map<String, List<Message>>>();
    if (!_send(id, responder)) {
      _responders[id] = responder;
      if (timeout > Duration.zero) {
        var timeoutTimer = Timer(timeout, () {
          if (!responder.isCompleted) {
            responder.complete({});
          }
        });
        await responder.future.then((value) {
          timeoutTimer.cancel();
        });
      }
    }
    return responder.future;
  }

  bool unicast(dynamic data, String topic, String id, [String from = '']) {
    if (_messages.containsKey(id) && _messages[id].containsKey(topic)) {
      final messages = _messages[id][topic];
      if (messages.length < messageQueueMaxLength) {
        messages.add(Message(data, from));
        _response(id);
        return true;
      }
    }
    return false;
  }

  Map<String, bool> multicast(dynamic data, String topic, List<String> ids,
      [String from = '']) {
    final result = <String, bool>{};
    for (final id in ids) {
      result[id] = unicast(data, topic, id, from);
    }
    return result;
  }

  Map<String, bool> broadcast(dynamic data, String topic, [String from = '']) {
    final result = <String, bool>{};
    for (final id in _messages.keys) {
      if (_messages[id].containsKey(topic)) {
        final messages = _messages[id][topic];
        if (messages.length < messageQueueMaxLength) {
          messages.add(Message(data, from));
          _response(id);
          result[id] = true;
        } else {
          result[id] = false;
        }
      }
    }
    return result;
  }

  dynamic push(dynamic data, String topic, [dynamic id, String from = '']) {
    if (id == null) {
      return broadcast(data, topic, from);
    }
    if (id is String) {
      return unicast(data, topic, id, from);
    }
    return multicast(data, topic, id, from);
  }

  void deny(String id, [String topic]) {
    if (_messages.containsKey(id)) {
      if (topic != null && topic.isNotEmpty) {
        if (_messages[id].containsKey(topic)) {
          _messages[id][topic] = null;
        }
      } else {
        for (final topic in _messages[id].keys) {
          _messages[id][topic] = null;
        }
      }
      _response(id);
    }
  }

  bool exists(String topic, String id) {
    return _messages.containsKey(id) &&
        _messages[id].containsKey(topic) &&
        _messages[id][topic] != null;
  }

  List<String> idlist(String topic) {
    final idlist = <String>[];
    for (final id in _messages.keys) {
      if (_messages[id].containsKey(topic) && _messages[id][topic] != null) {
        idlist.add(id);
      }
    }
    return idlist;
  }

  Future _handler(
      String name, List args, Context context, NextInvokeHandler next) {
    final serviceContext = context as ServiceContext;
    final from = serviceContext.requestHeaders.containsKey('id')
        ? serviceContext.requestHeaders['id'].toString()
        : '';
    switch (name) {
      case '>':
      case '>?':
        if (args.length == 3) args.add(from);
        break;
      case '>*':
        if (args.length == 2) args.add(from);
        break;
    }
    return next(name, args, BrokerContext(Producer(this, from), context));
  }
}

class Prosumer {
  final Map<String, void Function(Message message)> _callbacks = {};
  final Client client;
  void Function(dynamic error) onError;
  void Function(String topic) onSubscribe;
  void Function(String topic) onUnsubscribe;
  String get id {
    if (client.requestHeaders.containsKey('id')) {
      return client.requestHeaders['id'].toString();
    }
    throw Exception('Client unique id not found');
  }

  set id(String value) {
    client.requestHeaders['id'] = value;
  }

  Prosumer(this.client, [String id]) {
    if (!TypeManager.isRegister('@')) {
      TypeManager.register<Message>((json) => Message.FromJson(json),
          {'data': dynamic, 'from': String}, '@');
    }
    if (!Deserializer.isRegister<List<Message>>()) {
      Deserializer.register<List<Message>>(ListDeserializer<Message>());
    }
    if (!Deserializer.isRegister<Map<String, List<Message>>>()) {
      Deserializer.register<Map<String, List<Message>>>(
          MapDeserializer<String, List<Message>>());
    }
    if (id != null && id.isNotEmpty) this.id = id;
  }

  void _dispatch(Map<String, List<Message>> topics) {
    for (final topic in topics.keys) {
      final callback = _callbacks[topic];
      if (callback != null) {
        final messages = topics[topic];
        if (messages != null) {
          for (var i = 0, n = messages.length; i < n; ++i) {
            Future.microtask(() {
              try {
                callback(messages[i]);
              } catch (e) {
                if (onError != null) {
                  onError(e);
                }
              }
            });
          }
        } else {
          _callbacks.remove(topic);
          if (onUnsubscribe != null) {
            onUnsubscribe(topic);
          }
        }
      }
    }
  }

  void _message() async {
    while (true) {
      try {
        final topics = await client.invoke<Map<String, List<Message>>>('<');
        if (topics == null) return;
        _dispatch(topics);
      } catch (e) {
        if (onError != null) {
          onError(e);
        }
      }
    }
  }

  Future<bool> subscribe(
      String topic, void Function(Message message) callback) async {
    if (id.isNotEmpty) {
      _callbacks[topic] = callback;
      final result = await client.invoke<bool>('+', [topic]);
      _message();
      if (onSubscribe != null) {
        onSubscribe(topic);
      }
      return result;
    }
    return false;
  }

  Future<bool> unsubscribe(String topic) async {
    if (id.isNotEmpty) {
      final result = await client.invoke<bool>('-', [topic]);
      _callbacks.remove(topic);
      if (onUnsubscribe != null) {
        onUnsubscribe(topic);
      }
      return result;
    }
    return false;
  }

  Future<bool> unicast(dynamic data, String topic, String id) {
    return client.invoke<bool>('>', [data, topic, id]);
  }

  Future<Map<String, bool>> multicast(
      dynamic data, String topic, List<String> ids) {
    return client.invoke<Map<String, bool>>('>?', [data, topic, ids]);
  }

  Future<Map<String, bool>> broadcast(dynamic data, String topic) {
    return client.invoke<Map<String, bool>>('>*', [data, topic]);
  }

  Future<dynamic> push(dynamic data, String topic, [dynamic id]) {
    if (id == null) {
      return broadcast(data, topic);
    }
    if (id is String) {
      return unicast(data, topic, id);
    }
    return multicast(data, topic, id);
  }

  Future<bool> exists(String topic, [String id]) {
    if (id == null || id.isEmpty) {
      id = this.id;
    }
    return client.invoke<bool>('?', [topic, id]);
  }

  Future<List<String>> idlist(String topic) {
    return client.invoke<List<String>>('|', [topic]);
  }
}
