import 'dart:async';

class TestStream {
  static final TestStream _instance = TestStream._();

  TestStream._();

  factory TestStream() {
    return _instance;
  }

  int i = 0;
  final StreamController<int?> _testStreamController =
      StreamController<int?>.broadcast();

  Stream<int?> get stream => _testStreamController.stream;

  int f() {
    i++; // Increment the integer
    _testStreamController.add(i); // Add the incremented value to the stream
    return i; // Return the incremented value
  }

  void dispose() {
    _testStreamController.close();
  }
}
