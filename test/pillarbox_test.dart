import 'package:flutter_test/flutter_test.dart';
import 'package:pillarbox/pillarbox_plugin.dart';
import 'package:pillarbox/pillarbox_platform_interface.dart';
import 'package:pillarbox/pillarbox_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockPillarboxPlatform
    with MockPlatformInterfaceMixin
    implements PillarboxPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final PillarboxPlatform initialPlatform = PillarboxPlatform.instance;

  test('$MethodChannelPillarbox is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelPillarbox>());
  });

  test('getPlatformVersion', () async {
    PillarboxPlugin pillarboxPlugin = PillarboxPlugin();
    MockPillarboxPlatform fakePlatform = MockPillarboxPlatform();
    PillarboxPlatform.instance = fakePlatform;

    expect(await pillarboxPlugin.getPlatformVersion(), '42');
  });
}
