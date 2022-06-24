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
  var set1 = EnumSet.of(Test.values, {Test.one, Test.two});
  var set2 = {Test.three};
  print(set1.union(set2).toList());
  print(set2.union(set1).toList());
  print(set);
}
