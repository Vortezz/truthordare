import 'dart:async';

typedef EventCallback = void Function(Object? context);

Map<String, Map<String, EventCallback>> messages = {};
Map<String, List<String>> onceTokens = {};
int lastUid = -1;

mixin EventEmitter {
  void _deliver(message, data) {
    if (!messages.containsKey(message)) {
      return;
    }

    messages[message]?.forEach((token, subscriber) {
      subscriber(data);
    });
  }

  void emit(message, [data]) {
    Future.microtask(() {
      _deliver(message, data);
    });
  }

  String on(String message, EventCallback cb) {
    String token = '_token${++lastUid}';

    messages.putIfAbsent(message, () => {})[token] = cb;
    return token;
  }

  void cancelSubscribes() {
    messages.clear();
  }
}
