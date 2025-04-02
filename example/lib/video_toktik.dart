import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pillarbox_example/main.dart';
import 'package:video_player/video_player.dart';

class VideoTokTik extends StatefulWidget {
  const VideoTokTik({super.key});

  @override
  State<VideoTokTik> createState() => _VideoTokTikState();
}

class _VideoTokTikState extends State<VideoTokTik> {
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
            return VideoTokTikPage(e);
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
class VideoTokTikPage extends StatefulWidget {
  const VideoTokTikPage(this.networkUrl, {super.key});

  final String networkUrl;

  @override
  State<VideoTokTikPage> createState() => _VideoTokTikPageState();
}

class _VideoTokTikPageState extends State<VideoTokTikPage> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.networkUrl))
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {});
        _controller.play();
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
                    child: VideoPlayer(_controller),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: VideoProgressIndicator(
                      _controller,
                      allowScrubbing: true,
                      colors:
                          const VideoProgressColors(playedColor: Colors.white),
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
