import 'dart:async';

class FutureQueue<T> {
  final Duration _timeLimit;

  Future<T> _future;

  FutureQueue({Duration timeLimit})
      : _timeLimit = timeLimit,
        _future = Future.value();

  FutureQueue.seeded(
    FutureOr<T> seed, {
    Duration timeLimit,
  })  : _timeLimit = timeLimit,
        _future = Future.value(seed);

  Future<T> get future => _future;

  Future<T> append(FutureOr<T> Function() future, {Duration timeLimit}) {
    return _future = _future.catchError((_) => null).then((_) {
      if (timeLimit != null || _timeLimit != null) {
        return _withTimeout(future, timeLimit ?? _timeLimit);
      }
      return future();
    });
  }

  Future<T> _withTimeout(FutureOr<T> Function() future, Duration timeLimit) {
    return Future.value(future()).timeout(timeLimit);
  }

  /// Waits for queued events to finish.
  Future<void> close() async {
    await _future;
  }
}
