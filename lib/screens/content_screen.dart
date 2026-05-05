import 'package:flutter/material.dart';
import '../models/content_item.dart';
import 'content/content_widgets.dart';

class ContentScreen extends StatelessWidget {
  final List<ContentItem> items = [
    ContentItem(
      title: "Title",
      body:
          "Body text for whatever you'd like to say. Add main takeaway points, quotes, anecdotes, or even a very very short story.",
    ),
    ContentItem(
      title: "Title",
      body:
          "Body text for whatever you'd like to say. Add main takeaway points, quotes, anecdotes, or even a very very short story.",
    ),
    ContentItem(
      title: "Title",
      body:
          "Body text for whatever you'd like to say. Add main takeaway points, quotes, anecdotes, or even a very very short story.",
    ),
  ];

  final List<ContentItem> gridItems = List.generate(
    6,
    (_) => ContentItem(
      title: "Title",
      body:
          "Body text for whatever you'd like to say. Add main takeaway points, quotes, anecdotes, or even a very very short story.",
    ),
  );

  ContentScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Make the entire page scrollable: include the banner and footer inside
    // the SingleChildScrollView so tapping "Content" allows scrolling down
    // through the whole interface.
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ContentBanner(),

          // ── PHẦN 1: List cards ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Heading",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "Subheading",
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ],
            ),
          ),
          ...items.map((item) => _buildListCard(item)).toList(),

          const SizedBox(height: 16),

          // ── PHẦN 2: Grid 3x2 ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Heading",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "Subheading",
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 0.72,
              children:
                  gridItems.map((item) => _buildGridCard(item)).toList(),
            ),
          ),

          const SizedBox(height: 16),

          // ── PHẦN 3: Footer links ──
          _buildSiteFooter(),

          // App footer is now part of the scrollable content so it appears
          // at the end of the page and can be scrolled into view.
          const ContentFooter(),
        ],
      ),
    );
  }

  Widget _buildListCard(ContentItem item) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              bottomLeft: Radius.circular(8),
            ),
            child: Container(
              width: 100,
              height: 110,
              color: Colors.grey[300],
              child: Icon(Icons.image, color: Colors.grey[500], size: 40),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.body,
                    style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 4,
                      ),
                      minimumSize: const Size(0, 30),
                      side: BorderSide(color: Colors.grey[400]!),
                    ),
                    child: const Text(
                      "Button",
                      style: TextStyle(fontSize: 12, color: Colors.black87),
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

  Widget _buildGridCard(ContentItem item) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
            child: Container(
              width: double.infinity,
              height: 70,
              color: Colors.grey[300],
              child: Icon(Icons.image, color: Colors.grey[500], size: 30),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  item.body,
                  style: TextStyle(fontSize: 9, color: Colors.grey[700]),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
