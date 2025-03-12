library pillarbox;

import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// The duration, current position, buffering state, error state and settings
/// of a [PillarboxPlayerController].
@immutable
class PillarboxPlayerValue {
  /// Constructs a video with the given values. Only [duration] is required. The
  /// rest will initialize with default values when unset.
  const PillarboxPlayerValue({
    required this.duration,
    this.size = Size.zero,
    this.position = Duration.zero,
    this.isInitialized = false,
    this.isPlaying = false,
    this.errorDescription,
    this.isCompleted = false,
  });

  /// Returns an instance for a video that hasn't been loaded.
  const PillarboxPlayerValue.uninitialized()
      : this(duration: Duration.zero, isInitialized: false);

  /// Returns an instance with the given [errorDescription].
  const PillarboxPlayerValue.erroneous(String errorDescription)
      : this(
            duration: Duration.zero,
            isInitialized: false,
            errorDescription: errorDescription);

  /// This constant is just to indicate that parameter is not passed to [copyWith]
  /// workaround for this issue https://github.com/dart-lang/language/issues/2009
  static const String _defaultErrorDescription = 'defaultErrorDescription';

  /// The total duration of the video.
  ///
  /// The duration is [Duration.zero] if the video hasn't been initialized.
  final Duration duration;

  /// The current playback position.
  final Duration position;

  /// True if the video is playing. False if it's paused.
  final bool isPlaying;

  /// A description of the error if present.
  ///
  /// If [hasError] is false this is `null`.
  final String? errorDescription;

  /// True if video has finished playing to end.
  ///
  /// Reverts to false if video position changes, or video begins playing.
  /// Does not update if video is looping.
  final bool isCompleted;

  /// The [size] of the currently loaded video.
  final Size size;

  /// Indicates whether or not the video has been loaded and is ready to play.
  final bool isInitialized;

  /// Indicates whether or not the video is in an error state. If this is true
  /// [errorDescription] should have information about the problem.
  bool get hasError => errorDescription != null;

  /// Returns [size.width] / [size.height].
  ///
  /// Will return `1.0` if:
  /// * [isInitialized] is `false`
  /// * [size.width], or [size.height] is equal to `0.0`
  /// * aspect ratio would be less than or equal to `0.0`
  double get aspectRatio {
    if (!isInitialized || size.width == 0 || size.height == 0) {
      return 1.0;
    }
    final double aspectRatio = size.width / size.height;
    if (aspectRatio <= 0) {
      return 1.0;
    }
    return aspectRatio;
  }

  /// Returns a new instance that has the same values as this current instance,
  /// except for any overrides passed in as arguments to [copyWith].
  PillarboxPlayerValue copyWith({
    Duration? duration,
    Size? size,
    Duration? position,
    bool? isInitialized,
    bool? isPlaying,
    String? errorDescription = _defaultErrorDescription,
    bool? isCompleted,
  }) {
    return PillarboxPlayerValue(
      duration: duration ?? this.duration,
      size: size ?? this.size,
      position: position ?? this.position,
      isInitialized: isInitialized ?? this.isInitialized,
      isPlaying: isPlaying ?? this.isPlaying,
      errorDescription: errorDescription != _defaultErrorDescription
          ? errorDescription
          : this.errorDescription,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

/// Controls a platform video player, and provides updates when the state is
/// changing.
///
/// Instances must be initialized with initialize.
///
/// The video is displayed in a Flutter app by creating a [PillarboxPlayer] widget.
///
/// To reclaim the resources used by the player call [dispose].
///
/// After [dispose] all further calls are ignored.
class PillarboxPlayerController extends ValueNotifier<PillarboxPlayerValue> {
  /// Constructs a [VideoPlayerController] playing a network video.
  ///
  /// The URI for the video is given by the [dataSource] argument.
  ///
  /// [httpHeaders] option allows to specify HTTP headers
  /// for the request to the [dataSource].
  PillarboxPlayerController.networkUrl(Uri url)
      : dataSource = url.toString(),
        super(const PillarboxPlayerValue(duration: Duration.zero));

  /// The URI to the video file.
  final String dataSource;

  bool _isDisposed = false;

  var _viewId = 0;
  MethodChannel? _channel = null;

  void attach(int viewId) {
    _viewId = viewId;
    _channel = MethodChannel('Pillarbox/$viewId');
    _channel!.setMethodCallHandler(_handleMethod);
  }

  Future<dynamic> _handleMethod(MethodCall call) async {
    switch (call.method) {
      case 'log':
        String text = call.arguments as String;
        debugPrint("[Pillarbox] $text");
        return Future.value("Text from native: $text");
      case 'properties':
        debugPrint("[Pillarbox] properties: ${call.arguments}");
        var isPlaying = call.arguments["state"] == "playing";
        if (value.isPlaying != isPlaying) {
          value = value.copyWith(isPlaying: isPlaying);
        }
        return null;
      case 'is_playing':
        debugPrint("[Pillarbox] is_playing: ${call.arguments}");
        var isPlaying = call.arguments == "true";
        if (value.isPlaying != isPlaying) {
          value = value.copyWith(isPlaying: isPlaying);
        }
        return null;
      case 'state':
        debugPrint("[Pillarbox] state: ${call.arguments}");
        return null;
      default:
        throw UnimplementedError('${call.method} is not implemented');
    }
  }

  /// Attempts to open the given [dataSource] and load metadata about the video.
  Future<void> initialize() async {
    //TODO: Attach the Player to the controller directly and detect when initialized
    value = value.copyWith(isInitialized: true);
  }

  @override
  Future<void> dispose() async {
    if (_isDisposed) {
      return;
    }

    _isDisposed = true;
    super.dispose();
  }

  /// Starts playing the video.
  ///
  /// If the video is at the end, this method starts playing from the beginning.
  ///
  /// This method returns a future that completes as soon as the "play" command
  /// has been sent to the platform, not when playback itself is totally
  /// finished.
  Future<void> play() async {
    if (value.position == value.duration) {
      await seekTo(Duration.zero);
    }
    value = value.copyWith(isPlaying: true);
    //await _applyPlayPause();
    _channel?.invokeMethod("play", null);
  }

  /// Pauses the video.
  Future<void> pause() async {
    value = value.copyWith(isPlaying: false);
    //await _applyPlayPause();
    _channel?.invokeMethod("pause", null);
  }

  /// The position in the current video.
  Future<Duration?> get position async {
    if (_isDisposed) {
      return null;
    }
    return null;
  }

  /// Sets the video's current timestamp to be at [moment]. The next
  /// time the video is played it will resume from the given [moment].
  ///
  /// If [moment] is outside of the video's full range it will be automatically
  /// and silently clamped.
  Future<void> seekTo(Duration position) async {
    if (_isDisposedOrNotInitialized) {
      return;
    }
    if (position > value.duration) {
      position = value.duration;
    } else if (position < Duration.zero) {
      position = Duration.zero;
    }
    //await _videoPlayerPlatform.seekTo(_textureId, position);
    //_updatePosition(position);
  }

  bool get _isDisposedOrNotInitialized => _isDisposed || !value.isInitialized;
}

class PillarboxPlayer extends StatefulWidget {
  /// Uses the given [controller] for all video rendered in this widget.
  const PillarboxPlayer(this.controller, {super.key});

  /// The [PillarboxPlayerController] responsible for the video being rendered in
  /// this widget.
  final PillarboxPlayerController controller;

  @override
  State<PillarboxPlayer> createState() => _PillarboxPlayerState();
}

class _PillarboxPlayerState extends State<PillarboxPlayer> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void didUpdateWidget(PillarboxPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  void deactivate() {
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, String> args = {"uri": widget.controller.dataSource};
    if (Platform.isIOS) {
      return UiKitView(
        viewType: "pillarbox-view",
        onPlatformViewCreated: _onPlatformViewCreated,
        creationParams: args,
        creationParamsCodec: const StandardMessageCodec(),
      );
    } else if (Platform.isAndroid) {
      return AndroidView(
        viewType: "pillarbox-view",
        onPlatformViewCreated: _onPlatformViewCreated,
        creationParams: args,
        creationParamsCodec: const StandardMessageCodec(),
      );
    } else {
      return const Text('Unsupported platform');
    }
  }

  void _onPlatformViewCreated(int id) {
    widget.controller.attach(id);
  }
}
