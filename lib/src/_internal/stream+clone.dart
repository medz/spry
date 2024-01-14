// ignore_for_file: file_names

import 'dart:async';

extension Stream$Clone<T> on Stream<T> {
  /// Clone current stream, returns two streams.
  (Stream<T>, Stream<T>) clone() {
    final controller1 = StreamController<T>();
    final controller2 = StreamController<T>();

    listen(
      (event) {
        controller1.add(event);
        controller2.add(event);
      },
      onError: (error) {
        controller1.addError(error);
        controller2.addError(error);
      },
      onDone: () {
        controller1.close();
        controller2.close();
      },
    );

    return (controller1.stream, controller2.stream);
  }
}
