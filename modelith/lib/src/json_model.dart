/// Declares that a model serializes to a `Map<String, dynamic>`.
///
/// Implementing this on a `@Model` class is what lets *other* models embed it
/// as a field: the nested `toJson()` lives in the generated `_$Foo` mixin, which
/// does not exist yet while the outer model's json code is being generated, so
/// the json generator needs a resolvable declaration to look at. The mixin
/// satisfies the interface, so nothing extra has to be written in the class
/// body.
///
/// ```dart
/// @Model()
/// class AddressModel with Equatable, _$AddressModel implements JsonModel {
///   ...
/// }
/// ```
abstract interface class JsonModel {
  Map<String, dynamic> toJson();
}
