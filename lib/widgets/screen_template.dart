import 'package:flutter/material.dart';

class ScreenTemplate extends StatelessWidget {
  final String groupImagePath; // Đường dẫn ảnh nhóm
  final Widget body; // Nội dung chính của trang
  final String studentName; // Tên sinh viên
  final Widget? appNavBar; // Navigation bar tùy chọn

  const ScreenTemplate({
    super.key,
    required this.groupImagePath,
    required this.body,
    required this.studentName,
    this.appNavBar,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // ===== NAVIGATION BAR =====
          if (appNavBar != null) appNavBar!,

          // ===== HEADER: Ảnh nhóm =====
          Container(
            height: 150,
            color: Colors.grey[300],
            child: Image.network(
              "https://nguyenkhiem-ux.github.io/anhgoup/Screenshot%202026-04-29%20103108.png",
              fit: BoxFit.cover,
            ),
          ),

          // ===== BODY: Nội dung chính =====
          body,

          // ===== FOOTER =====
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Logo + Social Media
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Logo
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('🟦', style: TextStyle(fontSize: 32)),
                        SizedBox(height: 20),
                        // Social Media Icons
                        Row(
                          children: [
                            Text('😊', style: TextStyle(fontSize: 24)),
                            SizedBox(width: 15),
                            Text('😂', style: TextStyle(fontSize: 24)),
                            SizedBox(width: 15),
                            Text('❤️', style: TextStyle(fontSize: 24)),
                            SizedBox(width: 15),
                            Text('👌', style: TextStyle(fontSize: 24)),
                          ],
                        ),
                      ],
                    ),
                    // 3 Column Footer
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Use cases
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Use cases',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 15),
                              Text('UI design', style: TextStyle(fontSize: 12)),
                              SizedBox(height: 10),
                              Text('UX design', style: TextStyle(fontSize: 12)),
                              SizedBox(height: 10),
                              Text(
                                'Wireframing',
                                style: TextStyle(fontSize: 12),
                              ),
                              SizedBox(height: 10),
                              Text(
                                'Diagramming',
                                style: TextStyle(fontSize: 12),
                              ),
                              SizedBox(height: 10),
                              Text(
                                'Brainstorming',
                                style: TextStyle(fontSize: 12),
                              ),
                              SizedBox(height: 10),
                              Text(
                                'Online whiteboard',
                                style: TextStyle(fontSize: 12),
                              ),
                              SizedBox(height: 10),
                              Text(
                                'Team collaboration',
                                style: TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                          // Explore
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Explore',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 15),
                              Text('Design', style: TextStyle(fontSize: 12)),
                              SizedBox(height: 10),
                              Text(
                                'Prototyping',
                                style: TextStyle(fontSize: 12),
                              ),
                              SizedBox(height: 10),
                              Text(
                                'Development features',
                                style: TextStyle(fontSize: 12),
                              ),
                              SizedBox(height: 10),
                              Text(
                                'Design systems',
                                style: TextStyle(fontSize: 12),
                              ),
                              SizedBox(height: 10),
                              Text(
                                'Collaboration features',
                                style: TextStyle(fontSize: 12),
                              ),
                              SizedBox(height: 10),
                              Text(
                                'Design process',
                                style: TextStyle(fontSize: 12),
                              ),
                              SizedBox(height: 10),
                              Text('FigJam', style: TextStyle(fontSize: 12)),
                            ],
                          ),
                          // Resources
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Resources',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 15),
                              Text('Blog', style: TextStyle(fontSize: 12)),
                              SizedBox(height: 10),
                              Text(
                                'Best practices',
                                style: TextStyle(fontSize: 12),
                              ),
                              SizedBox(height: 10),
                              Text('Colors', style: TextStyle(fontSize: 12)),
                              SizedBox(height: 10),
                              Text(
                                'Color wheel',
                                style: TextStyle(fontSize: 12),
                              ),
                              SizedBox(height: 10),
                              Text('Support', style: TextStyle(fontSize: 12)),
                              SizedBox(height: 10),
                              Text(
                                'Developers',
                                style: TextStyle(fontSize: 12),
                              ),
                              SizedBox(height: 10),
                              Text(
                                'Resource library',
                                style: TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                const Divider(),
                const SizedBox(height: 20),
                // Bottom info
                Center(
                  child: Column(
                    children: [
                      const Text(
                        'Phenikaa University',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Student Name: $studentName',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ), // <-- Đã sửa lỗi thêm dấu ngoặc ở đây
    ); // <-- Đã sửa lỗi ở đây
  }
}
