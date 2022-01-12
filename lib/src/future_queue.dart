import 'dart:async';

class FutureQueue<T> {
  final Duration? _timeLimit;

  Future<T?> _future;

  FutureQueue({Duration? timeLimit})
      : _timeLimit = timeLimit,
        _future = Future.value();

  FutureQueue.seeded(
    FutureOr<T> seed, {
    Duration? timeLimit,
  })  : _timeLimit = timeLimit,
        _future = Future.value(seed);

  Future<T?> get future => _future;

  /// Adds the given [future] to queue. Note that the [previous] value will be
  /// null if the last operation caused an exception.
  Future<T?> append(FutureOr<T> Function(T? previous) future,
      {Duration? timeLimit}) {
    return _future = _future.catchError((_) {}).then((previous) {
      if (timeLimit != null || _timeLimit != null) {
        return _withTimeout(future(previous), timeLimit ?? _timeLimit!);
      }
      return future(previous);
    });
  }

  Future<T> _withTimeout(FutureOr<T> future, Duration timeLimit) {
    return Future.value(future).timeout(timeLimit);
  }

  /// Waits for queued events to finish.
  Future<void> close() async {
    await _future;
  }
}
