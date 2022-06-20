/// Support for doing something awesome.
///
/// More dartdocs go here.
library enumerated;

//export 'src/enumerated_base.dart' show EnumSet;

void main(List<String> args) {
  int bit = 0;
  bit |= (1 << 0);
  print(bit);
  print((1 << 3));
  print(bit & (1 << 3));
}
