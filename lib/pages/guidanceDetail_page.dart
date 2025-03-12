import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class GuidanceDetailPage extends StatelessWidget {
  final Map<String, dynamic> guidance;

  const GuidanceDetailPage({super.key, required this.guidance});

  @override
  Widget build(BuildContext context) {
    final attributes = guidance['attributes'];
    final title = attributes['title'] ?? 'No Title';
    final tools = attributes['tools'] ?? 'No Tools';
    final description = attributes['description'] ?? 'No Description';
    final conclusion = attributes['conclusion'] ?? '';
    final steps = List<Map<String, dynamic>>.from(attributes['Steps'] ?? []);
    final videoData = attributes['video']?['data'];

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Video Section
              if (videoData != null) ...[
                VideoWidget(videoUrl: videoData['attributes']['url']),
                const SizedBox(height: 16),
              ],

              // Guidance Info
              Text(
                description,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              Text(
                'Tools: $tools',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),

              // Steps Section
              if (steps.isNotEmpty) ...[
                Text(
                  'Steps:',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                for (var step in steps)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Step Title
                        Text(
                          step['title'] ?? 'No Title',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium!
                              .copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),

                        // Step Description
                        Text(
                          step['description'] ?? 'No Description',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 8),

                        // Step Media (if available)
                        if (step['media']?['data'] != null)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              'https://strapi-production-23a4.up.railway.app${step['media']['data']['attributes']['url']}',
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, progress) {
                                if (progress == null) return child;
                                return const Center(
                                    child: CircularProgressIndicator());
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(Icons.broken_image,
                                    size: 50, color: Colors.grey);
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
              ],

              // Conclusion Section
              if (conclusion.isNotEmpty) ...[
                const Divider(),
                const SizedBox(height: 16),
                Text(
                  'Conclusion:',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  conclusion,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class VideoWidget extends StatefulWidget {
  final String videoUrl;

  const VideoWidget({super.key, required this.videoUrl});

  @override
  State<VideoWidget> createState() => _VideoWidgetState();
}

class _VideoWidgetState extends State<VideoWidget> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(
      'https://strapi-production-23a4.up.railway.app${widget.videoUrl}',
    )
      ..initialize().then((_) {
        setState(() {});
        _controller.setLooping(true);
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: _controller.value.aspectRatio,
      child: Stack(
        alignment: Alignment.center,
        children: [
          VideoPlayer(_controller),
          if (!_controller.value.isPlaying)
            IconButton(
              icon: const Icon(Icons.play_circle, size: 64, color: Colors.white),
              onPressed: () {
                setState(() {
                  _controller.play();
                });
              },
            ),
          if (_controller.value.isPlaying)
            IconButton(
              icon: const Icon(Icons.pause_circle, size: 64, color: Colors.white),
              onPressed: () {
                setState(() {
                  _controller.pause();
                });
              },
            ),
        ],
      ),
    );
  }
}
