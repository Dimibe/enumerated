import 'package:meta/meta.dart';

import 'bit_operations.dart';

///
@sealed
abstract class EnumSet<T extends Enum> extends Iterable<T> implements Set<T> {
  final List<T> _enumConstants;

  EnumSet._(List<T> all) : _enumConstants = all;

  // TODO: Implement solution for large enums
  factory EnumSet.of(List<T> all, Iterable<T> elements) {
    return _BaseEnumSetImpl<T>.fromIterable(all, elements);
  }

  factory EnumSet.allOf(List<T> all) {
    return EnumSet.of(all, all);
  }

  factory EnumSet.noneOf(List<T> all) {
    return EnumSet.of(all, <T>[]);
  }

  factory EnumSet.complementOf(EnumSet<T> other) {
    return EnumSet.of(other._enumConstants, other.complement());
  }

  factory EnumSet.copy(EnumSet<T> other) {
    return EnumSet.of(other._enumConstants, other);
  }

  void fill();
  EnumSet<T> complement();
  EnumSet<T> copy();
}

class _BaseEnumSetImpl<T extends Enum> extends EnumSet<T> {
  int bitValue = 0;

  _BaseEnumSetImpl.fromIterable(super.all, Iterable<T> elements) : super._() {
    if (elements is _BaseEnumSetImpl<T>) {
      bitValue = elements.bitValue;
    } else {
      addAll(elements);
    }
  }

  _BaseEnumSetImpl.copy(super.all, this.bitValue) : super._();

  @override
  _BaseEnumSetImpl<T> copy() {
    return _BaseEnumSetImpl.copy(_enumConstants, bitValue);
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
    bitValue |= 1 << _enumConstants.length;
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
    if (other is Iterable<T>) {
      return other.every(contains);
    }
    return false;
  }

  @override
  EnumSet<T> difference(Set<Object?> other) {
    if (other is _BaseEnumSetImpl<T>) {
      var set = copy();
      set.bitValue &= (bitValue ^ other.bitValue);
      return set;
    }
    return copy();
  }

  @override
  EnumSet<T> intersection(Set<Object?> other) {
    if (other is _BaseEnumSetImpl<T>) {
      var set = copy();
      set.bitValue &= other.bitValue;
      return set;
    }
    return copy();
  }

  @override
  EnumSet<T> union(Set<T> other) {
    if (other is _BaseEnumSetImpl<T>) {
      var set = copy();
      set.bitValue |= other.bitValue;
      return set;
    }
    return copy();
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
    for (T element in this) {
      if (!elements.contains(element)) remove(element);
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
