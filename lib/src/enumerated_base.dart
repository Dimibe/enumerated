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
    if (value is Enum) {
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
    if (other is Iterable<Enum>) {
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
  // TODO: implement iterator
  Iterator<T> get iterator => throw UnimplementedError();

  @override
  T? lookup(Object? object) {
    // TODO: implement lookup
    throw UnimplementedError();
  }

  @override
  bool remove(Object? value) {
    if (contains(value) && value is Enum) {
      bitValue = bitValue ^ value.index;
      return true;
    }
    return false;
  }

  @override
  void removeAll(Iterable<Object?> elements) {
    // TODO: implement removeAll
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
    // TODO: implement elementAt
    throw UnimplementedError();
  }

  @override
  // TODO: implement first
  T get first => throw UnimplementedError();

  @override
  // TODO: implement isEmpty
  bool get isEmpty => bitValue == 0;

  @override
  // TODO: implement isNotEmpty
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
  EnumIterator._(EnumSet set);
  @override
  // TODO: implement current
  T get current => throw UnimplementedError();

  @override
  bool moveNext() {
    // TODO: implement moveNext
    throw UnimplementedError();
  }
}
