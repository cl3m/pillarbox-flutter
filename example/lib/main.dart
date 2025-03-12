import 'package:flutter/material.dart';
import 'package:pillarbox_example/player_view.dart';
import 'package:pillarbox_example/video_toktik.dart';
import 'package:pillarbox_example/pillarbox_toktik.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _selectedIndex = 0;

  static const List<Widget> _widgets = <Widget>[
    VideoTokTik(),
    PillarboxTokTik(),
    PlayerView(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      appBar: AppBar(title: const Text('Pillarbox Demo')),
      body: IndexedStack(
        index: _selectedIndex,
        children: _widgets,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Icon(Icons.videocam), label: 'VideoTokTik'),
          BottomNavigationBarItem(
            icon: Icon(Icons.videocam),
            label: 'PillarboxTokTik',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Player'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    ));
  }
}
