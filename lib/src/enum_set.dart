import 'package:enumerated/src/const.dart';
import 'package:meta/meta.dart';

import 'bit_operations.dart';

/// An binary based [Set] implementation for [Enum]s.
///
/// A [EnumSet] can hold different values of one [Enum]. The implementation is
/// based on binary operations and stores all information in one or more [int]s.
/// Based on that some operations may be more efficient than in a regular `Set`
/// since bit operations are suffient for adding/removing and other operations.
///
/// Internally two different implementations are used. The default
/// implementation stores all values in one [int] and therefore can only contain
/// a certain number of values. The specific number of values depends on the
/// compilation of the code. If the total number of possible enum values is
/// greater than the number of bits one [int] can hold another implementation is
/// used where instead of one [int] a list of multiple [int]s is used which
/// makes it possible to store more values. The functionallity of this
/// implementation is the same as on the regular implementation.
///
/// The [EnumSet] provides the same method as an regular [Set]. In addition
/// there are methods to copy an `EnumSet`, fill an `EnumSet` with all possible
/// Enum values and a `complement` method, which returns a new `EnumSet` with
/// all enum values which are not included in the original set.
///
/// For creation a few factory methods for useful usage exists.
///
/// Examples:
///
/// ```
/// enum MyEnum { one, two, three; }
///
/// EnumSet.of(MyEnum.values, [MyEnum.one]);
/// EnumSet.noneOf(MyEnum.values);
/// EnumSet.allOf(MyEnum.values);
/// ```
///
/// **See also:**
/// * [Set] is the general interface of collection where each object can
/// occur only once.
@sealed
abstract class EnumSet<T extends Enum> extends Iterable<T> implements Set<T> {
  final List<T> _enumConstants;

  @protected
  List<T> get enumConstants => _enumConstants;

  EnumSet._(List<T> all) : _enumConstants = all;

  /// Creates a new [EnumSet] which holds the specified elements
  /// of a given [Enum].
  ///
  /// A list of all possible enum values must be provided to the factory
  /// constructor's parameter [all]. The provided elements must be passed to the
  /// parameter [elements] as an [Iterable].
  ///
  /// Example:
  /// ```
  /// enum MyEnum { one, two, three; }
  ///
  /// EnumSet.of(MyEnum.values, [MyEnum.one]);
  /// ```
  factory EnumSet.of(List<T> all, Iterable<T> elements) {
    if (all.length <= maxBitsInt) {
      return _BaseEnumSetImpl<T>.fromIterable(all, elements);
    } else {
      return _LargeEnumSetImpl.fromIterable(all, elements);
    }
  }

  /// Creates a new [EnumSet] which holds all elements of a given [Enum].
  ///
  /// A list of all possible enum values must be provided to the factory
  /// constructor's parameter [all].
  ///
  /// Example:
  /// ```
  /// enum MyEnum { one, two, three; }
  ///
  /// EnumSet.allOf(MyEnum.values);
  /// ```
  factory EnumSet.allOf(List<T> all) {
    return EnumSet.of(all, all);
  }

  /// Creates a new [EnumSet] which holds no elements of a given [Enum].
  ///
  /// A list of all possible enum values must be provided to the factory
  /// constructor's parameter [all].
  ///
  /// Example:
  /// ```
  /// enum MyEnum { one, two, three; }
  ///
  /// EnumSet.noneOf(MyEnum.values);
  /// ```
  factory EnumSet.noneOf(List<T> all) {
    return EnumSet.of(all, <T>[]);
  }

  /// Creates a new [EnumSet] which holds all elements which are not included
  /// in [other].
  ///
  /// Combining the new [EnumSet] and [other] will hold each element of the
  /// given [Enum].
  factory EnumSet.complementOf(EnumSet<T> other) {
    return EnumSet.of(other._enumConstants, other.complement());
  }

  /// Creates a new copy of the current [EnumSet] and returns it. The newly
  /// created set holds exactly the same data as [other].
  factory EnumSet.copy(EnumSet<T> other) {
    return EnumSet.of(other._enumConstants, other);
  }

  /// Fills the [EnumSet] with all values from the dependent [Enum].
  void fill();

  /// Returns a new [EnumSet] which holds all elements which are not included
  /// in the [EnumSet] on which the method is called.
  ///
  /// Combining both [EnumSet]s will hold each element of the given [Enum].
  EnumSet<T> complement();

  /// Creates a new copy of the current [EnumSet] and returns it. The newly
  /// created set holds exactly the same data as the one on which the method
  /// is called on.
  EnumSet<T> copy();

  /// Creates a new [EnumSet] with the elements of this that are not in [other].
  ///
  /// That is, the returned set contains all the elements of this [EnumSet] that
  /// are not elements of [other] according to `other.contains`.
  /// ```dart
  /// var set1 = EnumSet.of(Test.values, {Test.one, Test.two});
  /// var set2 = EnumSet.of(Test.values, {Test.one, Test.three});
  /// final differenceSet1 = set1.difference(set2);
  /// print(differenceSet1); // (Test.two)
  /// final differenceSet2 = set2.difference(set1);
  /// print(differenceSet2); // (Test.three)
  /// ```
  @override
  EnumSet<T> difference(Set<Object?> other);

  /// Creates a new [EnumSet] which contains all the elements of this set and
  /// [other].
  ///
  /// That is, the returned set contains all the elements of this [EnumSet] and
  /// all the elements of [other].
  /// ```dart
  /// var set1 = EnumSet.of(Test.values, {Test.one, Test.two});
  /// var set2 = EnumSet.of(Test.values, {Test.one, Test.three});
  /// final unionSet1 = set1.union(set2);
  /// print(unionSet1); // (Test.one, Test.two, Test.three)
  /// final unionSet2 = set2.union(set1);
  /// print(unionSet2); // (Test.one, Test.two, Test.three)
  /// ```
  @override
  EnumSet<T> union(Set<T> other);

  /// Creates a new [EnumSet] which is the intersection between this set and
  /// [other].
  ///
  /// That is, the returned set contains all the elements of this [EnumSet] that
  /// are also elements of [other] according to `other.contains`.
  /// ```dart
  /// var set1 = EnumSet.of(Test.values, {Test.one, Test.two});
  /// var set2 = EnumSet.of(Test.values, {Test.one, Test.three});
  /// final unionSet = set1.intersection(set2);
  /// print(unionSet); // (Test.one)
  /// ```
  @override
  EnumSet<T> intersection(Set<Object?> other);
}

/// Implementation of [EnumSet].
///
/// This implementation stores the values in an single [int].
class _BaseEnumSetImpl<T extends Enum> extends EnumSet<T> {
  int bitValue = 0;

  /// Creates an instance of [_BaseEnumSetImpl] with the given [elements].
  _BaseEnumSetImpl.fromIterable(super.all, Iterable<T> elements) : super._() {
    if (elements is _BaseEnumSetImpl<T>) {
      bitValue = elements.bitValue;
    } else {
      addAll(elements);
    }
  }

  /// Creates an instance of [_BaseEnumSetImpl] with the given [bitValue].
  _BaseEnumSetImpl.fromBitValue(super.all, this.bitValue) : super._();

  @override
  _BaseEnumSetImpl<T> copy() {
    return _BaseEnumSetImpl.fromBitValue(_enumConstants, bitValue);
  }

  _BaseEnumSetImpl<T> _copyEmpty() {
    return _BaseEnumSetImpl.fromBitValue(_enumConstants, 0);
  }

  @override
  EnumSet<T> complement() {
    var set = copy();
    set.bitValue = (~set.bitValue).toUnsigned(_enumConstants.length);
    return set;
  }

  @override
  bool add(T value) {
    if (contains(value)) {
      return false;
    }
    bitValue |= (1 << value.index);
    return true;
  }

  @override
  void addAll(Iterable<T>? elements) {
    if (elements is _BaseEnumSetImpl<T>) {
      bitValue |= elements.bitValue;
    } else {
      elements?.forEach(add);
    }
  }

  @override
  void fill() {
    bitValue = (~0).toUnsigned(_enumConstants.length);
  }

  @override
  bool contains(Object? value) {
    if (value is T) {
      return bitValue & (1 << value.index) != 0;
    }
    return false;
  }

  @override
  void clear() {
    bitValue = 0;
  }

  @override
  bool containsAll(Iterable<Object?> other) {
    if (other is _BaseEnumSetImpl<T>) {
      return bitValue & other.bitValue == bitValue;
    }
    return other.every(contains);
  }

  @override
  EnumSet<T> difference(Set<Object?> other) {
    var set = _copyEmpty();
    if (other is _BaseEnumSetImpl<T>) {
      set.bitValue = bitValue & (bitValue ^ other.bitValue);
    } else {
      for (var value in this) {
        if (!other.contains(value)) {
          set.add(value);
        }
      }
    }
    return set;
  }

  @override
  EnumSet<T> intersection(Set<Object?> other) {
    var set = _copyEmpty();
    if (other is _BaseEnumSetImpl<T>) {
      set.bitValue = bitValue & other.bitValue;
    } else {
      for (var value in other) {
        if (contains(value)) {
          set.add(value as T);
        }
      }
    }
    return set;
  }

  @override
  EnumSet<T> union(Set<T> other) {
    var set = copy();
    if (other is _BaseEnumSetImpl<T>) {
      set.bitValue = bitValue | other.bitValue;
    } else {
      set.addAll(other);
    }
    print(set.bitValue);
    return set;
  }

  @override
  Iterator<T> get iterator => EnumIterator._(_enumConstants.toList(), bitValue);

  @override
  T? lookup(Object? object) {
    if (contains(object)) return object as T;
    return null;
  }

  @override
  bool remove(Object? value) {
    if (contains(value) && value is T) {
      bitValue ^= (1 << value.index);
      return true;
    }
    return false;
  }

  @override
  void removeAll(Iterable<Object?> elements) {
    if (elements is _BaseEnumSetImpl<T>) {
      bitValue &= ~elements.bitValue;
    } else {
      elements.forEach(remove);
    }
  }

  @override
  void removeWhere(bool Function(T element) test) {
    for (T element in this) {
      if (test(element)) remove(element);
    }
  }

  @override
  void retainAll(Iterable<Object?> elements) {
    if (elements is _BaseEnumSetImpl<T>) {
      bitValue = elements.bitValue;
    } else {
      for (T element in this) {
        if (!elements.contains(element)) remove(element);
      }
    }
  }

  @override
  void retainWhere(bool Function(T element) test) {
    for (T element in this) {
      if (!test(element)) remove(element);
    }
  }

  @override
  Set<R> cast<R>() => Iterable.castFrom<T, R>(this).toSet();

  @override
  T elementAt(int index) => _enumConstants[base(ffsn(bitValue, index))];

  @override
  T get first => _enumConstants[base(bitValue & -bitValue)];

  @override
  bool get isEmpty => bitValue == 0;

  @override
  bool get isNotEmpty => bitValue != 0;

  @override
  int get length => countBits(bitValue);

  @override
  T get single {
    if (bitValue != 0 && bitValue & (bitValue - 1) == 0) {
      return _enumConstants[base(bitValue)];
    }
    throw "Bad state: Too many elements";
  }
}

class EnumIterator<T extends Enum> extends Iterator<T> {
  final List<T> _elements;
  int _remaining;
  int _current = 0;

  EnumIterator._(this._elements, this._remaining);

  @override
  T get current => _elements[base(_current)];

  @override
  bool moveNext() {
    if (_remaining == 0) return false;
    _current = _remaining & -_remaining;
    _remaining ^= _current;
    return true;
  }
}
