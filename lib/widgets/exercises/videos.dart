/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c) 2020 - 2026 wger Team
 *
 * wger Workout Manager is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:video_player/video_player.dart';
import 'package:wger/core/error_dialogs.dart';
import 'package:wger/core/exceptions/http_exception.dart';
import 'package:wger/models/exercises/video.dart';
import 'package:wger/providers/wger_base.dart';

class ExerciseVideoWidget extends ConsumerStatefulWidget {
  const ExerciseVideoWidget({required this.video});

  final Video video;

  @override
  ConsumerState<ExerciseVideoWidget> createState() => _ExerciseVideoWidgetState();
}

class _ExerciseVideoWidgetState extends ConsumerState<ExerciseVideoWidget> {
  final logger = Logger('ExerciseVideoWidgetState');

  VideoPlayerController? _controller;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    // Defer controller construction until first build so we can resolve the
    // absolute media URL via Riverpod.
  }

  void _ensureController() {
    if (_controller != null) {
      return;
    }
    final uri = ref.read(mediaUrlBuilderProvider)(widget.video.video);
    if (uri == null) {
      hasError = true;
      return;
    }
    _controller = VideoPlayerController.networkUrl(uri);
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      await _controller!.initialize();
      if (mounted) {
        setState(() {});
      }
    } on PlatformException catch (e) {
      if (mounted) {
        setState(() => hasError = true);
      }

      logger.warning('PlatformException while initializing video: ${e.message}');
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _ensureController();
    final controller = _controller;
    return hasError || controller == null
        ? FormHttpErrorsWidget(
            WgerHttpException.fromMap(
              const {
                'error':
                    'An error happened while loading the video. If you can, '
                    'please check the application logs.',
              },
            ),
          )
        : controller.value.isInitialized
        ? AspectRatio(
            aspectRatio: controller.value.aspectRatio,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                VideoPlayer(controller),
                _ControlsOverlay(controller: controller),
                VideoProgressIndicator(controller, allowScrubbing: true),
              ],
            ),
          )
        : Container();
  }
}

/// Control overlay for the exercise video player
///
/// Taken from this example: https://pub.dev/packages/video_player/example
class _ControlsOverlay extends StatelessWidget {
  const _ControlsOverlay({required this.controller});

  static const _playbackRates = [0.25, 0.5, 1.0];

  final VideoPlayerController controller;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 50),
          reverseDuration: const Duration(milliseconds: 200),
          child: controller.value.isPlaying
              ? const SizedBox.shrink()
              : Container(
                  color: Colors.black26,
                  child: const Center(
                    child: Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 100.0,
                      semanticLabel: 'Play',
                    ),
                  ),
                ),
        ),
        GestureDetector(
          onTap: () {
            controller.value.isPlaying ? controller.pause() : controller.play();
          },
        ),
        Align(
          alignment: Alignment.topRight,
          child: PopupMenuButton<double>(
            initialValue: controller.value.playbackSpeed,
            tooltip: 'Playback speed',
            onSelected: (speed) {
              controller.setPlaybackSpeed(speed);
            },
            itemBuilder: (context) {
              return [
                for (final speed in _playbackRates)
                  PopupMenuItem(value: speed, child: Text('${speed}x')),
              ];
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                // Using less vertical padding as the text is also longer
                // horizontally, so it feels like it would need more spacing
                // horizontally (matching the aspect ratio of the video).
                vertical: 8,
                horizontal: 9,
              ),
              child: Text('${controller.value.playbackSpeed}x'),
            ),
          ),
        ),
      ],
    );
  }
}
