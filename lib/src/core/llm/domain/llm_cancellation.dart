import 'dart:async';

class LlmCancellationException implements Exception {
  const LlmCancellationException([this.message = 'LLM request was cancelled.']);

  final String message;

  @override
  String toString() => message;
}

class LlmCancellationToken {
  final _controller = StreamController<void>.broadcast();
  bool _isCancelled = false;

  bool get isCancelled => _isCancelled;

  Stream<void> get onCancel => _controller.stream;

  void cancel() {
    if (_isCancelled) {
      return;
    }
    _isCancelled = true;
    _controller.add(null);
  }

  void throwIfCancelled() {
    if (_isCancelled) {
      throw const LlmCancellationException();
    }
  }

  Future<void> dispose() => _controller.close();
}
