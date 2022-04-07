import 'dart:async';

class FutureQueue<T> {
  final Duration? _timeLimit;

  Future<T> _future;

  FutureQueue({
    required FutureOr<T> seed,
    Duration? timeLimit,
  })  : _timeLimit = timeLimit,
        _future = Future.value(seed);

  Future<T> get future => _future;

  /// Adds the given [future] to queue. Note that the [previous] value will be
  /// null if the last operation caused an exception.
  Future<T> append(FutureOr<T> Function(T? previous) future,
      {Duration? timeLimit}) {
    return _future = _future.then(
      (previous) => _nextValue(future, previous, timeLimit: timeLimit),
      onError: (_) => _nextValue(future, null, timeLimit: timeLimit),
    );
  }

  FutureOr<T> _nextValue(FutureOr<T> Function(T? previous) future, T? previous,
      {Duration? timeLimit}) {
    if (timeLimit != null || _timeLimit != null) {
      return _withTimeout(future(previous), timeLimit ?? _timeLimit!);
    }
    return future(previous);
  }

  Future<T> _withTimeout(FutureOr<T> future, Duration timeLimit) {
    return Future.value(future).timeout(timeLimit);
  }

  /// Waits for queued events to finish.
  Future<void> close() async {
    await _future;
  }
}
