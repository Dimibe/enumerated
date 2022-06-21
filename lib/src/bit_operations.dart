import 'package:meta/meta.dart';

/// Returns the base to 2 of [x], if [x] is power to 2.
///
/// Example:
/// ```
/// base(1) // = 0
/// base(2) // = 1
/// base(4) // = 2
/// base(8) // = 3
/// ```
///
/// For inputs which are not a power of 2 the output has no meaning.
@internal
int base(int x) {
  return x.bitLength - 1;
}

/// Returns the [n]th set bit in [x].
///
/// Example:
/// ```
/// ffsn(16 + 8 + 2, 2) // = 8
/// ffsn(16 + 8 + 2, 3) // = 16
/// ffsn(16 + 8, 2) // = 16
/// ```
@internal
int ffsn(int x, int n) {
  for (int i = 0; i < n; i++) {
    x &= x - 1;
  }
  return x & ~(x - 1);
}

/// Counts the bit which are set in [x].
/// Example:
/// ```
/// countBits(16 + 8 + 2 + 1) // = 4
/// countBits(16 + 8 + 1) // = 3
/// countBits(16 + 8 + 2 + 1) // = 1
/// ```
@internal
int countBits(int x) {
  int count = 0;
  while (x > 0) {
    count += x & 1;
    x = x >> 1;
  }
  return count;
}
