import 'package:meta/meta.dart';

///
@sealed
abstract class EnumSet<T extends Enum> extends Iterable<T> implements Set<T> {
  Set<T> enumConstants;

  EnumSet._(Iterable<T> all, [Iterable<T>? values]) : enumConstants = {...all} {
    if (values != null) {
      addAll(values);
    }
  }

  factory EnumSet.of(Iterable<T> all, Iterable<T> values) {
    if (all.length > 64) {}
    return _BaseEnumSetImpl<T>(all, values);
  }

  factory EnumSet.allOf(Iterable<T> all) {
    return EnumSet.of(all, all);
  }

  factory EnumSet.noneOf(Iterable<T> all) {
    return EnumSet.of(all, <T>[]);
  }

  factory EnumSet.complementOf(EnumSet<T> otherSet) {
    return EnumSet.of(otherSet.enumConstants, otherSet._complement());
  }

  @override
  void addAll(Iterable<T> elements) {
    elements.forEach(add);
  }

  Iterable<T> _complement();
}

class _BaseEnumSetImpl<T extends Enum> extends EnumSet<T> {
  int bitValue = 0;

  _BaseEnumSetImpl(super.all, super.values) : super._();

  _BaseEnumSetImpl.empty(super.all) : super._();

  Iterable<T> _complement() {
    return [];
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
  Set<T> difference(Set<Object?> other) {
    if (other is _BaseEnumSetImpl<T>) {
      var set = _BaseEnumSetImpl.empty(enumConstants);
      set.bitValue = bitValue ^ (1 << other.bitValue);
      return set;
    }
    // TODO: implement difference
    throw UnimplementedError();
  }

  @override
  Set<T> intersection(Set<Object?> other) {
    if (other is _BaseEnumSetImpl<T>) {
      var set = _BaseEnumSetImpl.empty(enumConstants);
      set.bitValue = bitValue & (1 << other.bitValue);
      return set;
    }
    // TODO: implement difference
    throw UnimplementedError();
  }

  @override
  Set<T> union(Set<T> other) {
    if (other is _BaseEnumSetImpl<T>) {
      var set = _BaseEnumSetImpl.empty(enumConstants);
      set.bitValue = bitValue | other.bitValue;
      return set;
    }
    // TODO: implement union
    throw UnimplementedError();
  }

  @override
  Iterator<T> get iterator => EnumIterator._(enumConstants.toList(), bitValue);

  @override
  T? lookup(Object? object) {
    if (contains(object)) return object as T;
    return null;
  }

  @override
  bool remove(Object? value) {
    if (contains(value) && value is T) {
      bitValue = bitValue ^ value.index;
      return true;
    }
    return false;
  }

  @override
  void removeAll(Iterable<Object?> elements) {
    elements.forEach(remove);
  }

  @override
  void removeWhere(bool Function(T element) test) {
    // TODO: implement removeWhere
  }

  @override
  void retainAll(Iterable<Object?> elements) {
    // TODO: implement retainAll
  }

  @override
  void retainWhere(bool Function(T element) test) {
    // TODO: implement retainWhere
  }

  @override
  Set<R> cast<R>() {
    // TODO: implement cast
    throw UnimplementedError();
  }

  @override
  T elementAt(int index) {
    return enumConstants.elementAt(bitValue << index);
  }

  @override
  T get first => enumConstants.elementAt(bitValue & -bitValue);

  @override
  bool get isEmpty => bitValue == 0;

  @override
  bool get isNotEmpty => bitValue != 0;

  @override
  T get single {
    if (bitValue != 0 && bitValue & (bitValue - 1) == 0) {
      return enumConstants.elementAt(bitValue);
    }
    // TODO: implement singleWhere
    throw UnimplementedError();
  }
}

class EnumIterator<T extends Enum> extends Iterator<T> {
  List<T> _elements;
  int _remaining;
  int _current = 0;

  EnumIterator._(this._elements, this._remaining);

  @override
  T get current => _elements[_current];

  @override
  bool moveNext() {
    _current = _remaining & -_remaining;
    _remaining ^= _current;
    return _remaining != 0;
  }
}
