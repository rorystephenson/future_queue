# `future_queue`

Dart package which provides sequential future execution with return values.

## How it works

Here is a code example which demonstrates how futures are queued:

```dart
final futureQueue = FutureQueue<int>();

final result1 = futureQueue.append(
  () => Future.delayed(Duration(seconds: 5), () => 1),
);
final result2 = futureQueue.append(
  () => Future.delayed(Duration(seconds: 1), () => 2),
);

print('result1: ${await result1}');
print('result2: ${await result2}');
```

Will print:

```
1
2
```

Even though the first future takes 4 seconds longer than the second future.

## Error handling

If the future throws an exception it can be caught, as usual, by chaining a `catchError` on the Future returned by FutureBuilder's `append`.
