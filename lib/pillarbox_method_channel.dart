import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'pillarbox_platform_interface.dart';

/// An implementation of [PillarboxPlatform] that uses method channels.
class MethodChannelPillarbox extends PillarboxPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('pillarbox');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
