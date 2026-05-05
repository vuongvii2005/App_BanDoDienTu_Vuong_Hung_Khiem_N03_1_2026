import 'package:flutter/material.dart';
import '../models/content_item.dart';

class HomeScreen extends StatelessWidget {
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

  HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Home should be empty; all UI lives under ContentScreen.
    return Container();
  }
}
