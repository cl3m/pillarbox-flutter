import 'package:flutter/material.dart';
import 'package:pillarbox_example/player_view.dart';
import 'package:pillarbox_example/video_toktik.dart';
import 'package:pillarbox_example/pillarbox_toktik.dart';

void main() {
  runApp(const MyApp());
}

final List<String> videoUrls = [
  "https://rts-vod-amd.akamaized.net/ww/13444390/f1b478f7-2ae9-3166-94b9-c5d5fe9610df/master.m3u8",
  "https://rts-vod-amd.akamaized.net/ww/13444333/feb1d08d-e62c-31ff-bac9-64c0a7081612/master.m3u8",
  "https://rts-vod-amd.akamaized.net/ww/13444466/2787e520-412f-35fb-83d7-8dbb31b5c684/master.m3u8",
  "https://rts-vod-amd.akamaized.net/ww/13444447/c1d17174-ad2f-31c2-a084-846a9247fd35/master.m3u8",
  "https://rts-vod-amd.akamaized.net/ww/13444352/32145dc0-b5f8-3a14-ae11-5fc6e33aaaa4/master.m3u8",
  "https://rts-vod-amd.akamaized.net/ww/13444409/23f808a4-b14a-3d3e-b2ed-fa1279f6cf01/master.m3u8",
  "https://rts-vod-amd.akamaized.net/ww/13444371/3f26467f-cd97-35f4-916f-ba3927445920/master.m3u8",
  "https://rts-vod-amd.akamaized.net/ww/13444428/857d97ef-0b8e-306e-bf79-3b13e8c901e4/master.m3u8",
];

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget content(int index) {
    switch (index) {
      case 0:
        return const PillarboxTokTik();
      case 1:
        return const VideoTokTik();
      case 2:
        return const PlayerView();
      default:
        throw UnimplementedError('content $index is not implemented');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      appBar: AppBar(title: const Text('Pillarbox Demo')),
      body: content(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.videocam),
            label: 'PillarboxTokTik',
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.videocam), label: 'VideoTokTik'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Player'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFFA1001E),
        onTap: _onItemTapped,
      ),
    ));
  }
}
