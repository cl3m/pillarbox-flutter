import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'pillarbox_method_channel.dart';

abstract class PillarboxPlatform extends PlatformInterface {
  /// Constructs a PillarboxPlatform.
  PillarboxPlatform() : super(token: _token);

  static final Object _token = Object();

  static PillarboxPlatform _instance = MethodChannelPillarbox();

  /// The default instance of [PillarboxPlatform] to use.
  ///
  /// Defaults to [MethodChannelPillarbox].
  static PillarboxPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [PillarboxPlatform] when
  /// they register themselves.
  static set instance(PillarboxPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
