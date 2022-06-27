[![pub package](https://img.shields.io/pub/v/enumerated.svg)](https://pub.dev/packages/enumerated)
[![package publisher](https://img.shields.io/pub/publisher/enumerated.svg)](https://pub.dev/packages/enumerated)
![build](https://github.com/Dimibe/enumerated/actions/workflows/dart.yaml/badge.svg??branch=main)

The enumerated package adds additional functionality around dart enums. 
One main aspect of this package is the `EnumSet`.  

## Features

* EnumSet - A `Set` implementation especially for enums. 
* EnumSet provides additional functionalities and more efficient implementations for specific set operations. 

## Getting started

Add the package to your pubspec.yaml:

```yaml
 enumerated: ^0.1.1
 ```
 
 In your dart file, import the library:

 ```Dart
import 'package:enumerated/enumerated.dart';
 ``` 

## Usage

#### Creating an EnumSet: 

In order to create an `EnumSet` you can choose from one of the following factory methods:
* `EnumSet.of(List, Iterable)`: Creates an `EnumSet` with the given values.  
* `EnumSet.noneOf(List)`: Creates an empty `EnumSet`.  
* `EnumSet.allOf(List)`:  Creates an `EnumSet` with all values of the given enum.
* `EnumSet.complementOf(EnumSet)`:  Creates an `EnumSet` with all values which are not contained in the other `EnumSet`

```dart
enum Numbers {one, two, three;}
var set1 = EnumSet.of(Numbers.values, [Numbers.one]);
var set2 = EnumSet.noneOf(Numbers.values);
var set3 = EnumSet.allOf(Numbers.values);
var set4 = EnumSet.complementOf(set1);
```

Note that for every factory method other than `complementOf` you need to provide the full list of possible enum values as first parameter. 

#### Adding and removing data:

```dart
set1.add(Numbers.two);
set1.addAll(set3);
set1.remove(Numbers.one);
set1.removeAll(set3);
```

#### Other useful functionalities: 

* fill(): Will add all enum values to the set. 

```dart
set1.fill();
```

* complement(): Will return a new `EnumSet` with all values which are not contained in the current set. 

```dart
set1.complement();
```

* copy(): Creates a exact copy of the current set. 

```dart
set1.copy();
```


## Additional information

If you have ideas for this package or want to help develop it yourself, 
don't hesitate to open an issue or create a pull request. I am grateful for any help!
