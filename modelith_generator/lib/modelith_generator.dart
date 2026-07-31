/// The Modelith generator, exposed for custom build pipelines and tests.
///
/// Normal projects only need the `build.yaml` wiring that ships with this
/// package: add `modelith_generator` as a dev dependency and run
/// `build_runner`.
library;

export 'src/model_generator.dart' show ModelGenerator;
export 'src/model_options.dart' show ModelOptions;
