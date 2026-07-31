/// The type of [$unset].
///
/// Only ever used as the default value of a generated `copyWith` parameter for
/// a nullable field, so that passing an explicit `null` is distinguishable from
/// omitting the argument.
class $Unset {
  const $Unset();

  @override
  String toString() => 'unset';
}

/// Marker meaning "argument not provided" in a generated `copyWith`.
///
/// Referenced by generated code; there is no reason to use it by hand.
const $unset = $Unset();
