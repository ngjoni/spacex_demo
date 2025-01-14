import 'package:spacex_api/spacex_api.dart';

///Thrown when an error occurs while looking up for launches
class LaunchException implements Exception {}

/// {@template launch_repository}
/// A Dart package to manage the launches
/// {@endtemplate}
class LaunchRepository {
  /// {@macro launches_repository}
  LaunchRepository({SpaceXApiClient? spaceXApiClient})
      : _spaceXApiClient = spaceXApiClient ?? SpaceXApiClient();

  final SpaceXApiClient _spaceXApiClient;

  /// Returns the latest launch.
  ///
  /// Throws a [LaunchException] if an error occurs.
  Future<Launch> fetchLatestLaunch() {
    try {
      return _spaceXApiClient.fetchLatestLaunch();
    } on Exception {
      throw LaunchException();
    }
  }
}
