import 'package:enumerated/enumerated.dart';
import 'package:test/test.dart';

enum Test {
  one,
  two,
  three,
  four,
  five;
}

void main() {
  group('group basic tests', () {
    test('test creation', () {
      expect(EnumSet.of(Test.values, [Test.one, Test.two]), isA<EnumSet>());
      expect(EnumSet.allOf(Test.values), isA<EnumSet>());
      expect(EnumSet.noneOf(Test.values), isA<EnumSet>());
    });

    test('test length', () {
      expect(EnumSet.of(Test.values, [Test.one, Test.two]).length, 2);
      expect(EnumSet.allOf(Test.values).length, Test.values.length);
      expect(EnumSet.noneOf(Test.values).length, 0);
    });

    test('test elementAt', () {
      var set = EnumSet.of(Test.values, [Test.one, Test.two, Test.five]);
      expect(set.elementAt(0), Test.one);
      expect(set.elementAt(1), Test.two);
      expect(set.elementAt(2), Test.five);
    });

    test('test first and last', () {
      var set = EnumSet.of(Test.values, [Test.two, Test.five]);
      expect(set.first, Test.two);
      expect(set.last, Test.five);
      set.add(Test.one);
      expect(set.first, Test.one);
      expect(set.last, Test.five);

      expect(() => EnumSet.noneOf(Test.values).first, throwsA(isA<Error>()));
    });

    test('test isEmpty and isNotEmpty', () {
      var set = EnumSet.of(Test.values, [Test.two]);
      expect(set.isEmpty, isFalse);
      expect(set.isNotEmpty, isTrue);
      set = EnumSet.noneOf(Test.values);
      expect(set.isEmpty, isTrue);
      expect(set.isNotEmpty, isFalse);
    });

    test('test single', () {
      var set = EnumSet.of(Test.values, [Test.two]);
      expect(set.single, Test.two);
      set.add(Test.five);
      expect(() => set.single, throwsA(isA<String>()));
    });
  });

  group('group add/remove tests', () {
    test('test add', () {
      var set = EnumSet.noneOf(Test.values);
      expect(set.add(Test.three), isTrue);
      expect(set.single, Test.three);
      expect(set.length, 1);
      expect(set.add(Test.three), isFalse);
      expect(set.length, 1);
      expect(set.add(Test.two), isTrue);
      expect(set.length, 2);
    });

    test('test addAll', () {
      var set = EnumSet.noneOf(Test.values);
      set.addAll([Test.three, Test.two]);
      expect(set.length, 2);
      set.addAll([Test.three, Test.five]);
      expect(set.length, 3);
    });

    test('test remove', () {
      var set = EnumSet.allOf(Test.values);
      expect(set.remove(Test.three), isTrue);
      expect(set.length, Test.values.length - 1);
      expect(set.remove(Test.three), isFalse);
      expect(set.length, Test.values.length - 1);
      expect(set.remove(Test.two), isTrue);
      expect(set.length, Test.values.length - 2);
    });

    test('test removeAll', () {
      var set = EnumSet.allOf(Test.values);
      set.removeAll([Test.three, Test.two]);
      expect(set.length, Test.values.length - 2);
      set.removeAll([Test.three, Test.five]);
      expect(set.length, Test.values.length - 3);
    });
  });

  group('group iterator tests', () {
    test('test enum iterator', () {
      var set = EnumSet.allOf(Test.values);
      var enumIterator = set.iterator;
      var listIterator = Test.values.iterator;
      expect(() => enumIterator.current, throwsA(isA<Error>()));
      expect(() => listIterator.current, throwsA(isA<Error>()));
      while (listIterator.moveNext()) {
        expect(enumIterator.moveNext(), isTrue);
        expect(enumIterator.current, listIterator.current);
      }
      expect(enumIterator.moveNext(), isFalse);
    });
  });

  group('group set tests', () {
    test('test union', () {
      var set1 = EnumSet.of(Test.values, {Test.one, Test.two});
      var set2 = EnumSet.of(Test.values, {Test.three});
      expect(set1.union(set2).toList(), [Test.one, Test.two, Test.three]);
      expect(set2.union(set1).toList(), [Test.one, Test.two, Test.three]);
      set2.add(Test.one);
      expect(set1.union(set2).toList(), [Test.one, Test.two, Test.three]);
      expect(set2.union(set1).toList(), [Test.one, Test.two, Test.three]);
    });

    test('test difference', () {
      var set1 = EnumSet.of(Test.values, {Test.one, Test.two});
      var set2 = EnumSet.of(Test.values, {Test.one, Test.three});
      expect(set1.difference(set2).toList(), [Test.two]);
      expect(set2.difference(set1).toList(), [Test.three]);
    });

    test('test intersection', () {
      var set1 = EnumSet.of(Test.values, {Test.one, Test.two});
      var set2 = EnumSet.of(Test.values, {Test.three});
      expect(set1.intersection(set2).toList(), []);
      expect(set2.intersection(set1).toList(), []);
      set2.add(Test.one);
      expect(set1.intersection(set2).toList(), [Test.one]);
      expect(set2.intersection(set1).toList(), [Test.one]);
    });

    test('test complement', () {
      var set = EnumSet.of(Test.values, {Test.one, Test.two});
      expect(set.complement().toList(), [Test.three, Test.four, Test.five]);
    });
  });
}
