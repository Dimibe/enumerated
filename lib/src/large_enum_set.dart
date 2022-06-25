import 'enum_set.dart';

class _LargeEnumSetImpl<T extends Enum> extends EnumSet<T> {
  late List<int> bitValues;

  /// Creates an instance of [_LargeEnumSetImpl] with the given [elements].
  _LargeEnumSetImpl.fromIterable(super.all, Iterable<T> elements) : super._() {
    if (elements is _LargeEnumSetImpl<T>) {
      bitValues = [...elements.bitValues];
    } else {
      bitValues =
          List.filled((_enumConstants.length + (maxBitsInt - 1)) >>> 5, 0);
      addAll(elements);
    }
  }

  /// Creates an instance of [_LargeEnumSetImpl] with the given [bitValue].
  _LargeEnumSetImpl.fromBitValue(super.all, this.bitValues) : super._();

  @override
  _LargeEnumSetImpl<T> copy() {
    return _LargeEnumSetImpl.fromBitValue(_enumConstants, bitValues);
  }

  _LargeEnumSetImpl<T> _copyEmpty() {
    return _LargeEnumSetImpl.fromBitValue(
      _enumConstants,
      List.filled((_enumConstants.length + (maxBitsInt - 1)) >>> 5, 0),
    );
  }

  @override
  bool add(T value) {
    // TODO: implement add
    throw UnimplementedError();
  }

  @override
  void addAll(Iterable<T> elements) {
    // TODO: implement addAll
  }

  @override
  Set<R> cast<R>() => Iterable.castFrom<T, R>(this).toSet();

  @override
  void clear() {
    // TODO: implement clear
  }

  @override
  EnumSet<T> complement() {
    // TODO: implement complement
    throw UnimplementedError();
  }

  @override
  bool containsAll(Iterable<Object?> other) {
    // TODO: implement containsAll
    throw UnimplementedError();
  }

  @override
  EnumSet<T> difference(Set<Object?> other) {
    // TODO: implement difference
    throw UnimplementedError();
  }

  @override
  void fill() {
    // TODO: implement fill
  }

  @override
  EnumSet<T> intersection(Set<Object?> other) {
    // TODO: implement intersection
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
    // TODO: implement remove
    throw UnimplementedError();
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
  EnumSet<T> union(Set<T> other) {
    // TODO: implement union
    throw UnimplementedError();
  }
}
