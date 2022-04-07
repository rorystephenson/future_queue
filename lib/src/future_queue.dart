class FutureQueue<T> {
  final Duration? _timeLimit;

  Future<T> _future;

  FutureQueue({
    required Future<T> seed,
    Duration? timeLimit,
  })  : _timeLimit = timeLimit,
        _future = Future.value(seed);

  Future<T> get future => _future;

  /// Adds the given [future] to queue. Note that the [previous] value will be
  /// null if the last operation caused an exception.
  Future<T> append(Future<T> Function(T? previous) future,
      {Duration? timeLimit}) {
    return _future = _future.then(
      (previous) => _nextValue(future, previous, timeLimit: timeLimit),
      onError: (_) => _nextValue(future, null, timeLimit: timeLimit),
    );
  }

  Future<T> _nextValue(Future<T> Function(T? previous) future, T? previous,
      {Duration? timeLimit}) {
    if (timeLimit != null || _timeLimit != null) {
      return future(previous).timeout(timeLimit ?? _timeLimit!);
    }
    return future(previous);
  }

  /// Waits for queued events to finish.
  Future<void> wait() async {
    try {
      await _future;
    } catch (_) {}
  }
}
