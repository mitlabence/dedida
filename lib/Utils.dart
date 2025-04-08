String dateTimeAsString(DateTime dt){
  String isoString = dt.toIso8601String();
  return isoString;
}

int shiftAndAddBit(int value, bool bit, {int mask = 0xFFFFFFFF}) {
  /// Shift the value to the left by one bit, add the bool bit as first bit,
  /// limit to mask bits (default: 32 bits).

  value = (value << 1);
  value = value | (bit ? 1 : 0);
  value = value & mask;

  return value;
}