import 'dart:async';

import 'package:future_queue/future_queue.dart';
import 'package:test/test.dart';

void main() {
  List<int> returnedValues;

  setUp(() {
    returnedValues = [];
  });

  void _expectAppend(
    FutureQueue futureQueue, {
    int delay,
    String throwA,
    int value,
    int timeLimit,
    int completeTo,
    dynamic throws,
  }) {
    expect(
      futureQueue
          .append(
              () => throwA != null
                  ? throw throwA
                  : Future<int>.delayed(
                      Duration(milliseconds: delay), () => value),
              timeLimit:
                  timeLimit == null ? null : Duration(milliseconds: timeLimit))
          .then((value) {
        returnedValues.add(value);
        return value;
      }),
      completeTo != null ? completion(completeTo) : throwsA(throws),
    );
  }

  test('waits for the previous future executing the next one', () async {
    final futureQueue = FutureQueue<int>();

    _expectAppend(futureQueue, delay: 300, value: 1, completeTo: 1);
    _expectAppend(futureQueue, delay: 200, value: 2, completeTo: 2);
    _expectAppend(futureQueue, delay: 100, value: 3, completeTo: 3);

    await futureQueue.close();
    expect(returnedValues, [1, 2, 3]);
  });

  test('only returns errors to the responsible call to append', () async {
    final futureQueue = FutureQueue<int>();

    _expectAppend(futureQueue, throwA: 'boom', value: 1, throws: 'boom');
    _expectAppend(futureQueue, delay: 200, value: 2, completeTo: 2);

    await futureQueue.close();
    expect(returnedValues, [2]);
  });

  test('times out due to global timeout', () async {
    final futureQueue = FutureQueue<int>(
      timeLimit: Duration(milliseconds: 250),
    );

    _expectAppend(futureQueue, delay: 200, value: 1, completeTo: 1);
    _expectAppend(futureQueue,
        delay: 500, value: 2, throws: isA<TimeoutException>());
    _expectAppend(futureQueue, delay: 100, value: 3, completeTo: 3);

    await futureQueue.close();
    expect(returnedValues, [1, 3]);
  });

  test('times out due to append timeout', () async {
    final futureQueue = FutureQueue<int>();
    _expectAppend(futureQueue, delay: 200, value: 1, completeTo: 1);
    _expectAppend(
      futureQueue,
      delay: 500,
      value: 2,
      timeLimit: 250,
      throws: isA<TimeoutException>(),
    );
    _expectAppend(futureQueue, delay: 100, value: 3, completeTo: 3);

    await futureQueue.close();
    expect(returnedValues, [1, 3]);
  });

  test('append timeout overrides global timeout', () async {
    final futureQueue = FutureQueue<int>(
      timeLimit: Duration(milliseconds: 250),
    );

    _expectAppend(futureQueue, delay: 200, value: 1, completeTo: 1);
    _expectAppend(
      futureQueue,
      delay: 500,
      value: 2,
      timeLimit: 600,
      completeTo: 2,
    );
    _expectAppend(
      futureQueue,
      delay: 200,
      value: 3,
      timeLimit: 10,
      throws: isA<TimeoutException>(),
    );
    _expectAppend(futureQueue, delay: 200, value: 4, completeTo: 4);

    await futureQueue.close();
    expect(returnedValues, [1, 2, 4]);
  });
}
