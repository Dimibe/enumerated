import 'package:enumerated/enumerated.dart';

enum Numbers {
  one,
  two,
  three,
  four,
  five;
}

void main() {
  var set1 = EnumSet<Numbers>.of(Numbers.values, {Numbers.one, Numbers.two});
  var set2 = {Numbers.three};
  var set1set2Union = set1.union(set2);
  print(set1set2Union);
  var set1complement = set1.complement();
  print(set1complement);
}
