import 'package:flutter/material.dart';
import '../models/content_item.dart';

class AboutScreen extends StatelessWidget {
  final List<ContentItem> items = List.generate(
    6,
    (_) => ContentItem(
      title: "Title",
      body:
          "Body text for whatever you'd like to say. "
          "Add main takeaway points, quotes, anecdotes, "
          "or even a very very short story.",
    ),
  );

  AboutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // About should be empty; content moved to ContentScreen.
    return Container();
  }

  Widget _buildSiteFooter() {
    final Map<String, List<String>> sections = {
      "Use cases": [
        "UI design",
        "UX design",
        "Wireframing",
        "Diagramming",
        "Brainstorming",
        "Online whiteboard",
        "Team collaboration",
      ],
      "Explore": [
        "Design",
        "Prototyping",
        "Development features",
        "Design systems",
        "Collaboration features",
        "Design process",
        "FigJam",
      ],
      "Resources": [
        "Blog",
        "Best practices",
        "Colors",
        "Color wheel",
        "Support",
        "Developers",
        "Resource library",
      ],
    };

    return Container(
      color: Colors.grey[100],
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo + social icons
          Row(
            children: const [
              Icon(Icons.grid_view, size: 24),
              SizedBox(width: 16),
              Icon(Icons.close, size: 18, color: Colors.grey),
              SizedBox(width: 8),
              Icon(Icons.camera_alt_outlined, size: 18, color: Colors.grey),
              SizedBox(width: 8),
              Icon(Icons.play_circle_outline, size: 18, color: Colors.grey),
              SizedBox(width: 8),
              Icon(Icons.link, size: 18, color: Colors.grey),
            ],
          ),
          const SizedBox(height: 16),

          // Link sections
          ...sections.entries.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.key,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 6),
                  ...entry.value.map(
                    (item) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Text(
                        item,
                        style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
