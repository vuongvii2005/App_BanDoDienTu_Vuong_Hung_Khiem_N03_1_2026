import 'package:flutter/material.dart';

Widget buildBanner() {
  return Image.network(
    "https://images.pexels.com/photos/13200205/pexels-photo-13200205.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
    height: 200,
    width: double.infinity,
    fit: BoxFit.cover,
    loadingBuilder: (context, child, loadingProgress) {
      if (loadingProgress == null) return child;
      return Container(
        height: 200,
        color: Colors.grey[200],
        child: const Center(child: CircularProgressIndicator()),
      );
    },
    errorBuilder: (context, error, stackTrace) {
      return Container(
        height: 200,
        color: Colors.grey[300],
        child: const Icon(
          Icons.image_not_supported,
          size: 50,
          color: Colors.grey,
        ),
      );
    },
  );
}

Widget buildSimpleFooter() {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(10),
    color: Colors.grey[300],
    child: const Text(
      "Phenikaa University - Your Name",
      textAlign: TextAlign.center,
    ),
  );
}

Widget buildImagePlaceholder({double? height, double? width}) {
  return Container(
    height: height,
    width: width,
    decoration: BoxDecoration(
      color: Colors.grey[200],
      borderRadius: BorderRadius.circular(8),
    ),
    child: Center(
      child: Icon(Icons.image_outlined, size: 40, color: Colors.grey[400]),
    ),
  );
}
