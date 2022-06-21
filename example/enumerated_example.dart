import 'package:enumerated/enumerated.dart';

enum Test {
  one,
  two,
  three,
  four,
  five;
}

void main() {
  var set = EnumSet.of(Test.values, [Test.one, Test.two, Test.five]);
}
