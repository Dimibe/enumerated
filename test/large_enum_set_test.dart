import 'package:enumerated/enumerated.dart';
import 'package:test/test.dart';

enum Test {
  one,
  two,
  three,
  four,
  five,
  six,
  seven,
  eight,
  nine,
  ten,
  eleven,
  twelve,
  thirteen,
  fourteen,
  fiveteen,
  sixteen,
  seventeen,
  eightteen,
  nineteen,
  twenty,
  twentyone,
  twentytwo,
  twentythree,
  twentyfour,
  twentyfive,
  twentysix,
  twentyseven,
  twentyeight,
  twentynine,
  thirty,
  thiryone,
  thirtytwo,
  thritythree,
  thrityfour,
  thirtyfive,
  thirtysix,
  thirtyseven,
  thirtyeight,
  thirtynine,
  fourty;
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
      var set = EnumSet.of(Test.values, [
        Test.one,
        Test.thirtytwo,
        Test.thritythree,
        Test.fourty,
      ]);
      expect(set.elementAt(0), Test.one);
      expect(set.elementAt(1), Test.thirtytwo);
      expect(set.elementAt(2), Test.thritythree);
      expect(set.elementAt(3), Test.fourty);
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
      expect(set.add(Test.thritythree), isTrue);
      expect(set.single, Test.thritythree);
      expect(set.length, 1);
      expect(set.add(Test.thritythree), isFalse);
      expect(set.length, 1);
      expect(set.add(Test.two), isTrue);
      expect(set.length, 2);
      expect(set.add(Test.fourty), isTrue);
      expect(set.length, 3);
    });

    test('test addAll from EnumSet', () {
      var set = EnumSet.noneOf(Test.values);
      set.addAll(EnumSet<Test>.of(Test.values, [Test.three, Test.two]));
      expect(set.length, 2);
      set.addAll(EnumSet<Test>.of(Test.values, [Test.three, Test.five]));
      expect(set.length, 3);
    });

    test('test addAll from other iterable', () {
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

    test('test removeAll with EnumSet', () {
      var set = EnumSet.allOf(Test.values);
      set.removeAll(EnumSet<Test>.of(Test.values, [Test.three, Test.two]));
      expect(set.length, Test.values.length - 2);
      expect(set.containsAll([Test.three, Test.two]), isFalse);
      set.removeAll(EnumSet<Test>.of(Test.values, [Test.three, Test.five]));
      expect(set.length, Test.values.length - 3);
      expect(set.contains(Test.five), isFalse);
      set.removeAll(EnumSet<Test>.of(Test.values, [Test.one, Test.four]));
      expect(set.length, Test.values.length - 5);
    });

    test('test removeAll with other iterable', () {
      var set = EnumSet.allOf(Test.values);
      set.removeAll([Test.three, Test.two]);
      expect(set.length, Test.values.length - 2);
      expect(set.containsAll([Test.three, Test.two]), isFalse);
      set.removeAll([Test.three, Test.five]);
      expect(set.length, Test.values.length - 3);
      expect(set.contains(Test.five), isFalse);
      set.removeAll([Test.one, Test.four]);
      expect(set.length, Test.values.length - 5);
    });

    test('test fill', () {
      var set = EnumSet.noneOf(Test.values);
      expect(set.length, 0);
      set.fill();
      expect(set.length, Test.values.length);
      expect(set.toList().length, Test.values.length);
    });

    test('test contains ', () {
      var set = EnumSet.of(Test.values, [Test.two, Test.fourty]);
      expect(set.contains(Test.one), isFalse);
      expect(set.contains(Test.two), isTrue);
      expect(set.contains(Test.fourty), isTrue);
    });

    test('test contains all with enum set', () {
      var set = EnumSet.of(Test.values, [Test.two, Test.fourty]);
      var other = EnumSet.of(Test.values, [Test.fourty]);
      expect(set.containsAll(other), isTrue);
      other = EnumSet.of(Test.values, [Test.one]);
      expect(set.containsAll(other), isFalse);
      other = EnumSet.of(Test.values, [Test.one, Test.fourty]);
      expect(set.containsAll(other), isFalse);
      other = EnumSet.of(Test.values, [Test.two, Test.fourty]);
      expect(set.containsAll(other), isTrue);
    });

    test('test contains all with iterable', () {
      var set = EnumSet.of(Test.values, [Test.two, Test.fourty]);
      expect(set.containsAll([Test.fourty]), isTrue);
      expect(set.containsAll([Test.one]), isFalse);
      expect(set.containsAll([Test.one, Test.fourty]), isFalse);
      expect(set.containsAll([Test.two, Test.fourty]), isTrue);
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
    test('test union between EnumSets', () {
      var set1 = EnumSet.of(Test.values, {Test.one, Test.two});
      var set2 = EnumSet.of(Test.values, {Test.three});
      expect(set1.union(set2).toList(), [Test.one, Test.two, Test.three]);
      expect(set2.union(set1).toList(), [Test.one, Test.two, Test.three]);
      set2.add(Test.one);
      expect(set1.union(set2).toList(), [Test.one, Test.two, Test.three]);
      expect(set2.union(set1).toList(), [Test.one, Test.two, Test.three]);
    });

    test('test union with iterable', () {
      var set1 = EnumSet.of(Test.values, {Test.one, Test.two});
      var set2 = {Test.three};
      expect(set1.union(set2).toList(), [Test.one, Test.two, Test.three]);
      expect(set2.union(set1).toList(), [Test.three, Test.one, Test.two]);
      set2.add(Test.one);
      expect(set1.union(set2).toList(), [Test.one, Test.two, Test.three]);
      expect(set2.union(set1).toList(), [Test.three, Test.one, Test.two]);
    });

    test('test difference between EnumSets', () {
      var set1 = EnumSet.of(Test.values, {Test.one, Test.two});
      var set2 = EnumSet.of(Test.values, {Test.one, Test.three});
      expect(set1.difference(set2).toList(), [Test.two]);
      expect(set2.difference(set1).toList(), [Test.three]);
    });

    test('test difference with iterable', () {
      var set1 = EnumSet.of(Test.values, {Test.one, Test.two});
      var set2 = <Test>{Test.one, Test.three};
      expect(set1.difference(set2).toList(), [Test.two]);
      expect(set2.difference(set1).toList(), [Test.three]);
    });

    test('test intersection between EnumSets', () {
      var set1 = EnumSet.of(Test.values, {Test.one, Test.two});
      var set2 = EnumSet.of(Test.values, {Test.three});
      expect(set1.intersection(set2).toList(), []);
      expect(set2.intersection(set1).toList(), []);
      set2.add(Test.one);
      expect(set1.intersection(set2).toList(), [Test.one]);
      expect(set2.intersection(set1).toList(), [Test.one]);
    });

    test('test intersection with iterable', () {
      var set1 = EnumSet.of(Test.values, {Test.one, Test.two});
      var set2 = {Test.three};
      expect(set1.intersection(set2).toList(), []);
      expect(set2.intersection(set1).toList(), []);
      set2.add(Test.one);
      expect(set1.intersection(set2).toList(), [Test.one]);
      expect(set2.intersection(set1).toList(), [Test.one]);
    });

    test('test complement', () {
      var set = EnumSet.of(Test.values, {Test.one, Test.two, Test.thirtyfive});
      var comp = set.complement();
      expect(comp.contains(Test.fourty), isTrue);
      expect(comp.contains(Test.one), isFalse);
      expect(comp.contains(Test.two), isFalse);
      expect(comp.contains(Test.thirtyfive), isFalse);
    });
  });
}
