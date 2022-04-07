## [1.1.0] - 07/04/22

* BREAKING: close() is renamed to wait() since it does not actually close the
            FutureQueue. It also now catches any previously thrown errors to
            prevent them from being rethrown.
* BREAKING: Removed FutureOr as it only complicated the API and synchronous
            functions can easily be converted to futures in the unlikely case
            that this is needed.

## [1.0.0+1] - 07/04/22

* Update README

## [1.0.0] - 07/04/22

* BREAKING: FutureQueue now allows non-null returning futures. This means that
            you must explicitly declare nullable FutureQueues e.g.
            FutureQueue<int?>. For this reason all FutureQueues must now be
            seeded.

## [0.2.0] - 12/01/22

* Provide the previous value to an appended future.

## [0.1.0] - 14/03/21

* Null-safe release.

## [0.0.1] - 14/03/21

* Initial release.
