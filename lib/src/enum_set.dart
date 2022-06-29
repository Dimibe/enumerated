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
/// enum Numbers { one, two, three; }
///
/// EnumSet<Numbers>.of(Numbers.values, [Numbers.one]);
/// EnumSet<Numbers>.noneOf(Numbers.values);
/// EnumSet<Numbers>.allOf(Numbers.values);
/// ```
///
/// **See also:**
/// * [Set] is the general interface of collection where each object can
/// occur only once.
@sealed
abstract class EnumSet<T extends Enum> extends Iterable<T> implements Set<T> {
  final List<T> _enumConstants;

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
  /// enum Numbers { one, two, three; }
  ///
  /// EnumSet<Numbers>.of(Numbers.values, [Numbers.one]);
  /// ```
  factory EnumSet.of(List<T> all, Iterable<T> elements) {
    if (all.length <= maxBitsInt) {
      return _BaseEnumSetImpl<T>(all, elements);
    } else {
      return _LargeEnumSetImpl<T>(all, elements);
    }
  }

  /// Creates a new [EnumSet] which holds all elements of a given [Enum].
  ///
  /// A list of all possible enum values must be provided to the factory
  /// constructor's parameter [all].
  ///
  /// Example:
  /// ```
  /// enum Numbers { one, two, three; }
  ///
  /// EnumSet<Numbers>.allOf(Numbers.values);
  /// ```
  factory EnumSet.allOf(List<T> all) => EnumSet<T>.of(all, all);

  /// Creates a new [EnumSet] which holds no elements of a given [Enum].
  ///
  /// A list of all possible enum values must be provided to the factory
  /// constructor's parameter [all].
  ///
  /// Example:
  /// ```
  /// enum Numbers { one, two, three; }
  ///
  /// EnumSet<Numbers>.noneOf(Numbers.values);
  /// ```
  factory EnumSet.noneOf(List<T> all) => EnumSet<T>.of(all, <T>[]);

  /// Creates a new [EnumSet] which holds all elements which are not included
  /// in [other].
  ///
  /// Combining the new [EnumSet] and [other] will hold each element of the
  /// given [Enum].
  factory EnumSet.complementOf(EnumSet<T> other) =>
      EnumSet<T>.of(other._enumConstants, other.complement());

  /// Creates a new copy of the current [EnumSet] and returns it. The newly
  /// created set holds exactly the same data as [other].
  factory EnumSet.copy(EnumSet<T> other) =>
      EnumSet<T>.of(other._enumConstants, other);

  /// Compares the EnumSet with [other] and checks if both contains the same
  /// values.
  ///
  /// ```dart
  /// var set1 = EnumSet<Numbers>.of(Numbers.values, [Numbers.one]);
  /// var set2 = EnumSet<Numbers>.of(Numbers.values, [Numbers.two]);
  /// var set3 = EnumSet<Numbers>.of(Numbers.values, [Numbers.two]);
  ///
  /// set1.equals(set2); // false
  /// set2.equals(set3); // true
  /// set1.equals({Numbers.one}); // true
  /// ```
  bool equals(Set<T> other) {
    if (identical(this, other)) {
      return true;
    }
    if (length != other.length) {
      return false;
    }
    for (var v in this) {
      if (!other.contains(v)) {
        return false;
      }
    }
    return true;
  }

  /// Fills the [EnumSet] with all values from the dependent [Enum].
  /// This method is equivalent to [addAll] with a list of the enums universe.
  ///
  /// ```
  /// enum Numbers {one, two, three;}
  ///
  /// var set = EnumSet<Numbers>.of(Numbers.values, [Numbers.one]);
  ///
  /// print(set); // (Numbers.one)
  /// set.fill();
  /// print(set); // (Numbers.one, Numbers.two, Numbers.three)
  /// ```
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

  /// Adds [value] to the set.
  ///
  /// Returns `true` if [value] (or an equal value) was not yet in the set.
  /// Otherwise returns `false` and the set is not changed.
  ///
  /// ```dart
  /// enum Numbers {one, two, three;}
  ///
  /// var set = EnumSet<Numbers>.of(Numbers.values, [Numbers.two]);
  ///
  /// var added = set.add(Numbers.one);
  /// print(added); // true
  ///
  /// added = set.add(Numbers.two);
  /// print(added); // false
  ///
  /// print(set); // (Numbers.one, Numbers.two)
  /// ```
  @override
  bool add(T value);

  /// Adds all [elements] to this set.
  ///
  /// Equivalent to adding each element in [elements] using [add],
  /// but some collections may be able to optimize it.
  ///
  /// ```dart
  /// enum Numbers {one, two, three;}
  ///
  /// var set = EnumSet<Numbers>.of(Numbers.values, [Numbers.two]);
  ///
  /// set.addAll({Numbers.one, Numbers.two});
  /// print(set); // (Numbers.one, Numbers.two)
  ///
  /// set.addAll(EnumSet<Numbers>.of(Numbers.values, [Numbers.three]));
  /// print(set); // (Numbers.one, Numbers.two, Numbers.three)
  /// ```
  @override
  void addAll(Iterable<T> elements);

  /// Removes [value] from the set.
  ///
  /// Returns `true` if [value] was in the set, and `false` if not.
  /// The method has no effect if [value] was not in the set.
  ///
  /// ```dart
  /// enum Numbers {one, two, three;}
  ///
  /// var set = EnumSet<Numbers>.of(Numbers.values, [Numbers.two, Numbers.three]);
  ///
  /// final didRemove2 = set.remove(Numbers.two); // true
  /// final didRemove1 = set.remove(Numbers.one); // false
  ///
  /// print(set); // (Numbers.three)
  /// ```
  @override
  bool remove(Object? value);

  /// Removes each element of [elements] from this set.
  ///
  /// ```dart
  /// enum Numbers {one, two, three;}
  ///
  /// var set = EnumSet<Numbers>.of(Numbers.values, [Numbers.two, Numbers.three]);
  ///
  /// set.removeAll({Numbers.one, Numbers.two});
  /// print(set); // (Numbers.three)
  /// ```
  @override
  void removeAll(Iterable<Object?> elements);

  /// Removes all elements of this set that are not elements in [elements].
  ///
  /// Checks for each element of [elements] whether there is an element in this
  /// set that is equal to it (according to `this.contains`), and if so, the
  /// equal element in this set is retained, and elements that are not equal
  /// to any element in [elements] are removed.
  ///
  /// ```dart
  /// enum Numbers {one, two, three;}
  ///
  /// var set = EnumSet<Numbers>.of(Numbers.values, [Numbers.two, Numbers.three]);
  /// set.retainAll({Numbers.one, Numbers.two});
  /// print(set); // (Numbers.two)
  /// ```
  @override
  void retainAll(Iterable<Object?> elements);

  /// Removes all elements from the set.
  ///
  /// ```dart
  /// enum Numbers {one, two, three;}
  ///
  /// var set = EnumSet<Numbers>.of(Numbers.values, [Numbers.two]);
  ///
  /// set.clear(); // ()
  /// ```
  @override
  void clear();

  /// Whether [value] is in the set.
  ///
  /// ```dart
  /// enum Numbers {one, two, three;}
  ///
  /// var set = EnumSet<Numbers>.of(Numbers.values, [Numbers.one]);
  ///
  /// final contains1 = set.contains(Test.one); // true
  /// final contains2 = set.contains(Test.two); // false
  /// ```
  @override
  bool contains(Object? value);

  /// Whether this set contains all the elements of [other].
  ///
  /// ```dart
  /// enum Numbers {one, two, three;}
  ///
  /// var set = EnumSet<Numbers>.of(Numbers.values, [Numbers.one, Numbers.two]);
  ///
  /// final contains12 = set.containsAll({Numbers.one, Numbers.two});
  /// print(contains12); // true
  /// final contains13 = set.containsAll({Numbers.one, Numbers.three});
  /// print(contains13); // false
  /// ```
  @override
  bool containsAll(Iterable<Object?> other);

  /// Creates a new [EnumSet] with the elements of this that are not in [other].
  ///
  /// That is, the returned set contains all the elements of this [EnumSet] that
  /// are not elements of [other] according to `other.contains`.
  ///
  /// ```dart
  /// enum Numbers { one, two, three; }
  ///
  /// var set1 = EnumSet.of(Numbers.values, {Numbers.one, Numbers.two});
  /// var set2 = EnumSet.of(Numbers.values, {Numbers.one, Numbers.three});
  ///
  /// final differenceSet1 = set1.difference(set2);
  /// print(differenceSet1); // (Numbers.two)
  ///
  /// final differenceSet2 = set2.difference(set1);
  /// print(differenceSet2); // (Numbers.three)
  /// ```
  @override
  EnumSet<T> difference(Set<Object?> other);

  /// Creates a new [EnumSet] which contains all the elements of this set and
  /// [other].
  ///
  /// That is, the returned set contains all the elements of this [EnumSet] and
  /// all the elements of [other].
  ///
  /// ```dart
  /// enum Numbers { one, two, three; }
  ///
  /// var set1 = EnumSet.of(Numbers.values, {Numbers.one, Numbers.two});
  /// var set2 = EnumSet.of(Numbers.values, {Numbers.one, Numbers.three});
  ///
  /// final unionSet1 = set1.union(set2);
  /// print(unionSet1); // (Numbers.one, Numbers.two, Numbers.three)
  ///
  /// final unionSet2 = set2.union(set1);
  /// print(unionSet2); // (Numbers.one, Numbers.two, Numbers.three)
  /// ```
  @override
  EnumSet<T> union(Set<T> other);

  /// Creates a new [EnumSet] which is the intersection between this set and
  /// [other].
  ///
  /// That is, the returned set contains all the elements of this [EnumSet] that
  /// are also elements of [other] according to `other.contains`.
  ///
  /// ```dart
  /// enum Numbers { one, two, three; }
  ///
  /// var set1 = EnumSet<Numbers>.of(Numbers.values, {Numbers.one, Numbers.two});
  /// var set2 = EnumSet<Numbers>.of(Numbers.values, {Numbers.one, Numbers.three});
  ///
  /// final unionSet = set1.intersection(set2);
  /// print(unionSet); // (Numbers.one)
  /// ```
  @override
  EnumSet<T> intersection(Set<Object?> other);

  @override
  Set<R> cast<R>() => Iterable.castFrom<T, R>(this).toSet();

  /// If an object equal to [object] is in the set, return it.
  ///
  /// Checks whether [object] is in the set, like [contains], and if so,
  /// returns the object in the set, otherwise returns `null`.
  ///
  /// If the equality relation used by the set is not identity,
  /// then the returned object may not be *identical* to [object].
  /// Some set implementations may not be able to implement this method.
  /// If the [contains] method is computed,
  /// rather than being based on an actual object instance,
  /// then there may not be a specific object instance representing the
  /// set element.
  ///
  /// ```dart
  /// enum Numbers { one, two, three; }
  ///
  /// var set1 = EnumSet<Numbers>.of(Numbers.values, {Numbers.one, Numbers.three});
  ///
  /// final contains1 = set.lookup(Numbers.one);
  /// print(contains1); // Numbers.one
  ///
  /// final contains2 = set.lookup(Numbers.two);
  /// print(contains2); // null
  /// ```
  @override
  T? lookup(Object? object) => contains(object) ? object as T : null;

  /// Removes all elements of this set that satisfy [test].
  ///
  /// ```dart
  /// enum Numbers { one, two, three; }
  ///
  /// var set1 = EnumSet<Numbers>.of(Numbers.values, {Numbers.one, Numbers.two});
  /// set1.removeWhere((element) => element.index < 1);
  ///
  /// print(set1); // (Numbers.two)
  /// ```
  @override
  void removeWhere(bool Function(T element) test) {
    for (var element in this) {
      if (test(element)) remove(element);
    }
  }

  /// Removes all elements of this set that fail to satisfy [test].
  ///
  /// ```dart
  /// enum Numbers { one, two, three; }
  ///
  /// var set1 = EnumSet<Numbers>.of(Numbers.values, {Numbers.one, Numbers.two});
  /// set1.retainWhere((element) => element.index >= 1);
  ///
  /// print(set1); // (Numbers.two)
  /// ```
  @override
  void retainWhere(bool Function(T element) test) {
    for (T element in this) {
      if (!test(element)) remove(element);
    }
  }
}

/// Implementation of [EnumSet].
///
/// This implementation stores the values in an single [int].
class _BaseEnumSetImpl<T extends Enum> extends EnumSet<T> {
  int bitValue = 0;

  /// Creates an instance of [_BaseEnumSetImpl] with the given [elements].
  _BaseEnumSetImpl(super.all, Iterable<T> elements) : super._() {
    if (elements is _BaseEnumSetImpl<T>) {
      bitValue = elements.bitValue;
    } else {
      addAll(elements);
    }
  }

  @override
  _BaseEnumSetImpl<T> copy() => _BaseEnumSetImpl(_enumConstants, this);

  _BaseEnumSetImpl<T> _copyEmpty() => _BaseEnumSetImpl(_enumConstants, []);

  @override
  EnumSet<T> complement() {
    var set = _copyEmpty();
    set.bitValue = (~bitValue).toUnsigned(_enumConstants.length);
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
  void fill() => bitValue = (~0).toUnsigned(_enumConstants.length);

  @override
  bool contains(Object? value) {
    if (value is T) {
      return bitValue & (1 << value.index) != 0;
    }
    return false;
  }

  @override
  void clear() => bitValue = 0;

  @override
  bool containsAll(Iterable<Object?> other) {
    if (other is _BaseEnumSetImpl<T>) {
      return ~bitValue & other.bitValue == 0;
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
  bool equals(Set<T> other) {
    if (other is _BaseEnumSetImpl<T>) {
      return bitValue == other.bitValue;
    }
    return super.equals(other);
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
    return set;
  }

  @override
  Iterator<T> get iterator =>
      _BaseEnumIterator(_enumConstants.toList(), bitValue);

  @override
  bool remove(Object? value) {
    if (value is T && contains(value)) {
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
  void retainAll(Iterable<Object?> elements) {
    if (elements is _BaseEnumSetImpl<T>) {
      bitValue &= elements.bitValue;
    } else {
      for (var element in this) {
        if (!elements.contains(element)) remove(element);
      }
    }
  }

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
    if (isEmpty) throw "Bad state: No elements";
    if (bitValue & (bitValue - 1) == 0) {
      return _enumConstants[base(bitValue)];
    }
    throw "Bad state: Too many elements";
  }
}

class _BaseEnumIterator<T extends Enum> extends Iterator<T> {
  final List<T> _elements;
  int _remaining;
  int _current = 0;

  _BaseEnumIterator(this._elements, this._remaining);

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

/// Implementation of [EnumSet] where the number of possible values exceeds the
/// number of bits one integer can store.
///
/// Instead of storing the values in an single [int], the values are stored in
/// multiple ints which are contained in a list. Otherwise the operations are
/// implemented the same way as [_BaseEnumSetImpl].
class _LargeEnumSetImpl<T extends Enum> extends EnumSet<T> {
  late List<int> bitValues;

  /// Stores the length of the set. Storing the current length of the set gives
  /// a performance improvement in contrast to calculate the length on demand.
  int _length = 0;

  /// Helper method to get the index of the [int] in [bitValues] for an specific
  /// enum value.
  int _mapIndex(int index) => index >>> 5;

  /// Creates an instance of [_LargeEnumSetImpl] with the given [elements].
  _LargeEnumSetImpl(super.all, Iterable<T> elements) : super._() {
    if (elements is _LargeEnumSetImpl<T>) {
      bitValues = [...elements.bitValues];
      _length = elements._length;
    } else {
      bitValues =
          List.filled(_mapIndex(_enumConstants.length + (maxBitsInt - 1)), 0);
      addAll(elements);
    }
  }

  /// Returns a new [EnumSet] for the same enum type with the same values set as
  /// the current set.
  @override
  _LargeEnumSetImpl<T> copy() => _LargeEnumSetImpl(_enumConstants, this);

  /// Returns a new [EnumSet] for the same enum type but with no values in the
  /// set.
  _LargeEnumSetImpl<T> _copyEmpty() => _LargeEnumSetImpl(_enumConstants, []);

  @override
  bool add(T value) {
    if (contains(value)) {
      return false;
    }
    bitValues[_mapIndex(value.index)] |= (1 << (value.index % maxBitsInt));
    _length++;
    return true;
  }

  @override
  void addAll(Iterable<T> elements) {
    if (elements is _LargeEnumSetImpl<T>) {
      _length = 0;
      for (var i = 0; i < bitValues.length; i++) {
        bitValues[i] |= elements.bitValues[i];
        _length += countBits(bitValues[i]);
      }
    } else {
      elements.forEach(add);
    }
  }

  @override
  void clear() {
    for (var i = 0; i < bitValues.length; i++) {
      bitValues[i] = 0;
    }
    _length = 0;
  }

  @override
  EnumSet<T> complement() {
    var set = _copyEmpty();
    for (var i = 0; i < bitValues.length; i++) {
      var l = i < bitValues.length - 1
          ? maxBitsInt
          : _enumConstants.length % maxBitsInt;
      set.bitValues[i] = (~bitValues[i]).toUnsigned(l);
    }
    set._length = _enumConstants.length - _length;
    return set;
  }

  @override
  bool contains(Object? element) {
    if (element is T) {
      var pos = element.index % maxBitsInt;
      return (bitValues[_mapIndex(element.index)] & (1 << pos)) != 0;
    }
    return false;
  }

  @override
  bool containsAll(Iterable<Object?> other) {
    if (other is _LargeEnumSetImpl<T>) {
      for (int i = 0; i < bitValues.length; i++) {
        if (~bitValues[i] & other.bitValues[i] != 0) {
          return false;
        }
      }
      return true;
    }
    return other.every(contains);
  }

  @override
  EnumSet<T> difference(Set<Object?> other) {
    var set = _copyEmpty();
    if (other is _LargeEnumSetImpl<T>) {
      for (int i = 0; i < bitValues.length; i++) {
        set.bitValues[i] = bitValues[i] & (bitValues[i] ^ other.bitValues[i]);
        set._length += countBits(set.bitValues[i]);
      }
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
  T elementAt(int index) {
    var currentLength = 0;
    for (int i = 0; i < bitValues.length; i++) {
      var bitCount = countBits(bitValues[i]);
      if (currentLength + countBits(bitValues[i]) > index) {
        var pos = base(ffsn(bitValues[i], index - currentLength));
        return _enumConstants[pos + (i * maxBitsInt)];
      }
      currentLength += bitCount;
    }
    throw RangeError.index(index, this, "index", null, _length);
  }

  @override
  bool equals(Set<T> other) {
    if (other is _LargeEnumSetImpl<T>) {
      for (int i = 0; i < bitValues.length; i++) {
        if (bitValues[i] != other.bitValues[i]) {
          return false;
        }
      }
      return true;
    }
    return super.equals(other);
  }

  @override
  void fill() {
    for (var i = 0; i < bitValues.length; i++) {
      var l = i < bitValues.length - 1
          ? maxBitsInt
          : _enumConstants.length % maxBitsInt;
      bitValues[i] = (~0).toUnsigned(l);
    }
    _length = _enumConstants.length;
  }

  @override
  T get first => super.first;

  @override
  EnumSet<T> intersection(Set<Object?> other) {
    var set = _copyEmpty();
    if (other is _LargeEnumSetImpl<T>) {
      for (int i = 0; i < bitValues.length; i++) {
        set.bitValues[i] = bitValues[i] & other.bitValues[i];
        set._length += countBits(set.bitValues[i]);
      }
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
  bool get isEmpty => _length == 0;

  @override
  bool get isNotEmpty => _length != 0;

  @override
  Iterator<T> get iterator =>
      _LargeEnumIterator(_enumConstants.toList(), bitValues);

  @override
  int get length => _length;

  @override
  bool remove(Object? value) {
    if (value is T && contains(value)) {
      var pos = value.index % maxBitsInt;
      bitValues[_mapIndex(value.index)] ^= (1 << pos);
      _length--;
      return true;
    }
    return false;
  }

  @override
  void removeAll(Iterable<Object?> elements) {
    if (elements is _LargeEnumSetImpl<T>) {
      _length = 0;
      for (int i = 0; i < bitValues.length; i++) {
        bitValues[i] &= ~elements.bitValues[i];
        _length += countBits(bitValues[i]);
      }
    } else {
      elements.forEach(remove);
    }
  }

  @override
  void retainAll(Iterable<Object?> elements) {
    if (elements is _LargeEnumSetImpl<T>) {
      _length = 0;
      for (int i = 0; i < bitValues.length; i++) {
        bitValues[i] &= elements.bitValues[i];
        _length += countBits(bitValues[i]);
      }
    } else {
      for (var element in this) {
        if (!elements.contains(element)) remove(element);
      }
    }
  }

  @override
  T get single {
    if (isEmpty) throw "Bad state: No elements";
    if (length > 1) throw "Bad state: Too many elements";
    return first;
  }

  @override
  EnumSet<T> union(Set<T> other) {
    var set = copy();
    if (other is _LargeEnumSetImpl<T>) {
      set._length = 0;
      for (int i = 0; i < bitValues.length; i++) {
        set.bitValues[i] = bitValues[i] | other.bitValues[i];
        set._length += countBits(set.bitValues[i]);
      }
    } else {
      set.addAll(other);
    }
    return set;
  }
}

class _LargeEnumIterator<T extends Enum> extends Iterator<T> {
  final List<T> _elements;
  final List<int> _bitValues;
  int _currentBitValue;
  int _currentIndex = 0;
  int _current = 0;

  _LargeEnumIterator(this._elements, this._bitValues)
      : _currentBitValue = _bitValues[0];

  @override
  T get current => _elements[(_currentIndex << 5) + base(_current)];

  @override
  bool moveNext() {
    while (_currentBitValue == 0 && (_currentIndex < _bitValues.length - 1)) {
      _currentBitValue = _bitValues[++_currentIndex];
    }
    if (_currentBitValue == 0) return false;
    _current = _currentBitValue & -_currentBitValue;
    _currentBitValue ^= _current;
    return true;
  }
}
