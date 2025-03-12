import 'pillarbox_platform_interface.dart';

class PillarboxPlugin {
  Future<String?> getPlatformVersion() {
    return PillarboxPlatform.instance.getPlatformVersion();
  }
}
