import 'dart:async';

import 'package:future_queue/future_queue.dart';
import 'package:test/test.dart';

void main() {
  late List<int?> returnedValues;
  late FutureQueue<int?> futureQueue;

  setUp(() {
    returnedValues = [];
  });

  tearDown(() {
    // Overwrite after test to prevent test errors.
    futureQueue = FutureQueue(seed: Future.value(null));
  });

  void _expectAppend({
    required int? previous,
    int? delay,
    String? throwA,
    int? value,
    int? timeLimit,
    int? completeTo,
    dynamic throws,
  }) {
    expect(
      futureQueue.append((previousResult) {
        expect(previousResult, previous);
        if (throwA != null) throw throwA;
        return Future<int>.delayed(
            Duration(milliseconds: delay!), () => value!);
      },
          timeLimit: timeLimit == null
              ? null
              : Duration(milliseconds: timeLimit)).then((value) {
        returnedValues.add(value);
        return value;
      }),
      completeTo != null ? completion(completeTo) : throwsA(throws),
    );
  }

  test('waits for the previous future executing the next one', () async {
    futureQueue = FutureQueue(seed: Future.value(null));

    _expectAppend(previous: null, delay: 300, value: 1, completeTo: 1);
    _expectAppend(previous: 1, delay: 200, value: 2, completeTo: 2);
    _expectAppend(previous: 2, delay: 100, value: 3, completeTo: 3);

    await futureQueue.wait();
    expect(returnedValues, [1, 2, 3]);
  });

  test('only returns errors to the responsible call to append', () async {
    futureQueue = FutureQueue<int?>(seed: Future.value(null));

    _expectAppend(previous: null, throwA: 'boom', value: 1, throws: 'boom');
    _expectAppend(previous: null, delay: 200, value: 2, completeTo: 2);

    await futureQueue.wait();
    expect(returnedValues, [2]);
  });

  test('times out due to global timeout', () async {
    futureQueue = FutureQueue<int?>(
      seed: Future.value(null),
      timeLimit: Duration(milliseconds: 250),
    );

    _expectAppend(previous: null, delay: 200, value: 1, completeTo: 1);
    _expectAppend(
        previous: 1, delay: 500, value: 2, throws: isA<TimeoutException>());
    _expectAppend(previous: null, delay: 100, value: 3, completeTo: 3);

    await futureQueue.wait();
    expect(returnedValues, [1, 3]);
  });

  test('times out due to append timeout', () async {
    futureQueue = FutureQueue<int?>(seed: Future.value(null));
    _expectAppend(previous: null, delay: 200, value: 1, completeTo: 1);
    _expectAppend(
      previous: 1,
      delay: 500,
      value: 2,
      timeLimit: 250,
      throws: isA<TimeoutException>(),
    );
    _expectAppend(previous: null, delay: 100, value: 3, completeTo: 3);

    await futureQueue.wait();
    expect(returnedValues, [1, 3]);
  });

  test('append timeout overrides global timeout', () async {
    futureQueue = FutureQueue<int?>(
      seed: Future.value(null),
      timeLimit: Duration(milliseconds: 250),
    );

    _expectAppend(previous: null, delay: 200, value: 1, completeTo: 1);
    _expectAppend(
      previous: 1,
      delay: 500,
      value: 2,
      timeLimit: 600,
      completeTo: 2,
    );
    _expectAppend(
      previous: 2,
      delay: 200,
      value: 3,
      timeLimit: 10,
      throws: isA<TimeoutException>(),
    );
    _expectAppend(previous: null, delay: 200, value: 4, completeTo: 4);

    await futureQueue.wait();
    expect(returnedValues, [1, 2, 4]);
  });

  test('wait() does not rethrow an error that occurred', () async {
    futureQueue = FutureQueue<int?>(seed: Future.value(null));
    _expectAppend(previous: null, throwA: 'boom', throws: 'boom');
    _expectAppend(previous: null, throwA: 'boom2', throws: 'boom2');
    await futureQueue.wait();
  });
}
