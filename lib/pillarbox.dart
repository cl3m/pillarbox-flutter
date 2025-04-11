library pillarbox;

import 'dart:async';
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

var _baseId = 0;

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
        id = _baseId,
        _plugin = const MethodChannel('pillarbox'),
        super(const PillarboxPlayerValue(duration: Duration.zero)) {
    _baseId++;
  }

  /// The URI to the video file.
  final String dataSource;

  bool _isDisposed = false;

  int id;
  MethodChannel? _channel;
  final MethodChannel? _plugin;
  final _initalization = Completer<void>();

  Future<dynamic> _handleMethod(MethodCall call) async {
    switch (call.method) {
      case 'log':
        String text = call.arguments as String;
        debugPrint("[Pillarbox] $text");
        return Future.value("Text from native: $text");
      case 'position':
        debugPrint("[Pillarbox] position: ${call.arguments}");
        var position = double.tryParse(call.arguments["position"]);
        if (position != null && position != 0) {
          value = value.copyWith(
              position: Duration(milliseconds: (position * 1000).toInt()));
        }
        return null;
      case 'properties':
        debugPrint("[Pillarbox] properties: ${call.arguments}");
        var newvalue = value;
        var height = double.tryParse(call.arguments["presentationSizeHeight"]);
        var width = double.tryParse(call.arguments["presentationSizeWidth"]);
        if (height != null && width != null && height != 0 && width != 0) {
          newvalue = newvalue.copyWith(size: Size(width, height));
        }
        var isPlaying = call.arguments["state"] == "playing";
        if (value.isPlaying != isPlaying) {
          newvalue = newvalue.copyWith(isPlaying: isPlaying);
        }
        var duration = double.tryParse(call.arguments["duration"]);
        if (duration != null && duration != 0) {
          newvalue = newvalue.copyWith(
              duration: Duration(milliseconds: (duration * 1000).toInt()));
        }
        var position = double.tryParse(call.arguments["position"]);
        if (position != null && position != 0) {
          newvalue = newvalue.copyWith(
              position: Duration(milliseconds: (position * 1000).toInt()));
        }
        var isEnding = call.arguments["state"] == "ended";
        var rate = double.tryParse(call.arguments["rate"]) ?? 0.0;
        if (!value.isPlaying && isEnding && rate > 0.0) {
          //state stay ended when replay
          newvalue = newvalue.copyWith(isPlaying: true);
        }
        newvalue = newvalue.copyWith(isCompleted: isEnding && rate == 0.0);
        var isPaused = call.arguments["state"] == "paused";
        if (isPaused && !value.isInitialized) {
          newvalue = newvalue.copyWith(isInitialized: true);
          value = newvalue;
          _initalization.complete();
        } else {
          value = newvalue;
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
        var isReady = call.arguments == "ready";
        if (value.isInitialized != isReady) {
          value = value.copyWith(isInitialized: true);
          _initalization.complete();
        }
        return null;
      case 'duration':
        debugPrint("[Pillarbox] duration: ${call.arguments}");
        var duration = Duration(milliseconds: call.arguments);
        if (value.duration != duration) {
          value = value.copyWith(duration: duration);
        }
        return null;
      case 'current_position':
        debugPrint("[Pillarbox] current_position: ${call.arguments}");
        var duration = Duration(milliseconds: call.arguments);
        if (value.duration != duration) {
          value = value.copyWith(position: duration);
        }
        return null;

      case 'video_size':
        debugPrint("[Pillarbox] video_size: ${call.arguments}");
        int height = call.arguments["height"];
        int width = call.arguments["width"];
        if (height != 0 && width != 0) {
          value =
              value.copyWith(size: Size(width.toDouble(), height.toDouble()));
        }
        return null;
      default:
        throw UnimplementedError('${call.method} is not implemented');
    }
  }

  /// Attempts to open the given [dataSource] and load metadata about the video.
  Future<void> initialize() async {
    var debug = await _plugin?.invokeMethod(
        "initialize", {"identifier": id, "dataSource": dataSource});
    debugPrint(debug);
    _channel = MethodChannel('pillarbox/$id');
    _channel!.setMethodCallHandler(_handleMethod);
    return _initalization.future;
  }

  @override
  Future<void> dispose() async {
    if (_isDisposed) {
      return;
    }

    var debug = await _plugin?.invokeMethod("dispose", {"identifier": id});
    debugPrint(debug);

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
    final Map<String, int> args = {"identifier": widget.controller.id};
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
    debugPrint("_onPlatformViewCreated:$id");
  }
}
