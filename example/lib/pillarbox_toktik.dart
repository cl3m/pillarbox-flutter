import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pillarbox/pillarbox.dart';
import 'package:pillarbox_example/main.dart';

class PillarboxTokTik extends StatefulWidget {
  const PillarboxTokTik({super.key});

  @override
  State<PillarboxTokTik> createState() => _PillarboxTokTikState();
}

class _PillarboxTokTikState extends State<PillarboxTokTik> {
  late PageController _pageViewController;
  int _currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageViewController = PageController();
  }

  @override
  void dispose() {
    super.dispose();
    _pageViewController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Stack(
      alignment: Alignment.bottomCenter,
      children: <Widget>[
        PageView(
          /// [PageView.scrollDirection] defaults to [Axis.horizontal].
          /// Use [Axis.vertical] to scroll vertically.
          controller: _pageViewController,
          onPageChanged: _handlePageViewChanged,
          children: videoUrls.map((e) {
            return PillarboxTokTikPage(e);
          }).toList(),
        ),
        Padding(
          padding: const EdgeInsets.all(0.0),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: videoUrls.asMap().entries.map((e) {
                return Text("·",
                    style: TextStyle(
                        fontSize: 50,
                        color: _currentPageIndex == e.key
                            ? Colors.white
                            : Colors.white.withAlpha(50)));
              }).toList()),
        ),
      ],
    );
  }

  void _handlePageViewChanged(int currentPageIndex) {
    setState(() {
      _currentPageIndex = currentPageIndex;
    });
  }
}

/// Stateful widget to fetch and then display video content.
class PillarboxTokTikPage extends StatefulWidget {
  const PillarboxTokTikPage(this.networkUrl, {super.key});

  final String networkUrl;

  @override
  State<PillarboxTokTikPage> createState() => _PillarboxTokTikPageState();
}

class _PillarboxTokTikPageState extends State<PillarboxTokTikPage> {
  late PillarboxPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        PillarboxPlayerController.networkUrl(Uri.parse(widget.networkUrl))
          ..initialize().then((_) {
            // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
            setState(() {});
            _controller.play();
          });
    _controller.addListener(() {
      //Ensure controller state is correct when player change state
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: _controller.value.isInitialized
            ? Stack(
                alignment: Alignment.topCenter,
                children: [
                  AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: PillarboxPlayer(_controller),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(20.0),
                    child: LinearProgressIndicator(
                      value: 0.5,
                      color: Colors.white,
                    ),
                  )
                ],
              )
            : Platform.isIOS
                ? const CupertinoActivityIndicator(color: Colors.white)
                : const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
